import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/modeles.dart';
import 'contenus/depot_contenus.dart';
import 'contenus/telechargeur.dart';
import 'db/base.dart';
import 'profils/profils.dart';
import 'reglages/reglages.dart';
import 'services.dart';

/// Services communs du téléphone (remplacés dans `main` et dans les tests).
final servicesProvider = Provider<Services>((ref) => throw UnimplementedError('servicesProvider non fourni'));

/// Message à montrer une fois (profil effacé à distance, session à reprendre).
final messageProvider = NotifierProvider<MessageNotifier, String?>(MessageNotifier.new);

class MessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void afficher(String? m) => state = m;
}

/// Profils du téléphone.
final profilsProvider = FutureProvider<List<Profil>>((ref) => ref.watch(servicesProvider).profils.profils());

/// Le profil déverrouillé (null : aucun).
final profilOuvertProvider = NotifierProvider<ProfilOuvertNotifier, ProfilOuvert?>(ProfilOuvertNotifier.new);

/// Raisons d'un retour à la liste des profils.
enum Fermeture { normale, effacementDistant }

class ProfilOuvertNotifier extends Notifier<ProfilOuvert?> {
  @override
  ProfilOuvert? build() => null;

  /// Vrai si la session doit être reprise par un code e-mail (refusée par le serveur).
  bool sessionAReprendre = false;

  Future<void> ouvrir(Profil profil) async {
    await fermer();
    final services = ref.read(servicesProvider);
    sessionAReprendre = await services.profils.jetonRafraichissement(profil.id) == null;
    final ouvert = await services.ouvrirProfil(
      profil,
      surEffacement: () async {
        state = null;
        ref.invalidate(profilsProvider);
        ref.read(messageProvider.notifier).afficher('profil_efface');
      },
      surSessionFermee: () async {
        sessionAReprendre = true;
        ref.read(messageProvider.notifier).afficher('session_a_reprendre');
      },
    );
    ouvert.activer();
    state = ouvert;
  }

  Future<void> fermer() async {
    final actuel = state;
    state = null;
    await actuel?.fermer();
  }

  Future<void> effacer() async {
    final actuel = state;
    state = null;
    await actuel?.effacer();
    ref.invalidate(profilsProvider);
  }
}

BaseProfil? _db(Ref ref) => ref.watch(profilOuvertProvider)?.db;

final formationsProvider = StreamProvider<List<FormationLocale>>((ref) {
  final db = _db(ref);
  if (db == null) return Stream.value(const []);
  return (db.select(db.formations)..orderBy([(f) => OrderingTerm.asc(f.ordre)])).watch();
});

final formationProvider = StreamProvider.family<FormationLocale?, int>((ref, coursId) {
  final db = _db(ref);
  if (db == null) return Stream.value(null);
  return (db.select(db.formations)..where((f) => f.id.equals(coursId))).watchSingleOrNull();
});

final etatsLeconsProvider = StreamProvider.family<Map<int, EtatLeconLocal>, int>((ref, coursId) {
  final db = _db(ref);
  if (db == null) return Stream.value(const {});
  return (db.select(
    db.etatsLecons,
  )..where((e) => e.coursId.equals(coursId))).watch().map((lignes) => {for (final l in lignes) l.leconId: l});
});

final enAttenteProvider = StreamProvider<int>((ref) {
  final db = _db(ref);
  if (db == null) return Stream.value(0);
  return db.surveillerEnAttente();
});

final envoiEnCoursProvider = StreamProvider<bool>((ref) {
  final moteur = ref.watch(profilOuvertProvider)?.moteur;
  if (moteur == null) return Stream.value(false);
  return moteur.envoiEnCours;
});

final reseauProvider = StreamProvider<TypeReseau>((ref) async* {
  final c = ref.watch(servicesProvider).connectivite;
  yield await c.actuel();
  yield* c.changements;
});

/// Réglages, réémis à chaque changement (données consommées comprises).
final reglagesProvider = StreamProvider<Reglages>((ref) async* {
  final r = ref.watch(servicesProvider).reglages;
  yield r;
  await for (final _ in r.changements) {
    yield r;
  }
});

/// Leçons d'un cours (manifest local, sinon demandé au serveur).
final manifestProvider = FutureProvider.family<Manifest?, int>((ref, coursId) async {
  final ouvert = ref.watch(profilOuvertProvider);
  if (ouvert == null) return null;
  final reseau = await ref.watch(servicesProvider).connectivite.actuel();
  return ouvert.manifest(coursId, reseau: reseau != TypeReseau.aucun);
});

