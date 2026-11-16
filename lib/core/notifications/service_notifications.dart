import 'dart:async';
import 'dart:convert';

import '../api/api_client.dart';
import '../api/modeles.dart';
import '../db/base.dart';
import '../push/service_push.dart';

/// Ce que les écrans voient des notifications d'un profil (une nouvelle valeur à chaque changement).
class InstantaneNotifications {
  const InstantaneNotifications({
    this.boite = const BoiteDeReception(),
    this.preferences,
    this.pushDisponible = false,
    this.pushProposee = true,
    this.envoiEnAttente = false,
  });

  final BoiteDeReception boite;

  /// Null tant qu'elles n'ont jamais été lues (il faut du réseau une fois).
  final PreferencesNotifications? preferences;

  /// Firebase est configuré dans cette version de l'appli.
  final bool pushDisponible;

  /// La question « Recevoir les rappels sur ce téléphone ? » a déjà été posée à ce profil.
  final bool pushProposee;

  /// Des changements (messages lus, préférences) attendent le réseau.
  final bool envoiEnAttente;

  int get nonLues => boite.nonLues;
  bool get proposerPush => pushDisponible && !pushProposee;
}

/// Boîte de réception et préférences de notification d'un profil ouvert, gardées dans sa base chiffrée.
///
/// Comme le profil : les changements s'appliquent tout de suite sur le téléphone, puis partent dès que possible
/// (envois sans risque à rejouer).
class ServiceNotifications {
  ServiceNotifications({
    required this.db,
    required this.api,
    required this.push,
    required this.plateforme,
    required this.langue,
  });

  final BaseProfil db;
  final ApiClient api;
  final ServicePush push;
  final String plateforme;
  final String Function() langue;

  static const _cleBoite = 'notifications:boite';
  static const _clePreferences = 'notifications:preferences';
  static const _cleLuesEnAttente = 'notifications:lues_en_attente';
  static const _clePrefsEnAttente = 'notifications:preferences_en_attente';
  static const _cleJeton = 'push:jeton';
  static const _cleProposee = 'push:proposee';

  BoiteDeReception _boite = const BoiteDeReception();
  PreferencesNotifications? _preferences;
  Set<int> _luesEnAttente = {};
  List<PreferenceNotification> _prefsEnAttente = [];
  bool _proposee = false;
  bool _ferme = false;

  final _flux = StreamController<InstantaneNotifications>.broadcast();
  late InstantaneNotifications _actuel = _instantane();
  InstantaneNotifications get actuel => _actuel;
  Stream<InstantaneNotifications> get changements => _flux.stream;

  StreamSubscription<String>? _jetons;
  StreamSubscription<MessagePush>? _recues;

  Future<void> charger() async {
    Map<String, dynamic>? objet(String? brut) =>
        brut == null || brut.isEmpty ? null : (jsonDecode(brut) as Map).cast<String, dynamic>();
    final boite = objet(await db.lireMeta(_cleBoite));
    if (boite != null) _boite = BoiteDeReception.fromJson(boite);
    final prefs = objet(await db.lireMeta(_clePreferences));
    if (prefs != null) _preferences = PreferencesNotifications.fromJson(prefs);
    final lues = await db.lireMeta(_cleLuesEnAttente);
    if (lues != null && lues.isNotEmpty) {
      _luesEnAttente = {for (final i in jsonDecode(lues) as List) (i as num).toInt()};
    }
    final attente = await db.lireMeta(_clePrefsEnAttente);
    if (attente != null && attente.isNotEmpty) {
      _prefsEnAttente = [
        for (final p in jsonDecode(attente) as List)
          PreferenceNotification.fromJson((p as Map).cast<String, dynamic>()),
      ];
    }
    _proposee = await db.lireMeta(_cleProposee) == '1';
    _publier();
  }

  /// Écoute Firebase tant que le profil est ouvert : nouveau jeton, message reçu appli ouverte.
  void activer() {
    _jetons = push.nouveauxJetons.listen((j) => unawaited(_tour(() => _envoyerJeton(j))));
    _recues = push.recues.listen((_) => unawaited(rafraichir()));
  }

  InstantaneNotifications _instantane() {
    final lues = _luesEnAttente;
    final notifications = [for (final n in _boite.notifications) lues.contains(n.id) && !n.lue ? n.commeLue() : n];
    final nonLues = (_boite.nonLues - _boite.notifications.where((n) => !n.lue && lues.contains(n.id)).length).clamp(
      0,
      1 << 30,
    );
    var prefs = _preferences;
    if (prefs != null && _prefsEnAttente.isNotEmpty) prefs = prefs.avec(_prefsEnAttente);
    return InstantaneNotifications(
      boite: BoiteDeReception(notifications: notifications, nonLues: nonLues),
      preferences: prefs,
      pushDisponible: push.disponible,
      pushProposee: _proposee,
      envoiEnAttente: _luesEnAttente.isNotEmpty || _prefsEnAttente.isNotEmpty,
    );
  }

  void _publier() {
    if (_ferme) return;
    _actuel = _instantane();
    _flux.add(_actuel);
  }

  Future<void> _file = Future.value();

  Future<T> _tour<T>(Future<T> Function() f) {
    final suite = _file.then((_) => f());
    _file = suite.then((_) {}, onError: (_) {});
    return suite;
  }

  static bool _aRejouer(ApiException e) => e.estReseau || e.status == null || e.status! >= 500 || e.status == 401;

