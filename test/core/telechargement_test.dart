import 'dart:io';
import 'dart:math';

import 'package:arc_academy/core/api/api_client.dart';
import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/contenus/depot_contenus.dart';
import 'package:arc_academy/core/contenus/telechargeur.dart';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/jetons_memoire.dart';

List<int> contenuAleatoire(int taille, int graine) {
  final r = Random(graine);
  return List<int>.generate(taille, (_) => r.nextInt(256));
}

Fichier fichierDe(String chemin, List<int> contenu, [String type = 'application/octet-stream']) =>
    Fichier(chemin: chemin, empreinte: FauxServeur.empreinte(contenu), taille: contenu.length, typeMime: type);

void main() {
  late FauxServeur serveur;
  late Directory dossier;
  late DepotContenus depot;
  late ApiClient api;

  setUp(() async {
    serveur = FauxServeur();
    await serveur.demarrer();
    dossier = Directory.systemTemp.createTempSync('arc_depot_');
    depot = DepotContenus(Directory('${dossier.path}/contenus'));
    await depot.preparer();
    api = ApiClient(baseUrl: serveur.url, jetons: JetonsMemoire());
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  Telechargeur telechargeur({int essais = 1, Future<int?> Function()? place}) => Telechargeur(
    depot: depot,
    api: api,
    essaisParFichier: essais,
    attente: (_) => Duration.zero,
    placeLibre: place,
    margeSecurite: 0,
  );

  test('coupure au milieu d’un fichier puis reprise par Range : fichier final correct', () async {
    final contenu = contenuAleatoire(300000, 1);
    serveur.ajouterFichier(contenu);
    final f = fichierDe('video.mp4', contenu);
    serveur.couperFichierApres = 120000;

    await expectLater(telechargeur().telechargerFichier(f), throwsA(isA<TelechargementInterrompu>()));
    expect(depot.possede(f.empreinte), isFalse);
    final recu = depot.fichierPartiel(f.empreinte).lengthSync();
    expect(recu, greaterThan(0));
    expect(recu, lessThan(contenu.length));

    final fichier = await telechargeur().telechargerFichier(f);
    expect(serveur.rangesRecus.last, 'bytes=$recu-');
    expect(fichier.readAsBytesSync(), contenu);
    expect(depot.fichierPartiel(f.empreinte).existsSync(), isFalse);
  });

  test('après une coupure, le téléchargeur réessaie tout seul et termine', () async {
    final contenu = contenuAleatoire(200000, 2);
    serveur.ajouterFichier(contenu);
    serveur.couperFichierApres = 50000;
    final fichier = await telechargeur(essais: 3).telechargerFichier(fichierDe('doc.pdf', contenu));
    expect(await empreinteFichier(fichier), FauxServeur.empreinte(contenu));
    expect(serveur.fichiersDemandes.length, 2);
  });

  test('un fichier abîmé est rejeté et jamais rangé', () async {
    final contenu = contenuAleatoire(1000, 3);
    serveur.ajouterFichier(contenu);
    serveur.servirFichierAbime = true;
    final f = fichierDe('a.html', contenu);
    await expectLater(telechargeur().telechargerFichier(f), throwsA(isA<EmpreinteIncorrecte>()));
    expect(depot.possede(f.empreinte), isFalse);
    expect(depot.fichierPartiel(f.empreinte).existsSync(), isFalse);
  });

  Manifest manifest(String version, List<(int, Fichier)> fichiers) => Manifest(
    coursId: 7,
    version: version,
    titre: 'Cours',
    tailleTotale: fichiers.fold(0, (s, f) => s + f.$2.taille),
    lecons: [
      for (final (id, f) in fichiers)
        Lecon(
          id: id,
          titre: 'L$id',
          type: TypeLecon.article,
          ordre: id,
          horsLigne: true,
          terminee: false,
          fichiers: [f],
          entree: f.chemin,
        ),
    ],
  );

  test('mise à jour différentielle : seuls les fichiers changés sont retéléchargés', () async {
    final a = contenuAleatoire(5000, 4), b = contenuAleatoire(6000, 5), b2 = contenuAleatoire(6100, 6);
    for (final c in [a, b, b2]) {
      serveur.ajouterFichier(c);
    }
    final v1 = manifest('v1', [(1, fichierDe('index.html', a)), (2, fichierDe('index.html', b))]);
    await telechargeur().telechargerCours(v1);
    expect(depot.etat(7, versionServeur: 'v1'), EtatHorsLigne.complet);
    expect(depot.etat(7, versionServeur: 'v2'), EtatHorsLigne.miseAJour);
    expect(serveur.fichiersDemandes.length, 2);

    final v2 = manifest('v2', [(1, fichierDe('index.html', a)), (2, fichierDe('index.html', b2))]);
    serveur.fichiersDemandes.clear();
    await telechargeur().telechargerCours(v2);
    expect(serveur.fichiersDemandes, [FauxServeur.empreinte(b2)]);
    // L'ancien fichier, qui ne sert plus, a été supprimé.
    expect(depot.possede(FauxServeur.empreinte(b)), isFalse);
    expect(depot.etat(7, versionServeur: 'v2'), EtatHorsLigne.complet);
  });

  test('place insuffisante : refus clair avant de télécharger', () async {
    final a = contenuAleatoire(10000, 7);
    serveur.ajouterFichier(a);
    final m = manifest('v1', [(1, fichierDe('index.html', a))]);
    await expectLater(
      telechargeur(place: () async => 5000).telechargerCours(m),
      throwsA(isA<PlaceInsuffisante>().having((e) => e.necessaire, 'nécessaire', 10000)),
    );
    expect(serveur.fichiersDemandes, isEmpty);
  });

  test('paquet SCORM décompressé une fois, sans sortir de son dossier', () async {
    final archive = Archive()
      ..addFile(ArchiveFile.string('imsmanifest.xml', '<manifest/>'))
      ..addFile(ArchiveFile.string('story.html', '<p>module</p>'))
      ..addFile(ArchiveFile.string('../../evasion.txt', 'non'));
    final zip = ZipEncoder().encode(archive);
    serveur.ajouterFichier(zip);
    final f = fichierDe('paquet.zip', zip, 'application/zip');
    final m = Manifest(
      coursId: 8,
      version: 'v1',
      titre: 'SCORM',
      tailleTotale: zip.length,
      lecons: [
        Lecon(
          id: 3,
          titre: 'Module',
          type: TypeLecon.scorm,
          ordre: 1,
          horsLigne: true,
          terminee: false,
          fichiers: [f],
          entree: 'story.html',
          scormVersion: '1.2',
        ),
      ],
    );
    await telechargeur().telechargerCours(m);
    final d = depot.dossierScorm(f.empreinte);
    expect(File('${d.path}/story.html').readAsStringSync(), '<p>module</p>');
    expect(File('${dossier.path}/evasion.txt').existsSync(), isFalse);
    expect(File('${dossier.path}/contenus/evasion.txt').existsSync(), isFalse);
  });

  test('supprimer un cours libère ses fichiers mais garde ceux d’un autre cours', () async {
    final commun = contenuAleatoire(3000, 8), propre = contenuAleatoire(3000, 9);
    serveur.ajouterFichier(commun);
    serveur.ajouterFichier(propre);
    await telechargeur().telechargerCours(
      manifest('v1', [(1, fichierDe('index.html', commun)), (2, fichierDe('index.html', propre))]),
    );
    final autre = Manifest(
      coursId: 9,
      version: 'x',
      titre: 'Autre',
      tailleTotale: commun.length,
      lecons: [
        Lecon(
          id: 5,
          titre: 'L',
          type: TypeLecon.pdf,
          ordre: 1,
          horsLigne: true,
          terminee: false,
          fichiers: [fichierDe('document.pdf', commun)],
        ),
      ],
    );
    serveur.fichiersDemandes.clear();
    await telechargeur().telechargerCours(autre);
    expect(serveur.fichiersDemandes, isEmpty, reason: 'fichier commun déjà présent : pas de doublon');
    await depot.supprimerCours(7);
    expect(depot.possede(FauxServeur.empreinte(commun)), isTrue);
    expect(depot.possede(FauxServeur.empreinte(propre)), isFalse);
  });
}
