@Tags(['e2e'])
library;

/// Essai de bout en bout contre un vrai serveur Odoo avec `arc_mobile_api` (base de démonstration préparée par
/// `arc-academy-odoo/scripts/preparer_base_demo_mobile.py`, code de test 123456).
///
///     ARC_E2E_URL=http://127.0.0.1:8069/api/v1 flutter test test/e2e
///
/// Le téléphone passe par un « relais coupeur » qui simule le terrain : le premier téléchargement est coupé au
/// milieu, la réponse du premier envoi de progression est perdue. Le module SCORM téléchargé est vraiment joué
/// dans Chromium (Playwright) à travers le serveur local de l'appli, en deux fois (reprise).
/// Sans ARC_E2E_URL, l'essai est ignoré (il ne tourne pas dans la CI).
import 'dart:convert';
import 'dart:io';

import 'package:arc_academy/core/api/api_client.dart';
import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/contenus/depot_contenus.dart';
import 'package:arc_academy/core/profils/coffre_fort.dart';
import 'package:arc_academy/core/profils/profils.dart';
import 'package:arc_academy/core/reglages/reglages.dart';
import 'package:arc_academy/core/serveur_local/serveur_local.dart';
import 'package:arc_academy/core/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/harnais.dart';
import '../outils/jetons_memoire.dart';

final _url = Platform.environment['ARC_E2E_URL'];
const _email = 'awa.demo@arc-academy.test';
const _cours = 1;

/// Relais HTTP entre l'appli et Odoo, qui sait couper une réponse.
class RelaisCoupeur {
  RelaisCoupeur(this.cible);
  final Uri cible;
  HttpServer? _serveur;
  final _client = HttpClient()..autoUncompress = false;

  bool couperProchainFichier = false;
  bool perdreProchaineSynchro = false;
  int fichiersCoupes = 0;
  int synchrosPerdues = 0;
  final requetesRange = <String>[];

  String get url => 'http://127.0.0.1:${_serveur!.port}${cible.path}';

  Future<void> demarrer() async {
    _serveur = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _serveur!.listen(_relayer);
  }

  Future<void> arreter() async {
    await _serveur?.close(force: true);
    _client.close(force: true);
  }

  Future<void> _relayer(HttpRequest entree) async {
    final corps = await entree.fold<List<int>>([], (a, b) => a..addAll(b));
    final suite = entree.uri.path.substring(cible.path.length);
    final req = await _client.openUrl(
      entree.method,
      cible.replace(path: '${cible.path}$suite', query: entree.uri.query),
    );
    for (final h in [
      'authorization',
      'content-type',
      'content-encoding',
      'range',
      'if-none-match',
      'accept-language',
    ]) {
      final v = entree.headers.value(h);
      if (v != null) req.headers.set(h, v);
    }
    if (entree.headers.value('range') != null) requetesRange.add(entree.headers.value('range')!);
    req.add(corps);
    final rep = await req.close();
    final octets = await rep.fold<List<int>>([], (a, b) => a..addAll(b));

    if (suite == '/sync/evenements' && perdreProchaineSynchro) {
      // Odoo a tout reçu et traité ; la réponse se perd en route (réseau coupé).
      perdreProchaineSynchro = false;
      synchrosPerdues++;
      (await entree.response.detachSocket(writeHeaders: false)).destroy();
      return;
    }
    final sortie = entree.response..statusCode = rep.statusCode;
    for (final h in ['content-type', 'content-encoding', 'etag', 'content-range', 'accept-ranges', 'cache-control']) {
      final v = rep.headers.value(h);
      if (v != null) sortie.headers.set(h, v);
    }
    sortie.contentLength = octets.length;
    if (suite.startsWith('/fichiers/') && couperProchainFichier && octets.length > 1000) {
      // La connexion tombe au milieu du fichier.
      couperProchainFichier = false;
      fichiersCoupes++;
      final socket = await sortie.detachSocket();
      socket.add(octets.sublist(0, octets.length ~/ 2));
      await socket.flush();
      socket.destroy();
      return;
    }
    sortie.add(octets);
    await sortie.close();
  }
}

