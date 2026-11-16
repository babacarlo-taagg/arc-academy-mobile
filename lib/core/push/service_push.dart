import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Données d'une notification reçue ou touchée (`notificationId`, `apprenantId`, `neutre`), toutes en texte.
class MessagePush {
  const MessagePush(this.donnees);
  final Map<String, String> donnees;

  int? get apprenantId => int.tryParse(donnees['apprenantId'] ?? '');
  int? get notificationId => int.tryParse(donnees['notificationId'] ?? '');
}

/// Notifications sur le téléphone (Firebase Cloud Messaging), abstraites pour les tests.
///
/// Sans configuration Firebase (valeurs `--dart-define` absentes), le service est « absent » : l'appli marche
/// pareil, la boîte de réception se remplit à chaque passage réseau.
abstract class ServicePush {
  /// Faux si Firebase n'est pas configuré dans cette version de l'appli.
  bool get disponible;

  /// Jeton du téléphone, ou null (pas encore donné, ou pas de service).
  Future<String?> jeton();

  /// Nouveaux jetons donnés par Firebase (le jeton change de temps en temps).
  Stream<String> get nouveauxJetons;

  /// Demande au système l'autorisation d'afficher des notifications. Vrai si elle est accordée.
  Future<bool> demanderPermission();

  /// Notifications reçues pendant que l'appli est ouverte.
  Stream<MessagePush> get recues;

  /// Notifications touchées (appli en fond, ou lancée par la notification).
  Stream<MessagePush> get touchees;

  /// Notification qui a lancé l'appli, lue une seule fois.
  Future<MessagePush?> messageDeDepart();
}

/// Pas de Firebase : rien n'arrive, rien ne part.
class ServicePushAbsent implements ServicePush {
  const ServicePushAbsent();
  @override
  bool get disponible => false;
  @override
  Future<String?> jeton() async => null;
  @override
  Stream<String> get nouveauxJetons => const Stream.empty();
  @override
  Future<bool> demanderPermission() async => false;
  @override
  Stream<MessagePush> get recues => const Stream.empty();
  @override
  Stream<MessagePush> get touchees => const Stream.empty();
  @override
  Future<MessagePush?> messageDeDepart() async => null;
}

/// Réglages Firebase, passés à la construction de l'appli (jamais écrits dans le dépôt) :
///   --dart-define=FIREBASE_PROJECT_ID=… --dart-define=FIREBASE_SENDER_ID=…
///   --dart-define=FIREBASE_API_KEY_ANDROID=… --dart-define=FIREBASE_APP_ID_ANDROID=…
///   --dart-define=FIREBASE_API_KEY_IOS=… --dart-define=FIREBASE_APP_ID_IOS=…
FirebaseOptions? optionsFirebase({TargetPlatform? plateforme}) {
  const projet = String.fromEnvironment('FIREBASE_PROJECT_ID');
  const expediteur = String.fromEnvironment('FIREBASE_SENDER_ID');
  final ios = (plateforme ?? defaultTargetPlatform) == TargetPlatform.iOS;
  final cle = ios
      ? const String.fromEnvironment('FIREBASE_API_KEY_IOS')
      : const String.fromEnvironment('FIREBASE_API_KEY_ANDROID');
  final appli = ios
      ? const String.fromEnvironment('FIREBASE_APP_ID_IOS')
      : const String.fromEnvironment('FIREBASE_APP_ID_ANDROID');
  if (projet.isEmpty || expediteur.isEmpty || cle.isEmpty || appli.isEmpty) return null;
  return FirebaseOptions(
    apiKey: cle,
    appId: appli,
    messagingSenderId: expediteur,
    projectId: projet,
    iosBundleId: ios ? 'org.africaresourcecentre.academy' : null,
  );
}

MessagePush _message(RemoteMessage m) => MessagePush({for (final e in m.data.entries) e.key: '${e.value}'});

/// Firebase Cloud Messaging (Android et iOS).
class ServicePushFirebase implements ServicePush {
  ServicePushFirebase._(this._fcm);

  final FirebaseMessaging _fcm;

  /// Démarre Firebase si l'appli a été construite avec ses réglages ; sinon (ou en cas d'échec) : service absent.
  static Future<ServicePush> demarrer() async {
    final options = optionsFirebase();
    if (options == null || kIsWeb) return const ServicePushAbsent();
    try {
      await Firebase.initializeApp(options: options);
      return ServicePushFirebase._(FirebaseMessaging.instance);
    } catch (e) {
      debugPrint('Notifications désactivées : $e');
      return const ServicePushAbsent();
    }
  }

  @override
  bool get disponible => true;

  @override
  Future<String?> jeton() async {
    try {
      // Jeton d'enregistrement classique (envoi `message.token` de l'API FCM v1 côté serveur), encore pris en
      // charge par Firebase ; l'envoi direct par identifiant d'installation (register/onRegistered) viendra plus tard.
      // ignore: deprecated_member_use
      return await _fcm.getToken();
    } catch (_) {
      // Pas de Google Play sur le téléphone, ou iOS sans autorisation : pas de jeton.
      return null;
    }
  }

  @override
  // ignore: deprecated_member_use
  Stream<String> get nouveauxJetons => _fcm.onTokenRefresh;

  @override
  Future<bool> demanderPermission() async {
    try {
      final r = await _fcm.requestPermission();
      return r.authorizationStatus == AuthorizationStatus.authorized ||
          r.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  @override
  Stream<MessagePush> get recues => FirebaseMessaging.onMessage.map(_message);

  @override
  Stream<MessagePush> get touchees => FirebaseMessaging.onMessageOpenedApp.map(_message);

  @override
  Future<MessagePush?> messageDeDepart() async {
    try {
      final m = await _fcm.getInitialMessage();
      return m == null ? null : _message(m);
    } catch (_) {
      return null;
    }
  }
}
