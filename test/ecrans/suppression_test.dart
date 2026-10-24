import 'dart:io';

import 'package:arc_academy/app.dart';
import 'package:arc_academy/core/providers.dart';
import 'package:arc_academy/core/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/harnais.dart';

final _defilement = find
    .descendant(of: find.byKey(const Key('liste_suppression')), matching: find.byType(Scrollable))
    .first;

void main() {
  late FauxServeur serveur;
  late Directory dossier;

  setUp(() async {
    preparerReseauReel();
    serveur = FauxServeur();
    await serveur.demarrer();
    dossier = Directory.systemTemp.createTempSync('arc_suppression_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  /// Ouvre le profil d'Awa et va sur l'écran de suppression.
  Future<(Services, ProviderContainer, String)> ouvrirSuppression(
    WidgetTester tester, {
    ConnectiviteTest? connectivite,
  }) async {
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url, connectivite: connectivite);
    late String id;
    await tester.runAsync(() async {
      final p = await services.profils.ouvrirSession(sessionDeTest(42, 'Awa Diop'));
      id = p.id;
      await services.profils.definirPin(p.id, '1234');
    });
    final conteneur = await lancerAppli(tester, services);
    await tester.tap(find.byKey(Key('profil_$id')));
    await attendre(tester);
    await taperPin(tester, '1234');
    await tester.ensureVisible(find.byIcon(Icons.check_rounded));
    await tester.tap(find.byIcon(Icons.check_rounded));
    await attendre(tester, fois: 15);
    conteneur.read(routeurProvider).go('/reglages');
    await attendre(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('bouton_supprimer_mon_compte')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.byKey(const Key('bouton_supprimer_mon_compte')));
    await attendre(tester);
    expect(find.text('Pour confirmer, tape SUPPRIMER'), findsOneWidget);
    return (services, conteneur, id);
  }

  Future<void> confirmerEtEnvoyer(WidgetTester tester) async {
    final bouton = find.byKey(const Key('bouton_supprimer_compte'));
    await tester.scrollUntilVisible(bouton, 300, scrollable: _defilement);
    expect(tester.widget<ButtonStyleButton>(bouton).onPressed, isNull, reason: 'pas avant la confirmation');
    await tester.enterText(find.byKey(const Key('champ_confirmation')), 'supprimer');
    await tester.pump();
    expect(tester.widget<ButtonStyleButton>(bouton).onPressed, isNotNull);
    await tester.tap(bouton);
    await attendre(tester, fois: 10);
  }

  testWidgets('demande acceptée : message d’ARC, puis profil effacé du téléphone', (tester) async {
    final (services, conteneur, _) = await ouvrirSuppression(tester);
    await tester.enterText(find.byKey(const Key('champ_motif')), 'Je change de métier.');
    await confirmerEtEnvoyer(tester);

    expect(serveur.suppressions, ['Je change de métier.']);
    expect(find.text('Demande envoyée'), findsOneWidget);
    expect(find.textContaining('sous 30 jours'), findsOneWidget);
    await tester.tap(find.text("J'ai compris"));
    await attendre(tester, fois: 15);

    expect(conteneur.read(profilOuvertProvider), isNull);
    expect(await tester.runAsync(() => services.profils.profils()), isEmpty);
    expect(services.fichierBase('p42').existsSync(), isFalse);
    expect(find.byKey(const Key('champ_email')), findsOneWidget, reason: 'plus aucun profil : écran de connexion');
    await terminer(tester, conteneur);
  });

  testWidgets('hors ligne : rien n’est envoyé ni effacé, lien vers le site', (tester) async {
    final connectivite = ConnectiviteTest()..valeur = TypeReseau.aucun;
    final (services, conteneur, id) = await ouvrirSuppression(tester, connectivite: connectivite);
    await confirmerEtEnvoyer(tester);

    expect(serveur.suppressions, isEmpty);
    expect(find.textContaining('Il faut du réseau'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const Key('lien_suppression_web')), 200, scrollable: _defilement);
    expect(find.text('https://academy.africaresourcecentre.org/suppression-compte'), findsOneWidget);
    expect(conteneur.read(profilOuvertProvider)?.profil.id, id);
    expect(await tester.runAsync(() => services.profils.profils()), hasLength(1));
    await terminer(tester, conteneur);
  });

  testWidgets('session refusée par le serveur : il faut se reconnecter, le profil reste', (tester) async {
    final (services, conteneur, _) = await ouvrirSuppression(tester);
    serveur
      ..expirerJetons()
      ..sessionRevoquee = true;
    await confirmerEtEnvoyer(tester);

    expect(serveur.suppressions, isEmpty);
    expect(find.textContaining('Ta session a expiré'), findsOneWidget);
    expect(await tester.runAsync(() => services.profils.profils()), hasLength(1));
    expect(find.byType(AppliArc), findsOneWidget);
    await terminer(tester, conteneur);
  });
}