/// Place libre sur le téléphone (octets), ou null si inconnue.
final placeLibreProvider = FutureProvider<int?>((ref) async => ref.watch(servicesProvider).placeLibre?.call());

/// État d'un téléchargement de cours, vu par l'écran.
class EtatTelechargement {
  const EtatTelechargement({this.enCours = false, this.progres, this.erreur, this.fini = false});
  final bool enCours;
  final Progres? progres;

  /// `wifi`, `reseau`, `place:<besoin>:<libre>`, `fichier`, `inconnue`.
  final String? erreur;
  final bool fini;
}

final telechargementsProvider = NotifierProvider<TelechargementsNotifier, Map<int, EtatTelechargement>>(
  TelechargementsNotifier.new,
);

/// Téléchargements en cours, indépendants des écrans (on peut quitter l'écran du cours).
class TelechargementsNotifier extends Notifier<Map<int, EtatTelechargement>> {
  final _annulations = <int, CancelToken>{};

  @override
  Map<int, EtatTelechargement> build() => const {};

  void _maj(int coursId, EtatTelechargement e) => state = {...state, coursId: e};

  Future<void> telecharger(int coursId) async {
    final ouvert = ref.read(profilOuvertProvider);
    if (ouvert == null || (state[coursId]?.enCours ?? false)) return;
    final services = ref.read(servicesProvider);
    final reseau = await services.connectivite.actuel();
    if (reseau == TypeReseau.aucun) return _maj(coursId, const EtatTelechargement(erreur: 'reseau'));
    if (reseau == TypeReseau.mobile && services.reglages.wifiSeulement) {
      return _maj(coursId, const EtatTelechargement(erreur: 'wifi'));
    }
    final annulation = CancelToken();
    _annulations[coursId] = annulation;
    _maj(coursId, const EtatTelechargement(enCours: true));
    try {
      final local = services.depot.manifestLocal(coursId);
      final frais = await ouvert.api.manifest(coursId, versionLocale: local?.version);
      final manifest = frais ?? local;
      if (manifest == null) throw StateError('manifest');
      await ouvert.telechargeur.telechargerCours(
        manifest,
        annulation: annulation,
        onProgres: (p) => _maj(coursId, EtatTelechargement(enCours: true, progres: p)),
      );
      _maj(coursId, const EtatTelechargement(fini: true));
    } on PlaceInsuffisante catch (e) {
      _maj(coursId, EtatTelechargement(erreur: 'place:${e.necessaire}:${e.libre}'));
    } on EmpreinteIncorrecte {
      _maj(coursId, const EtatTelechargement(erreur: 'fichier'));
    } on TelechargementInterrompu {
      _maj(coursId, EtatTelechargement(erreur: annulation.isCancelled ? null : 'reseau'));
    } catch (_) {
      _maj(coursId, const EtatTelechargement(erreur: 'inconnue'));
    } finally {
      _annulations.remove(coursId);
      ref.invalidate(manifestProvider(coursId));
      ref.invalidate(placeLibreProvider);
    }
  }

  void annuler(int coursId) => _annulations[coursId]?.cancel();

  Future<void> supprimer(int coursId) async {
    await ref.read(servicesProvider).depot.supprimerCours(coursId);
    _maj(coursId, const EtatTelechargement());
    ref.invalidate(manifestProvider(coursId));
    ref.invalidate(placeLibreProvider);
  }
}

/// État hors ligne d'un cours (recalculé quand un téléchargement change).
final etatHorsLigneProvider = Provider.family<EtatHorsLigne, (int, String)>((ref, cle) {
  ref.watch(telechargementsProvider.select((t) => t[cle.$1]));
  return ref.watch(servicesProvider).depot.etat(cle.$1, versionServeur: cle.$2);
});

/// Taille lisible : « 18,4 Mo ».
String tailleLisible(int octets) {
  if (octets < 1024) return '$octets o';
  if (octets < 1024 * 1024) return '${(octets / 1024).round()} Ko';
  if (octets < 1024 * 1024 * 1024) return '${(octets / 1024 / 1024).toStringAsFixed(1).replaceAll('.', ',')} Mo';
  return '${(octets / 1024 / 1024 / 1024).toStringAsFixed(1).replaceAll('.', ',')} Go';
}
