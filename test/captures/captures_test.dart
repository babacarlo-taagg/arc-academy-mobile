@Tags(['captures'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:arc_academy/app.dart';
import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/harnais.dart';

/// Captures d'écran des écrans principaux (docs/captures), avec les vraies polices.
/// Les refaire : flutter test --tags captures --update-goldens
void main() {
  late FauxServeur serveur;
  late Directory dossier;

  final article = utf8.encode('<html><body><h1>Notifier</h1></body></html>');
  final pdf = List<int>.generate(4000, (i) => i % 251);

  setUp(() async {
    preparerReseauReel();
    serveur = FauxServeur();
    await serveur.demarrer();
    serveur.ajouterFichier(article);
    serveur.ajouterFichier(pdf);
    serveur.formations = [
      {
        'id': 12,
        'titre': 'Certificat de Praticien en Pharmacovigilance',
        'cohortes': [
          {'id': 3, 'nom': 'PV-2026-Kolda'},
        ],
        'tuteurs': [
          {'nom': 'Dr Fatou Ndiaye'},
        ],
        'nbLecons': 17,
        'nbLeconsTerminees': 5,
        'progression': 29,
        'version': 'v1',
        'tailleTelechargement': article.length + pdf.length,
      },
      {
        'id': 14,
        'titre': 'Gestion des stocks de médicaments au district',
        'cohortes': [
          {'id': 3, 'nom': 'PV-2026-Kolda'},
        ],
        'tuteurs': [],
        'nbLecons': 9,
        'nbLeconsTerminees': 0,
        'progression': 0,
        'version': 'w1',
        'tailleTelechargement': 24117248,
      },
    ];
    Map<String, dynamic> f(String chemin, List<int> c, String type) => {
      'chemin': chemin,
      'empreinte': FauxServeur.empreinte(c),
      'taille': c.length,
      'typeMime': type,
    };
    serveur.manifestes[12] = {
      'coursId': 12,
      'version': 'v1',
      'titre': 'Certificat de Praticien en Pharmacovigilance',
      'tailleTotale': article.length + pdf.length,
      'lecons': [
        {
          'id': 1,
          'titre': "Qu'est-ce que la pharmacovigilance ?",
          'type': 'article',
          'section': 'Module 1 — Les bases',
          'ordre': 1,
          'dureeMinutes': 10,
          'horsLigne': true,
          'terminee': true,
          'entree': 'index.html',
          'fichiers': [f('index.html', article, 'text/html')],
        },
        {
          'id': 2,
          'titre': 'Fiche de notification nationale',
          'type': 'pdf',
          'section': 'Module 1 — Les bases',
          'ordre': 2,
          'dureeMinutes': 5,
          'horsLigne': true,
          'terminee': false,
          'entree': 'document.pdf',
          'fichiers': [f('document.pdf', pdf, 'application/pdf')],
        },
        {
          'id': 3,
          'titre': 'Notifier un effet indésirable',
          'type': 'scorm',
          'section': 'Module 2 — Notifier',
          'ordre': 3,
          'dureeMinutes': 25,
          'horsLigne': false,
          'terminee': false,
          'fichiers': [],
          'urlEnLigne': '/slides/slide/3',
        },
        {
          'id': 4,
          'titre': 'Témoignage d’un point focal',
          'type': 'video',
          'section': 'Module 2 — Notifier',
          'ordre': 4,
          'dureeMinutes': 8,
          'horsLigne': false,
          'terminee': false,
          'fichiers': [],
          'urlEnLigne': '/slides/slide/4',
        },
        {
          'id': 5,
          'titre': 'Quiz du module 2',
          'type': 'quiz',
          'section': 'Module 2 — Notifier',
          'ordre': 5,
          'horsLigne': false,
          'terminee': false,
          'fichiers': [],
        },
      ],
    };
    dossier = Directory.systemTemp.createTempSync('arc_captures_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  /// Parcourt les écrans et les capture au format demandé (taille logique, densité, dossier, écrans retenus).
  Future<void> parcours(
    WidgetTester tester, {
    Size taille = const Size(360, 740),
    double densite = 2,
    String sortie = 'docs/captures',
    Set<String>? ecrans,
  }) async {
    Future<void> capture(WidgetTester tester, String nom) async {
      await attendre(tester, fois: 8);
      if (ecrans != null && !ecrans.contains(nom)) return;
      await expectLater(find.byType(AppliArc), matchesGoldenFile('../../$sortie/$nom.png'));
    }

    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url);
    late String id;
    await tester.runAsync(() async {
      final p = await services.profils.ouvrirSession(sessionDeTest(42, 'Awa Diop'));
      id = p.id;
      await services.profils.definirPin(p.id, '1234');
      final m = await services.profils.ouvrirSession(sessionDeTest(43, 'Moussa Ba'));
      await services.profils.definirPin(m.id, '1234');
    });
    final conteneur = await lancerAppli(tester, services, taille: taille, densite: densite);
    await capture(tester, '01_profils');

    await tester.tap(find.byKey(Key('profil_$id')));
    await capture(tester, '02_code_secret');

    final routeur = conteneur.read(routeurProvider);
    routeur.push('/connexion');
    await attendre(tester);
    await tester.enterText(find.byKey(const Key('champ_email')), 'awa.diop@example.org');
    await capture(tester, '03_connexion');
    routeur.push(
      '/connexion/code',
      extra: (
        'awa.diop@example.org',
        const CodeEnvoye(emailMasque: 'a•••@example.org', expireDans: 600, renvoiPossibleDans: 45),
      ),
    );
    await capture(tester, '04_code_email');

    // Profil ouvert, premier cours téléchargé.
    await tester.runAsync(() async {
      await conteneur.read(profilOuvertProvider.notifier).ouvrir((await services.profils.profil(id))!);
      final ouvert = conteneur.read(profilOuvertProvider)!;
      await ouvert.mettreAJourFormations();
      final m = await ouvert.api.manifest(12);
      await ouvert.telechargeur.telechargerCours(m!);
    });
    routeur.go('/formations');
    await capture(tester, '05_mes_formations');
    routeur.push('/cours/12');
    await capture(tester, '06_cours');
    routeur.push('/lecon/12/4');
    await capture(tester, '07_lecon_en_ligne');
    routeur.go('/reglages');
    await capture(tester, '08_reglages');
    routeur.push('/reglages/suppression');
    await capture(tester, '09_suppression_compte');
    await terminer(tester, conteneur);
  }

  testWidgets('captures des écrans', (tester) => parcours(tester));

  // Fiches des stores. Google Play : rapport hauteur/largeur de 2 au plus (1080×1920 ici).
  // App Store : captures d'iPhone 6,9 pouces (1320×2868).
  const ecransStores = {'01_profils', '03_connexion', '05_mes_formations', '06_cours', '08_reglages'};
  testWidgets(
    'captures Google Play',
    (tester) => parcours(
      tester,
      taille: const Size(360, 640),
      densite: 3,
      sortie: 'store/android/fr-FR/captures',
      ecrans: ecransStores,
    ),
  );
  testWidgets(
    'captures App Store',
    (tester) => parcours(
      tester,
      taille: const Size(440, 956),
      densite: 3,
      sortie: 'store/ios/fr-FR/captures',
      ecrans: ecransStores,
    ),
  );
}
