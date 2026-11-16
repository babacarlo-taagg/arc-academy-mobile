import 'dart:convert';
import 'dart:io';

import 'package:arc_academy/app.dart';
import 'package:arc_academy/core/providers.dart';
import 'package:arc_academy/core/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/harnais.dart';

/// Notifications : boîte de réception, préférences, proposition des rappels, notification touchée.
void main() {
  late FauxServeur serveur;
  late Directory dossier;
  final article = utf8.encode('<html><body><h1>Notifier</h1></body></html>');

  setUp(() async {
    preparerReseauReel();
    serveur = FauxServeur();
    await serveur.demarrer();
    serveur.ajouterFichier(article);
    serveur.formations = [
      {
        'id': 12,
        'titre': 'Pharmacovigilance pour les points focaux',
        'cohortes': [],
        'tuteurs': [],
        'nbLecons': 1,
        'nbLeconsTerminees': 0,
        'progression': 0,
        'version': 'v1',
        'tailleTelechargement': article.length,
      },
    ];
    serveur.manifestes[12] = {
      'coursId': 12,
      'version': 'v1',
      'titre': 'Pharmacovigilance pour les points focaux',
      'tailleTotale': article.length,
      'lecons': [
        {
          'id': 1,
          'titre': 'Notifier',
          'type': 'article',
          'ordre': 1,
          'horsLigne': true,
          'terminee': false,
          'entree': 'index.html',
          'fichiers': [
            {
              'chemin': 'index.html',
              'empreinte': FauxServeur.empreinte(article),
              'taille': article.length,
              'typeMime': 'text/html',
            },
          ],
        },
      ],
    };
    dossier = Directory.systemTemp.createTempSync('arc_notifs_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  /// Lance l'appli avec les profils donnés (id → nom) et ouvre le premier par son code secret.
  Future<(ProviderContainer, Services)> ouvrir(
    WidgetTester tester,
    FauxPush push, {
    Map<int, String> profils = const {42: 'Awa Diop'},
  }) async {
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url, push: push);
    await tester.runAsync(() async {
      for (final e in profils.entries) {
        final p = await services.profils.ouvrirSession(sessionDeTest(e.key, e.value));
        await services.profils.definirPin(p.id, '1234');
      }
    });
    final conteneur = await lancerAppli(tester, services);
    await tester.tap(find.byKey(Key('profil_p${profils.keys.first}')));
    await attendre(tester);
    await validerPin(tester);
    return (conteneur, services);
  }

  Finder badge(String texte) =>
      find.descendant(of: find.byKey(const Key('badge_messages')), matching: find.text(texte));

  testWidgets('boîte de réception : badge, message lu, ouverture du cours', (tester) async {
    serveur.messages = [
      FauxServeur.message(41, cible: {'type': 'cours', 'id': 12}),
      FauxServeur.message(42),
    ];
    final (conteneur, _) = await ouvrir(tester, FauxPush());
    expect(find.text('Mes formations'), findsOneWidget);
    expect(badge('2'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bouton_messages')));
    await attendre(tester);
    expect(find.text('Mes messages'), findsOneWidget);
    expect(find.byKey(const Key('message_41')), findsOneWidget);
    expect(find.byKey(const Key('message_42')), findsOneWidget);

    await tester.tap(find.byKey(const Key('message_41')));
    await attendre(tester, fois: 8);
    expect(serveur.idsLus.expand((l) => l), [41]);
    expect(find.text('Pharmacovigilance pour les points focaux'), findsWidgets, reason: 'le cours est ouvert');

    conteneur.read(routeurProvider).go('/formations');
    await attendre(tester);
    expect(badge('1'), findsOneWidget);
    await terminer(tester, conteneur);
  });

  testWidgets('proposition des rappels sur le téléphone : oui → permission, rappels activés, jeton envoyé', (
    tester,
  ) async {
    final push = FauxPush();
    final (conteneur, _) = await ouvrir(tester, push);
    expect(serveur.jetonsPush.single, {'jeton': 'fcm-jeton-1', 'plateforme': 'android'});
    expect(find.text('Recevoir les rappels de tes cours sur ce téléphone ?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bouton_push_oui')));
    await attendre(tester, fois: 8);
    expect(push.permissionsDemandees, 1);
    expect(serveur.preferences['push:cours'], isTrue);
    expect(find.byKey(const Key('carte_proposition_push')), findsNothing);
    expect(find.text("C'est noté : tu recevras tes rappels ici."), findsOneWidget);
    await terminer(tester, conteneur);
  });

  testWidgets('proposition refusée : plus jamais reposée, rien n’est envoyé', (tester) async {
    final push = FauxPush();
    final (conteneur, services) = await ouvrir(tester, push);
    await tester.tap(find.byKey(const Key('bouton_push_non')));
    await attendre(tester, fois: 4);
    expect(find.byKey(const Key('carte_proposition_push')), findsNothing);
    expect(push.permissionsDemandees, 0);
    expect(serveur.modificationsPreferences, isEmpty);

    // Le profil est rouvert plus tard : la question n'est pas reposée.
    await tester.runAsync(() => conteneur.read(profilOuvertProvider.notifier).fermer());
    conteneur.read(routeurProvider).go('/profils');
    await attendre(tester);
    await tester.tap(find.byKey(const Key('profil_p42')));
    await attendre(tester);
    await validerPin(tester);
    expect(find.text('Mes formations'), findsOneWidget);
    expect(find.byKey(const Key('carte_proposition_push')), findsNothing);
    await terminer(tester, conteneur);
  });

  testWidgets('Réglages › Notifications : choix par sujet et canal, WhatsApp indisponible, permission refusée', (
    tester,
  ) async {
    final push = FauxPush(permission: false);
    final (conteneur, _) = await ouvrir(tester, push);
    await tester.tap(find.byKey(const Key('bouton_push_non')));
    await attendre(tester, fois: 2);
    conteneur.read(routeurProvider).go('/reglages');
    await attendre(tester);
    await tester.tap(find.byKey(const Key('lien_notifications')));
    await attendre(tester);
    expect(find.text('Rappels de mes cours'), findsOneWidget);
    final whatsapp = tester.widget<SwitchListTile>(find.byKey(const Key('pref_whatsapp_cours')));
    expect(whatsapp.onChanged, isNull, reason: 'pas de numéro ni d’accord WhatsApp');
    expect(find.text('Pour WhatsApp, ajoute ton numéro et ton accord dans Mon profil.'), findsWidgets);
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('pref_email_cours'))).value, isTrue);

    // Couper les e-mails de rappel : enregistré tout de suite.
    await tester.tap(find.byKey(const Key('pref_email_cours')));
    await attendre(tester, fois: 6);
    expect(serveur.modificationsPreferences.single.single, {'canal': 'email', 'sujet': 'cours', 'actif': false});
    expect(tester.widget<SwitchListTile>(find.byKey(const Key('pref_email_cours'))).value, isFalse);

    // Notification sur le téléphone sans l'autorisation du système : explication, rien n'est envoyé.
    await tester.tap(find.byKey(const Key('pref_push_cours')));
    await attendre(tester, fois: 4);
    expect(push.permissionsDemandees, 1);
    expect(find.text("Autorise les notifications d'ARC Academy dans les réglages du téléphone."), findsOneWidget);
    expect(serveur.modificationsPreferences, hasLength(1));
    await terminer(tester, conteneur);
  });

  testWidgets('notification touchée sur un téléphone partagé : code secret du bon profil, puis ses messages', (
    tester,
  ) async {
    final push = FauxPush();
    serveur.messages = [FauxServeur.message(7)];
    final (conteneur, _) = await ouvrir(tester, push, profils: {42: 'Awa Diop', 43: 'Moussa Ba'});
    expect(find.text('Mes formations'), findsOneWidget);

    // Le message est pour Moussa : le profil d'Awa se ferme, rien n'apparaît avant le code de Moussa.
    push.toucher({'notificationId': '7', 'apprenantId': '43', 'neutre': '1'});
    await attendre(tester);
    expect(conteneur.read(profilOuvertProvider), isNull);
    expect(find.text('Bonjour Moussa'), findsOneWidget);
    expect(find.byKey(const Key('message_7')), findsNothing);

    await validerPin(tester);
    expect(conteneur.read(profilOuvertProvider)!.profil.apprenantId, 43);
    expect(find.text('Mes messages'), findsOneWidget);
    expect(find.byKey(const Key('message_7')), findsOneWidget);

    // Touchée pour le profil déjà ouvert : directement ses messages.
    conteneur.read(routeurProvider).go('/formations');
    await attendre(tester);
    push.toucher({'notificationId': '7', 'apprenantId': '43', 'neutre': '0'});
    await attendre(tester);
    expect(find.text('Mes messages'), findsOneWidget);
    await terminer(tester, conteneur);
  });

  testWidgets('retirer le dernier profil du téléphone : plus de notification ici', (tester) async {
    final (conteneur, _) = await ouvrir(tester, FauxPush());
    conteneur.read(routeurProvider).go('/reglages');
    await attendre(tester);
    final bouton = find.text('Retirer mon profil de ce téléphone');
    await tester.scrollUntilVisible(bouton, 300, scrollable: find.byType(Scrollable).last);
    await tester.ensureVisible(bouton);
    await tester.pumpAndSettle();
    await tester.tap(bouton);
    await attendre(tester, fois: 2);
    await tester.tap(find.text('Confirmer'));
    await attendre(tester, fois: 15);
    expect(serveur.retraitsJetonPush, 1);
    expect(find.byKey(const Key('champ_email')), findsOneWidget);
    await terminer(tester, conteneur);
  });
}

/// Tape le code secret 1234 et le valide.
Future<void> validerPin(WidgetTester tester) async {
  await taperPin(tester, '1234');
  await tester.ensureVisible(find.byIcon(Icons.check_rounded));
  await tester.tap(find.byIcon(Icons.check_rounded));
  await attendre(tester, fois: 15);
}
