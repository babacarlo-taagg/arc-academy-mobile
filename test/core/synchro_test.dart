import 'dart:async';
import 'dart:io';

import 'package:arc_academy/core/api/api_client.dart';
import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/db/base.dart';
import 'package:arc_academy/core/sync/journal.dart';
import 'package:arc_academy/core/sync/moteur_synchro.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/jetons_memoire.dart';

const cle = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

void main() {
  late FauxServeur serveur;
  late Directory dossier;
  late File fichierBase;
  late BaseProfil db;
  late JournalApprenant journal;
  late MoteurSynchro moteur;
  final planifies = <Duration>[];

  MoteurSynchro creerMoteur(BaseProfil base, {String? url}) => MoteurSynchro(
    db: base,
    api: ApiClient(baseUrl: url ?? serveur.url, jetons: JetonsMemoire(), delai: const Duration(seconds: 3)),
    journal: JournalApprenant(base),
    appareilId: '7c9e6679-7425-40de-944b-e07fc1f90ae7',
    planifier: (d, f) {
      planifies.add(d);
      return Timer(const Duration(days: 1), () {});
    },
  );

  setUp(() async {
    serveur = FauxServeur();
    await serveur.demarrer();
    dossier = Directory.systemTemp.createTempSync('arc_sync_');
    fichierBase = File('${dossier.path}/p.sqlite');
    db = BaseProfil.ouvrir(fichierBase, cle, enArrierePlan: false);
    journal = JournalApprenant(db);
    moteur = creerMoteur(db);
    planifies.clear();
    await db
        .into(db.formations)
        .insert(FormationsCompanion.insert(id: const Value(12), titre: 'PV', nbLecons: const Value(4)));
  });

  tearDown(() async {
    await moteur.fermer();
    await db.close();
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  test('envoie toute la file, compressée, puis la vide', () async {
    await journal.leconOuverte(12, 1);
    await journal.leconTerminee(12, 1);
    await journal.tempsPasse(12, 1, 300);
    expect(await db.compterEnAttente(), 3);

    final bilan = await moteur.envoyer();
    expect(bilan.envoyes, 3);
    expect(bilan.complet, isTrue);
    expect(await db.compterEnAttente(), 0);
    expect(serveur.evenementsRecus.length, 3);
    expect(serveur.requetesGzip, 1);
    expect(
      serveur.evenementsRecus.values.map((e) => e['type']),
      containsAll(['lecon_ouverte', 'lecon_terminee', 'temps_passe']),
    );
  });

  test('réponse perdue après traitement : rien ne se perd, rien n’est compté deux fois', () async {
    for (var i = 0; i < 5; i++) {
      await journal.tempsPasse(12, 1, 60);
    }
    serveur.perdreProchaineReponse = true;
    final premier = await moteur.envoyer();
    expect(premier.coupure, isTrue);
    expect(await db.compterEnAttente(), 5, reason: 'sans réponse, le téléphone garde tout');
    expect(serveur.evenementsRecus.length, 5, reason: 'le serveur avait pourtant tout reçu');
    expect(planifies, isNotEmpty, reason: 'un nouvel essai est programmé');

    final second = await moteur.envoyer();
    expect(second.envoyes, 5);
    expect(await db.compterEnAttente(), 0);
    expect(serveur.evenementsRecus.length, 5, reason: 'renvoyés avec le même identifiant : deja_recu');
  });

  test('serveur injoignable : la file reste intacte et l’attente augmente', () async {
    await serveur.arreter();
    await journal.leconTerminee(12, 2);
    final b1 = await moteur.envoyer();
    final b2 = await moteur.envoyer();
    expect(b1.coupure && b2.coupure, isTrue);
    expect(await db.compterEnAttente(), 1);
    expect(planifies.length, 2);
    expect(planifies[1], greaterThan(planifies[0]));
    // Le serveur revient (on le relance) : la file part.
    serveur = FauxServeur();
    await serveur.demarrer();
    final m2 = creerMoteur(db);
    expect((await m2.envoyer()).envoyes, 1);
    await m2.fermer();
  });

  test('appli tuée : la base rouverte contient toujours la file, qui part ensuite', () async {
    await journal.leconOuverte(12, 3);
    await journal.etatScorm(12, 3, {
      'completionStatus': 'incomplete',
      'successStatus': 'unknown',
      'runtimeData': {
        'cmi': {'suspend_data': 'p=4'},
      },
    });
    // « Tuer » l'appli : on ferme tout sans rien envoyer.
    await moteur.fermer();
    await db.close();

    db = BaseProfil.ouvrir(fichierBase, cle, enArrierePlan: false);
    journal = JournalApprenant(db);
    moteur = creerMoteur(db);
    expect(await db.compterEnAttente(), 2);
    expect((await journal.lireEtatScorm(3)).cmi, contains('p=4'));
    expect((await moteur.envoyer()).envoyes, 2);
  });

  test('un événement refusé quitte la file et reste dans le journal des refus', () async {
    serveur.leconsInconnues.add(99);
    await journal.leconTerminee(12, 99);
    await journal.leconTerminee(12, 1);
    final bilan = await moteur.envoyer();
    expect(bilan.envoyes, 1);
    expect(bilan.refuses, 1);
    expect(await db.compterEnAttente(), 0);
    final refuses = await db.select(db.evenementsRefuses).get();
    expect(refuses.single.raison, 'lecon_inconnue');
  });

  test('gros arriéré : paquets de taille croissante, plafonnés à 100', () async {
    await db.transaction(() async {
      for (var i = 0; i < 260; i++) {
        await db
            .into(db.evenements)
            .insert(
              EvenementsCompanion.insert(
                id: 'e$i-0000',
                type: 'temps_passe',
                coursId: 12,
                leconId: 1,
                survenuLe: DateTime.now(),
              ),
            );
      }
    });
    final bilan = await moteur.envoyer();
    expect(bilan.envoyes, 260);
    expect(serveur.taillesPaquets, [10, 20, 40, 80, 100, 10]);
  });

  test('l’état du serveur fait avancer la progression locale, jamais reculer', () async {
    await journal.leconTerminee(12, 1);
    await journal.leconTerminee(12, 2);
    var f = await (db.select(db.formations)..where((x) => x.id.equals(12))).getSingle();
    expect(f.progression, 50);

    await journal.appliquerEtatServeur(
      const EtatSynchro(
        formations: [
          EtatFormation(coursId: 12, progression: 25, lecons: [EtatLecon(leconId: 1, terminee: false)]),
        ],
      ),
    );
    f = await (db.select(db.formations)..where((x) => x.id.equals(12))).getSingle();
    expect(f.progression, 50, reason: 'le serveur en retard ne fait pas reculer');
    final l1 = await (db.select(db.etatsLecons)..where((x) => x.leconId.equals(1))).getSingle();
    expect(l1.terminee, isTrue);

    await journal.appliquerEtatServeur(
      const EtatSynchro(
        formations: [
          EtatFormation(coursId: 12, progression: 75, lecons: [EtatLecon(leconId: 3, terminee: true)]),
        ],
      ),
    );
    f = await (db.select(db.formations)..where((x) => x.id.equals(12))).getSingle();
    expect(f.progression, 75);
  });

  test('SCORM : meilleur score, réussite définitive, cmi le plus avancé', () async {
    await journal.etatScorm(12, 5, {
      'completionStatus': 'completed',
      'successStatus': 'passed',
      'score': {'raw': 80, 'min': 0, 'max': 100},
      'totalTimeSeconds': 900,
      'runtimeData': {
        'cmi': {'suspend_data': 'fin'},
      },
    });
    // Nouvelle tentative moins bonne, pas terminée.
    final etat = await journal.etatScorm(12, 5, {
      'completionStatus': 'incomplete',
      'successStatus': 'failed',
      'score': {'raw': 40, 'min': 0, 'max': 100},
      'totalTimeSeconds': 1000,
      'runtimeData': {
        'cmi': {'suspend_data': 'debut'},
      },
    });
    expect(etat.completionStatus, 'completed');
    expect(etat.successStatus, 'passed');
    expect(etat.scorePourcent, 80);
    expect(etat.totalTimeSeconds, 1000);
    expect(etat.cmi, contains('fin'));
    expect(etat.estTermine, isTrue);
    final lecon = await (db.select(db.etatsLecons)..where((x) => x.leconId.equals(5))).getSingle();
    expect(lecon.terminee, isTrue);
    // Un seul envoi, avec l'état fusionné (le meilleur) : économie de données.
    final attente = await db.select(db.evenements).get();
    expect(attente, hasLength(1));
    expect(attente.single.donnees, contains('"successStatus":"passed"'));
    expect(attente.single.donnees, contains('"raw":80'));
    expect(attente.single.donnees, contains('fin'));
  });

  test('une leçon déjà terminée ne crée pas un second événement « terminée »', () async {
    await journal.leconTerminee(12, 1);
    await journal.leconTerminee(12, 1);
    expect(await db.compterEnAttente(), 1);
  });

  test('un seul envoi à la fois', () async {
    for (var i = 0; i < 3; i++) {
      await journal.tempsPasse(12, 1, 30);
    }
    final a = moteur.envoyer();
    final b = moteur.envoyer();
    expect(identical(a, b), isTrue);
    await a;
    expect(serveur.taillesPaquets, [3]);
  });
}