  /// Envoie ce qui attend, enregistre le jeton du téléphone, relit la boîte et les préférences. Silencieux hors ligne.
  Future<void> rafraichir() => _tour(() async {
    if (_ferme) return;
    try {
      await _envoyerAttente();
      if (push.disponible) {
        final j = await push.jeton();
        if (j != null) await _envoyerJeton(j);
      }
      final boite = await api.listerNotifications(langue: langue());
      if (_ferme) return;
      _boite = boite;
      await db.ecrireMeta(_cleBoite, jsonEncode(boite.toJson()));
      _publier();
      final prefs = await api.lirePreferencesNotifications(langue: langue());
      if (_ferme) return;
      _preferences = prefs;
      await db.ecrireMeta(_clePreferences, jsonEncode(prefs.toJson()));
      _publier();
    } on ApiException {
      // hors ligne : on garde la copie du téléphone
    }
  });

  Future<void> _envoyerJeton(String jeton) async {
    if (_ferme || await db.lireMeta(_cleJeton) == jeton) return;
    try {
      await api.enregistrerJetonPush(jeton, plateforme: plateforme);
      await db.ecrireMeta(_cleJeton, jeton);
    } on ApiException {
      // réessayé au prochain passage réseau
    }
  }

  Future<void> _envoyerAttente() async {
    if (_luesEnAttente.isNotEmpty) {
      final ids = _luesEnAttente.toList();
      try {
        for (var i = 0; i < ids.length; i += 100) {
          await api.marquerNotificationsLues(ids.sublist(i, i + 100 > ids.length ? ids.length : i + 100));
        }
      } on ApiException catch (e) {
        if (_aRejouer(e)) rethrow;
      }
      // Copie du téléphone à jour sans attendre la prochaine lecture de la boîte.
      final avant = _boite;
      _boite = BoiteDeReception(
        notifications: [for (final n in avant.notifications) ids.contains(n.id) ? n.commeLue() : n],
        nonLues: (avant.nonLues - avant.notifications.where((n) => !n.lue && ids.contains(n.id)).length).clamp(
          0,
          1 << 30,
        ),
      );
      await db.ecrireMeta(_cleBoite, jsonEncode(_boite.toJson()));
      _luesEnAttente.removeAll(ids);
      await db.ecrireMeta(_cleLuesEnAttente, _luesEnAttente.isEmpty ? '' : jsonEncode(_luesEnAttente.toList()));
    }
    if (_prefsEnAttente.isNotEmpty) {
      final envoi = [..._prefsEnAttente];
      try {
        final p = await api.modifierPreferencesNotifications(envoi, langue: langue());
        _preferences = p;
        await db.ecrireMeta(_clePreferences, jsonEncode(p.toJson()));
      } on ApiException catch (e) {
        if (_aRejouer(e)) rethrow;
        // Refusée (canal indisponible) : la rejouer ne servirait à rien.
      }
      _prefsEnAttente.removeWhere(envoi.contains);
      await db.ecrireMeta(
        _clePrefsEnAttente,
        _prefsEnAttente.isEmpty ? '' : jsonEncode([for (final p in _prefsEnAttente) p.toJson()]),
      );
    }
    _publier();
  }

  /// Messages lus : visibles tout de suite, envoyés dès que possible.
  Future<void> marquerLues(Iterable<int> ids) async {
    final nouveaux = {
      for (final n in _boite.notifications)
        if (ids.contains(n.id) && !n.lue && !_luesEnAttente.contains(n.id)) n.id,
    };
    if (nouveaux.isEmpty || _ferme) return;
    _luesEnAttente.addAll(nouveaux);
    await db.ecrireMeta(_cleLuesEnAttente, jsonEncode(_luesEnAttente.toList()));
    _publier();
    unawaited(_tour(_envoyerSilencieux));
  }

  Future<void> _envoyerSilencieux() async {
    try {
      await _envoyerAttente();
    } on ApiException {
      // réessayé au prochain passage réseau
    }
  }

  /// Change une préférence (canal × sujet) : visible tout de suite, envoyée dès que possible.
  Future<void> modifierPreference(String canal, String sujet, bool actif) async {
    if (_ferme) return;
    final p = PreferenceNotification(canal: canal, sujet: sujet, actif: actif);
    _prefsEnAttente
      ..removeWhere((x) => x.canal == canal && x.sujet == sujet)
      ..add(p);
    await db.ecrireMeta(_clePrefsEnAttente, jsonEncode([for (final p in _prefsEnAttente) p.toJson()]));
    _publier();
    unawaited(_tour(_envoyerSilencieux));
  }

  /// Réponse à « Recevoir les rappels de tes cours sur ce téléphone ? ». Rend vrai si les rappels sont activés.
  Future<bool> repondrePropositionPush(bool oui) async {
    _proposee = true;
    await db.ecrireMeta(_cleProposee, '1');
    _publier();
    if (!oui) return false;
    if (!await push.demanderPermission()) return false;
    await modifierPreference(CanalNotification.push, SujetNotification.cours, true);
    unawaited(rafraichir());
    return true;
  }

  /// Plus de notification sur ce téléphone (déconnexion du dernier profil).
  Future<void> retirerJeton() async {
    try {
      await api.retirerJetonPush();
      await db.ecrireMeta(_cleJeton, '');
    } on ApiException {
      // Hors ligne : le serveur retire de lui-même le jeton quand plus aucun profil n'est connecté.
    }
  }

  Future<void> fermer() async {
    _ferme = true;
    await _jetons?.cancel();
    await _recues?.cancel();
    await _flux.close();
  }
}
