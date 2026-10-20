import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../api/api_client.dart';
import '../db/base.dart';
import 'journal.dart';

/// Bilan d'un passage du moteur.
class BilanSynchro {
  const BilanSynchro({this.envoyes = 0, this.refuses = 0, this.coupure = false, this.erreur});

  final int envoyes;
  final int refuses;

  /// Le réseau a coupé : ce qui n'a pas reçu de réponse reste dans la file.
  final bool coupure;
  final String? erreur;

  bool get complet => !coupure && erreur == null;
}

/// Envoie la file d'événements au serveur, par paquets, dès que le réseau le permet.
///
/// Règles (aucune perte, aucun doublon) :
/// - un événement n'est supprimé du téléphone qu'après la réponse du serveur (`accepte` ou `deja_recu`) ;
/// - si la réponse se perd (coupure), le même événement repart plus tard avec le même identifiant, et le
///   serveur répond `deja_recu` sans rien refaire ;
/// - `refuse` : retiré de la file et noté dans `evenements_refuses` ;
/// - un seul envoi à la fois ; paquets de 10, puis de plus en plus gros (jusqu'à 100) tant que ça passe.
class MoteurSynchro {
  MoteurSynchro({
    required this.db,
    required this.api,
    required this.journal,
    required this.appareilId,
    this.attenteApresEchec = _attenteParDefaut,
    this.planifier = _planifierParDefaut,
  });

  final BaseProfil db;
  final ApiClient api;
  final JournalApprenant journal;
  final String appareilId;

  /// Attente avant de réessayer après `echecs` échecs consécutifs.
  final Duration Function(int echecs) attenteApresEchec;

  /// Programme un nouvel essai (remplacé dans les tests).
  final Timer Function(Duration, void Function()) planifier;

  static const paquetMin = 10;
  static const paquetMax = 100;

  int _taillePaquet = paquetMin;
  int _echecs = 0;
  Timer? _reessai;
  Future<BilanSynchro>? _enCours;
  bool _ferme = false;

  final _envoiEnCours = StreamController<bool>.broadcast();

  /// Vrai pendant un envoi (pour l'indicateur).
  Stream<bool> get envoiEnCours => _envoiEnCours.stream;

  DateTime? derniereReussite;

  static Duration _attenteParDefaut(int echecs) => Duration(seconds: min(5 * pow(2, echecs - 1).toInt(), 900));
  static Timer _planifierParDefaut(Duration d, void Function() f) => Timer(d, f);

  /// Lance un envoi (ou rend celui déjà en cours).
  Future<BilanSynchro> envoyer() {
    if (_ferme) return Future.value(const BilanSynchro(erreur: 'ferme'));
    return _enCours ??= _envoyerTout().whenComplete(() => _enCours = null);
  }

  Future<BilanSynchro> _envoyerTout() async {
    _reessai?.cancel();
    _envoiEnCours.add(true);
    var envoyes = 0;
    var refuses = 0;
    try {
      while (!_ferme) {
        final paquet =
            await (db.select(db.evenements)
                  ..orderBy([(e) => OrderingTerm.asc(e.rang)])
                  ..limit(_taillePaquet))
                .get();
        if (paquet.isEmpty) break;
        final resultat = await api.envoyerEvenements(appareilId, [
          for (final e in paquet)
            {
              'id': e.id,
              'type': e.type,
              'coursId': e.coursId,
              'leconId': e.leconId,
              'survenuLe': e.survenuLe.toUtc().toIso8601String(),
              'donnees': jsonDecode(e.donnees),
            },
        ]);
        final parId = {for (final r in resultat.resultats) r.id: r};
        await db.transaction(() async {
          for (final e in paquet) {
            final r = parId[e.id];
            if (r == null) {
              // Pas de réponse pour celui-là : il repartira au prochain passage.
              await (db.update(
                db.evenements,
              )..where((x) => x.id.equals(e.id))).write(EvenementsCompanion(essais: Value(e.essais + 1)));
            } else if (r.estRecu) {
              await (db.delete(db.evenements)..where((x) => x.id.equals(e.id))).go();
              envoyes++;
            } else {
              await db
                  .into(db.evenementsRefuses)
                  .insertOnConflictUpdate(
                    EvenementsRefusesCompanion.insert(
                      id: e.id,
                      type: e.type,
                      raison: Value(r.raison ?? r.statut),
                      donnees: Value(e.donnees),
                      refuseLe: DateTime.now(),
                    ),
                  );
              await (db.delete(db.evenements)..where((x) => x.id.equals(e.id))).go();
              refuses++;
            }
          }
        });
        await journal.appliquerEtatServeur(resultat.etat);
        if (parId.isEmpty) break; // Réponse vide : on évite de tourner en rond.
        _taillePaquet = min(_taillePaquet * 2, paquetMax);
      }
      _echecs = 0;
      derniereReussite = DateTime.now();
      return BilanSynchro(envoyes: envoyes, refuses: refuses);
    } on ApiException catch (e) {
      _taillePaquet = e.status == 413 ? max(_taillePaquet ~/ 2, 1) : paquetMin;
      _echecs++;
      if (!_ferme) _reessai = planifier(attenteApresEchec(_echecs), () => envoyer());
      return BilanSynchro(
        envoyes: envoyes,
        refuses: refuses,
        coupure: e.estReseau,
        erreur: e.estReseau ? null : e.code,
      );
    } finally {
      if (!_envoiEnCours.isClosed) _envoiEnCours.add(false);
    }
  }

  /// Récupère l'état du serveur (nouveau téléphone, progression faite sur le site) et le fusionne.
  Future<void> recupererEtat({int? coursId}) async {
    final etat = await api.etat(coursId: coursId);
    await journal.appliquerEtatServeur(etat);
  }

  Future<void> fermer() async {
    _ferme = true;
    _reessai?.cancel();
    await _enCours;
    await _envoiEnCours.close();
  }
}
