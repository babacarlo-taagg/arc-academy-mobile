import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../api/modeles.dart';
import '../db/base.dart';
import 'fusion.dart';

/// Écrit chaque action de l'apprenant **dans la même transaction** que la mise à jour de l'état local et que
/// l'événement à envoyer : si l'appli est tuée ou la batterie lâche, soit tout est écrit, soit rien.
class JournalApprenant {
  JournalApprenant(this.db, {DateTime Function()? horloge}) : _horloge = horloge ?? DateTime.now;

  final BaseProfil db;
  final DateTime Function() _horloge;

  /// Prévient le moteur de synchronisation qu'un événement attend.
  void Function()? _apresEcriture;
  set apresEcriture(void Function()? f) => _apresEcriture = f;

  Future<void> _ajouterEvenement(String type, int coursId, int leconId, Map<String, dynamic> donnees) async {
    await db
        .into(db.evenements)
        .insert(
          EvenementsCompanion.insert(
            id: const Uuid().v4(),
            type: type,
            coursId: coursId,
            leconId: leconId,
            survenuLe: _horloge().toUtc(),
            donnees: Value(jsonEncode(donnees)),
          ),
        );
  }

  Future<EtatLeconLocal?> _etatLecon(int leconId) =>
      (db.select(db.etatsLecons)..where((e) => e.leconId.equals(leconId))).getSingleOrNull();

  Future<void> _majLecon(int coursId, int leconId, {bool? terminee, bool? ouverte, int ajoutTemps = 0}) async {
    final actuel = await _etatLecon(leconId);
    await db
        .into(db.etatsLecons)
        .insertOnConflictUpdate(
          EtatsLeconsCompanion.insert(
            leconId: Value(leconId),
            coursId: coursId,
            terminee: Value((actuel?.terminee ?? false) || (terminee ?? false)),
            ouverte: Value((actuel?.ouverte ?? false) || (ouverte ?? false)),
            tempsSecondes: Value((actuel?.tempsSecondes ?? 0) + ajoutTemps),
            majLe: _horloge(),
          ),
        );
  }

  /// Recalcule la progression locale du cours (jamais en dessous de celle du serveur).
  Future<void> _majProgression(int coursId) async {
    final formation = await (db.select(db.formations)..where((f) => f.id.equals(coursId))).getSingleOrNull();
    if (formation == null || formation.nbLecons == 0) return;
    final n = db.etatsLecons.leconId.count();
    final terminees =
        (await (db.selectOnly(db.etatsLecons)
                  ..addColumns([n])
                  ..where(db.etatsLecons.coursId.equals(coursId) & db.etatsLecons.terminee.equals(true)))
                .getSingle())
            .read(n) ??
        0;
    final nb = terminees > formation.nbLeconsTerminees ? terminees : formation.nbLeconsTerminees;
    final pourcent = (nb * 100 / formation.nbLecons).round().clamp(0, 100);
    await (db.update(db.formations)..where((f) => f.id.equals(coursId))).write(
      FormationsCompanion(
        nbLeconsTerminees: Value(nb),
        progression: Value(pourcent > formation.progression ? pourcent : formation.progression),
        derniereActivite: Value(_horloge().toUtc()),
      ),
    );
  }

  Future<void> leconOuverte(int coursId, int leconId) async {
    await db.transaction(() async {
      await _majLecon(coursId, leconId, ouverte: true);
      await _ajouterEvenement('lecon_ouverte', coursId, leconId, const {});
    });
    _apresEcriture?.call();
  }

  Future<void> leconTerminee(int coursId, int leconId) async {
    await db.transaction(() async {
      final deja = (await _etatLecon(leconId))?.terminee ?? false;
      await _majLecon(coursId, leconId, terminee: true, ouverte: true);
      if (!deja) await _ajouterEvenement('lecon_terminee', coursId, leconId, const {});
      await _majProgression(coursId);
    });
    _apresEcriture?.call();
  }

  /// Temps passé dans une leçon depuis la dernière fois (ignoré sous 5 secondes).
  Future<void> tempsPasse(int coursId, int leconId, int secondes) async {
    if (secondes < 5) return;
    await db.transaction(() async {
      await _majLecon(coursId, leconId, ajoutTemps: secondes);
      await _ajouterEvenement('temps_passe', coursId, leconId, {'secondes': secondes});
    });
    _apresEcriture?.call();
  }

  Future<EtatScormLocal> lireEtatScorm(int leconId) async {
    final ligne = await (db.select(db.etatsScorm)..where((e) => e.leconId.equals(leconId))).getSingleOrNull();
    if (ligne == null) return const EtatScormLocal();
    return EtatScormLocal(
      completionStatus: ligne.completionStatus,
      successStatus: ligne.successStatus,
      scorePourcent: ligne.scorePourcent,
      totalTimeSeconds: ligne.totalTimeSeconds,
      cmi: ligne.cmi,
    );
  }

