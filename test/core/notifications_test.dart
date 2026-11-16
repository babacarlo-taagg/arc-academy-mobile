import 'dart:io';

import 'package:arc_academy/core/api/api_client.dart';
import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/harnais.dart';
import '../outils/jetons_memoire.dart';

/// Notifications (contrat 0.4.0) : client, modèles, boîte de réception et préférences hors ligne.
void main() {
  late FauxServeur serveur;
  late Directory dossier;

  setUp(() async {
    serveur = FauxServeur();
    await serveur.demarrer();
    dossier = Directory.systemTemp.createTempSync('arc_notifications_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  Future<ProfilOuvert> ouvrir(Services services) async {
    final p = await services.profils.ouvrirSession(sessionDeTest(42, 'Awa Diop'));
    final ouvert = await services.ouvrirProfil(p, enArrierePlan: false);
    await ouvert.notifications.charger();
    return ouvert;
  }

  test('modèles : cible ouverte dans l’appli (cours, leçon) ou dans le navigateur', () {
    final b = BoiteDeReception.fromJson({
      'nonLues': 1,
      'notifications': [
        FauxServeur.message(1, cible: {'type': 'cours', 'id': 12}),
        FauxServeur.message(2, lue: true, cible: {'type': 'lecon', 'id': 345, 'coursId': 12}),
        FauxServeur.message(3, cible: {'type': 'certificat', 'id': 9, 'url': 'https://example.org/c/9'}),
        FauxServeur.message(4),
      ],
    });
    expect(b.nonLues, 1);
    expect([for (final n in b.notifications) n.cible?.route], ['/cours/12', '/lecon/12/345', null, null]);
    expect(b.notifications[2].cible!.url, 'https://example.org/c/9');
    expect(b.notifications[0].envoyeeLe, DateTime.utc(2026, 11, 20, 9));
    expect(BoiteDeReception.fromJson(b.toJson()).notifications[1].lue, isTrue);
  });

  test('client : jeton, boîte, messages lus, préférences', () async {
    final api = ApiClient(baseUrl: serveur.url, jetons: JetonsMemoire(), gzip: false);
    serveur.messages = [FauxServeur.message(41), FauxServeur.message(42)];
    await api.enregistrerJetonPush('fcm-1', plateforme: 'android');
    expect(serveur.jetonsPush.single, {'jeton': 'fcm-1', 'plateforme': 'android'});
    await api.retirerJetonPush();
    expect(serveur.retraitsJetonPush, 1);

    final boite = await api.listerNotifications();
    expect(boite.nonLues, 2);
    await api.marquerNotificationsLues([41]);
    expect((await api.listerNotifications()).nonLues, 1);

    final prefs = await api.lirePreferencesNotifications(langue: 'en');
    expect(prefs.sujets.first.libelle, 'Reminders about my courses');
    expect(prefs.actif('email', 'cours'), isTrue);
    expect(prefs.canaux.firstWhere((c) => c.cle == 'whatsapp').disponible, isFalse);
    final apres = await api.modifierPreferencesNotifications([
      const PreferenceNotification(canal: 'push', sujet: 'cours', actif: true),
    ]);
    expect(apres.actif('push', 'cours'), isTrue);
    await expectLater(
      api.modifierPreferencesNotifications([
        const PreferenceNotification(canal: 'whatsapp', sujet: 'cours', actif: true),
      ]),
      throwsA(isA<ApiException>().having((e) => e.extra['champs'], 'champs', {'whatsapp': 'indisponible'})),
    );
  });

  test('hors ligne : messages lus et préférences gardés sur le téléphone, envoyés au retour du réseau', () async {
    final push = FauxPush();
    final services = servicesDeTest(dossier, serveur.url, push: push);
    serveur.messages = [FauxServeur.message(41), FauxServeur.message(42)];
    var ouvert = await ouvrir(services);
    await ouvert.notifications.rafraichir();
    expect(ouvert.notifications.actuel.nonLues, 2);
    expect(serveur.jetonsPush.single, {'jeton': 'fcm-jeton-1', 'plateforme': 'android'});

    serveur.notificationsInjoignables = true;
    await ouvert.notifications.marquerLues([41]);
    await ouvert.notifications.modifierPreference('push', 'cours', true);
    await ouvert.notifications.rafraichir();
    expect(ouvert.notifications.actuel.nonLues, 1, reason: 'lu tout de suite sur le téléphone');
    expect(ouvert.notifications.actuel.preferences!.actif('push', 'cours'), isTrue);
    expect(ouvert.notifications.actuel.envoiEnAttente, isTrue);
    expect(serveur.idsLus, isEmpty);
    final profilId = ouvert.profil.id;
    await ouvert.fermer();

    // L'appli est rouverte plus tard, toujours hors ligne : rien n'est perdu.
    ouvert = await services.ouvrirProfil((await services.profils.profil(profilId))!, enArrierePlan: false);
    await ouvert.notifications.charger();
    expect(ouvert.notifications.actuel.nonLues, 1);
    expect(ouvert.notifications.actuel.envoiEnAttente, isTrue);

    serveur.notificationsInjoignables = false;
    await ouvert.notifications.rafraichir();
    expect(serveur.idsLus, [
      [41],
    ]);
    expect(serveur.modificationsPreferences.single.single, {'canal': 'push', 'sujet': 'cours', 'actif': true});
    expect(ouvert.notifications.actuel.envoiEnAttente, isFalse);
    expect(ouvert.notifications.actuel.nonLues, 1);
    expect(serveur.jetonsPush, hasLength(1), reason: 'le même jeton n’est pas renvoyé');

    // Firebase renouvelle le jeton : il part tout de suite.
    ouvert.notifications.activer();
    push.nouveauJeton('fcm-jeton-2');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(serveur.jetonsPush.last['jeton'], 'fcm-jeton-2');
    await ouvert.fermer();
  });

  test('proposition « rappels sur ce téléphone » : posée une fois, permission puis rappels activés', () async {
    final push = FauxPush(permission: false);
    final services = servicesDeTest(dossier, serveur.url, push: push);
    final ouvert = await ouvrir(services);
    await ouvert.notifications.rafraichir();
    expect(ouvert.notifications.actuel.proposerPush, isTrue);
    expect(await ouvert.notifications.repondrePropositionPush(true), isFalse, reason: 'permission refusée');
    expect(ouvert.notifications.actuel.proposerPush, isFalse);
    expect(serveur.modificationsPreferences, isEmpty);

    push.permission = true;
    expect(await ouvert.notifications.repondrePropositionPush(true), isTrue);
    await ouvert.notifications.rafraichir();
    expect(serveur.preferences['push:cours'], isTrue);
    await ouvert.fermer();

    // Sans Firebase dans cette version : jamais proposé, aucun jeton.
    final sans = servicesDeTest(Directory('${dossier.path}/sans')..createSync(), serveur.url);
    final autre = await ouvrir(sans);
    await autre.notifications.rafraichir();
    expect(autre.notifications.actuel.proposerPush, isFalse);
    await autre.fermer();
  });
}