/// Joue le module SCORM dans Chromium : clique `clics` fois sur le bouton du module, rend le texte d'état lu
/// avant de cliquer.
Future<String> jouerScorm(String url, int clics) async {
  final script = File('${Directory.systemTemp.path}/arc_e2e_scorm.js')
    ..writeAsStringSync('''
const { chromium } = require('playwright');
(async () => {
  const navigateur = await chromium.launch();
  const page = await navigateur.newPage();
  await page.goto(process.argv[2]);
  const cadre = page.frameLocator('iframe');
  await cadre.locator('#etat').waitFor();
  console.log('ETAT:' + await cadre.locator('#etat').textContent());
  for (let i = 0; i < Number(process.argv[3]); i++) {
    await cadre.locator('#suivant').click();
    await page.waitForTimeout(400);
  }
  await page.waitForTimeout(1500);
  await navigateur.close();
})().catch((e) => { console.error(e); process.exit(1); });
''');
  final r = await Process.run(
    'node',
    [script.path, url, '$clics'],
    environment: {'NODE_PATH': '/opt/node-tools/node_modules'},
  );
  expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  return RegExp(r'ETAT:(.*)').firstMatch(r.stdout as String)!.group(1)!.trim();
}

void main() {
  late Directory dossier;
  late RelaisCoupeur relais;
  late Services services;

  setUp(() async {
    preparerReseauReel();
    dossier = Directory.systemTemp.createTempSync('arc_e2e_');
    relais = RelaisCoupeur(Uri.parse(_url ?? 'http://127.0.0.1:8069/api/v1'));
    await relais.demarrer();
    final coffre = CoffreFortMemoire();
    final depot = DepotContenus(Directory('${dossier.path}/contenus'));
    await depot.preparer();
    Manifest? manifestLocal(int c) => depot.manifestLocal(c);
    services = Services(
      coffre: coffre,
      profils: ProfilStore(coffre),
      depot: depot,
      reglages: Reglages(File('${dossier.path}/reglages.json')),
      serveurLocal: ServeurLocal(
        depot: depot,
        lecon: (c, l) => manifestLocal(c)?.lecons.where((x) => x.id == l).firstOrNull,
        scormAgain: () async => File('assets/scorm/scorm-again.min.js').readAsBytesSync(),
      ),
      dossierBases: Directory('${dossier.path}/profils'),
      connectivite: ConnectiviteTest(),
      baseUrl: relais.url,
      placeLibre: () async => 2 * 1024 * 1024 * 1024,
      basesEnArrierePlan: false,
    );
    await services.serveurLocal.demarrer();
  });

  tearDown(() async {
    await services.serveurLocal.arreter();
    await relais.arreter();
    dossier.deleteSync(recursive: true);
  });

  test(
    'connexion, téléchargement coupé puis repris, article + PDF + SCORM hors ligne, synchro coupée, état serveur',
    () async {
      // 1. Connexion par code e-mail.
      final anonyme = ApiClient(baseUrl: relais.url);
      final envoi = await anonyme.demanderCode(_email);
      expect(envoi.emailMasque, contains('@arc-academy.test'));
      final session = await anonyme.verifierCode(
        email: _email,
        code: '123456',
        appareil: await services.descriptionAppareil(),
      );
      final profil = await services.profils.ouvrirSession(session);
      await services.profils.definirPin(profil.id, '2468');
      final ouvert = await services.ouvrirProfil(profil);
      ouvert.activer();

      // 2. Mes formations.
      await ouvert.mettreAJourFormations();
      final formations = await ouvert.api.formations();
      final cours = formations.singleWhere((f) => f.id == _cours);
      expect(cours.tailleTelechargement, greaterThan(0));

      // 3. Téléchargement : la connexion tombe au milieu d'un fichier, la reprise se fait par Range.
      final manifest = (await ouvert.manifest(_cours))!;
      relais.couperProchainFichier = true;
      await ouvert.telechargeur.telechargerCours(manifest);
      expect(relais.fichiersCoupes, 1);
      expect(relais.requetesRange, isNotEmpty, reason: 'la reprise doit demander la suite du fichier');
      expect(services.depot.etat(_cours, versionServeur: cours.version), EtatHorsLigne.complet);
      for (final f in manifest.fichiersDistincts.values) {
        expect(await empreinteFichier(services.depot.fichierObjet(f.empreinte)), f.empreinte);
      }

      // 4. Désormais, plus besoin du serveur : article et PDF lus depuis le téléphone.
      final article = manifest.lecons.firstWhere((l) => l.type == TypeLecon.article);
      final pdf = manifest.lecons.firstWhere((l) => l.type == TypeLecon.pdf);
      final scorm = manifest.lecons.firstWhere((l) => l.type == TypeLecon.scorm);
      final client = HttpClient();
      final html = await (await (await client.getUrl(
        Uri.parse(services.serveurLocal.urlLecon(_cours, article.id, 'index.html')),
      )).close()).transform(utf8.decoder).join();
      expect(html, contains('<img'));
      expect(html.toLowerCase(), isNot(contains('<script')));
      final repPdf = await (await client.getUrl(
        Uri.parse(services.serveurLocal.urlLecon(_cours, pdf.id, 'document.pdf')),
      )).close();
      expect(String.fromCharCodes(await repPdf.first).startsWith('%PDF'), isTrue);
      client.close();
      await ouvert.journal.leconOuverte(_cours, article.id);
      await ouvert.journal.tempsPasse(_cours, article.id, 240);
      await ouvert.journal.leconTerminee(_cours, article.id);
      await ouvert.journal.leconOuverte(_cours, pdf.id);
      await ouvert.journal.leconTerminee(_cours, pdf.id);

      // 5. SCORM joué dans un vrai navigateur : une page, on ferme, on revient → reprise à la page 2.
      final urlScorm = services.serveurLocal.urlScorm(_cours, scorm.id);
      expect(await jouerScorm(urlScorm, 1), 'Page 1 sur 3');
      expect(await jouerScorm(urlScorm, 3), 'Page 2 sur 3', reason: 'le module doit reprendre où il en était');
      final local = await ouvert.journal.lireEtatScorm(scorm.id);
      expect(local.cmi, isNotNull);

      // 6. Synchro : la réponse du premier envoi est perdue après traitement par Odoo.
      expect(await ouvert.db.compterEnAttente(), greaterThan(0));
      relais.perdreProchaineSynchro = true;
      final premier = await ouvert.moteur.envoyer();
      expect(relais.synchrosPerdues, 1);
      expect(premier.complet, isFalse);
      expect(await ouvert.db.compterEnAttente(), greaterThan(0), reason: 'rien n’est retiré sans réponse');
      final second = await ouvert.moteur.envoyer();
      expect(second.complet, isTrue);
      expect(await ouvert.db.compterEnAttente(), 0);

      // 7. Côté serveur : tout est compté une fois, la reprise SCORM est disponible pour un autre téléphone.
      final etat = await ouvert.api.etat(coursId: _cours);
      final f = etat.formations.singleWhere((x) => x.coursId == _cours);
      final parLecon = {for (final l in f.lecons) l.leconId: l};
      expect(parLecon[article.id]!.terminee, isTrue);
      expect(parLecon[pdf.id]!.terminee, isTrue);
      expect(parLecon[scorm.id]!.terminee, isTrue);
      expect(parLecon[scorm.id]!.scorm!.successStatus, 'passed');
      expect(parLecon[scorm.id]!.scorm!.scorePourcent, 80);
      expect(f.progression, greaterThanOrEqualTo(75));

      // Un renvoi de tout ce qui a déjà été envoyé ne change rien (identifiants déjà vus).
      final dejaVu = await ouvert.api.envoyerEvenements(await services.profils.appareilId(), [
        {
          'id': '00000000-0000-4000-8000-000000000001',
          'type': 'temps_passe',
          'coursId': _cours,
          'leconId': article.id,
          'survenuLe': DateTime.now().toUtc().toIso8601String(),
          'donnees': {'secondes': 1},
        },
      ]);
      final encore = await ouvert.api.envoyerEvenements(await services.profils.appareilId(), [
        {
          'id': '00000000-0000-4000-8000-000000000001',
          'type': 'temps_passe',
          'coursId': _cours,
          'leconId': article.id,
          'survenuLe': DateTime.now().toUtc().toIso8601String(),
          'donnees': {'secondes': 1},
        },
      ]);
      expect(dejaVu.resultats.single.statut, anyOf('accepte', 'deja_recu'));
      expect(encore.resultats.single.statut, 'deja_recu');

      // 8. Second téléphone (même compte) : il retrouve l'état SCORM complet pour reprendre.
      final autre = ApiClient(
        baseUrl: _url!,
        jetons: JetonsMemoire(acces: await services.profils.jetonAcces(profil.id)),
      );
      final etatAutre = await autre.etat(coursId: _cours);
      final s = etatAutre.formations.single.lecons.singleWhere((l) => l.leconId == scorm.id).scorm!;
      expect(jsonEncode(s.runtimeData), contains('lesson_location'));

      await ouvert.fermer();
    },
    skip: _url == null ? 'ARC_E2E_URL non défini (serveur Odoo de démonstration)' : false,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