  Future<void> _ecrireEtatScorm(int coursId, int leconId, EtatScormLocal etat) => db
      .into(db.etatsScorm)
      .insertOnConflictUpdate(
        EtatsScormCompanion.insert(
          leconId: Value(leconId),
          coursId: coursId,
          completionStatus: Value(etat.completionStatus),
          successStatus: Value(etat.successStatus),
          scorePourcent: Value(etat.scorePourcent),
          totalTimeSeconds: Value(etat.totalTimeSeconds),
          cmi: Value(etat.cmi),
          majLe: _horloge(),
        ),
      );

  /// Enregistrement envoyé par le module SCORM (format « commit » de scorm-again).
  Future<EtatScormLocal> etatScorm(int coursId, int leconId, Map<String, dynamic> commit) async {
    late EtatScormLocal resultat;
    await db.transaction(() async {
      final runtime = commit['runtimeData'];
      final nouveau = EtatScormLocal(
        completionStatus: commit['completionStatus'] as String? ?? 'unknown',
        successStatus: commit['successStatus'] as String? ?? 'unknown',
        scorePourcent: scorePourcent((commit['score'] as Map?)?.cast<String, dynamic>()),
        totalTimeSeconds: (commit['totalTimeSeconds'] as num?)?.toInt() ?? 0,
        cmi: runtime is Map ? jsonEncode(runtime) : null,
      );
      final garde = await lireEtatScorm(leconId);
      resultat = fusionnerScorm(garde, nouveau);
      await _ecrireEtatScorm(coursId, leconId, resultat);
      await _majLecon(coursId, leconId, ouverte: true, terminee: resultat.estTermine);
      await _ajouterEvenement('scorm_etat', coursId, leconId, commit);
      if (resultat.estTermine) await _majProgression(coursId);
    });
    _apresEcriture?.call();
    return resultat;
  }

  /// Fusionne l'état du serveur (réponse de synchronisation ou `/sync/etat`) avec l'état local.
  Future<void> appliquerEtatServeur(EtatSynchro etat) async {
    await db.transaction(() async {
      for (final f in etat.formations) {
        for (final l in f.lecons) {
          if (l.terminee) await _majLecon(f.coursId, l.leconId, terminee: true);
          final s = l.scorm;
          if (s != null) {
            final serveur = EtatScormLocal(
              completionStatus: s.completionStatus,
              successStatus: s.successStatus,
              scorePourcent: s.scorePourcent,
              totalTimeSeconds: s.totalTimeSeconds,
              cmi: s.runtimeData == null ? null : jsonEncode(s.runtimeData),
            );
            await _ecrireEtatScorm(f.coursId, l.leconId, fusionnerScorm(await lireEtatScorm(l.leconId), serveur));
          }
        }
        final formation = await (db.select(db.formations)..where((x) => x.id.equals(f.coursId))).getSingleOrNull();
        if (formation != null && f.progression > formation.progression) {
          await (db.update(
            db.formations,
          )..where((x) => x.id.equals(f.coursId))).write(FormationsCompanion(progression: Value(f.progression)));
        }
        await _majProgression(f.coursId);
      }
    });
  }

  /// Remplace la liste des cours par celle du serveur, sans faire reculer la progression locale.
  Future<void> enregistrerFormations(List<Formation> formations) async {
    await db.transaction(() async {
      final anciennes = {for (final f in await db.select(db.formations).get()) f.id: f};
      await db.delete(db.formations).go();
      var ordre = 0;
      for (final f in formations) {
        final a = anciennes[f.id];
        await db
            .into(db.formations)
            .insert(
              FormationsCompanion.insert(
                id: Value(f.id),
                titre: f.titre,
                resume: Value(f.resume),
                cohortes: Value(jsonEncode(f.cohortes)),
                tuteurs: Value(jsonEncode(f.tuteurs)),
                nbLecons: Value(f.nbLecons),
                nbLeconsTerminees: Value(
                  a != null && a.nbLeconsTerminees > f.nbLeconsTerminees ? a.nbLeconsTerminees : f.nbLeconsTerminees,
                ),
                progression: Value(a != null && a.progression > f.progression ? a.progression : f.progression),
                versionServeur: Value(f.version),
                tailleTelechargement: Value(f.tailleTelechargement),
                derniereActivite: Value(f.derniereActivite ?? a?.derniereActivite),
                ordre: Value(ordre++),
              ),
            );
      }
    });
  }
}
