import 'dart:io';

import 'package:arc_academy/core/providers.dart';
import 'package:arc_academy/core/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/harnais.dart';

void main() {
  late FauxServeur serveur;
  late Directory dossier;

  setUp(() async {
    preparerReseauReel();
    serveur = FauxServeur();
    await serveur.demarrer();
    serveur.formations = [
      {
        'id': 12,
        'titre': 'Pharmacovigilance pour les points focaux',
        'cohortes': [
          {'id': 3, 'nom': 'PV-2026-Kolda'},
        ],
        'tuteurs': [],
        'nbLecons': 4,
        'nbLeconsTerminees': 1,
        'progression': 25,
        'version': 'v1',
        'tailleTelechargement': 18432000,
      },
    ];
    dossier = Directory.systemTemp.createTempSync('arc_ecrans_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  testWidgets('première connexion : e-mail, code, code secret, puis Mes formations', (tester) async {
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url);
    final conteneur = await lancerAppli(tester, services);
    expect(find.byKey(const Key('champ_email')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('champ_email')), 'awa@example.org');
    await tester.tap(find.byKey(const Key('bouton_recevoir_code')));
    await attendre(tester);
    expect(find.textContaining('Si cette adresse est connue'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('champ_code')), '000000');
    await attendre(tester);
    expect(find.textContaining('Code incorrect'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('champ_code')), '123456');
    await attendre(tester);
    expect(find.text('Choisis ton code secret'), findsOneWidget);

    await taperPin(tester, '246813');
    await attendre(tester);
    expect(find.text('Tape encore ton code secret'), findsOneWidget);
    await taperPin(tester, '246813');
    await attendre(tester, fois: 15);

    expect(find.text('Mes formations'), findsOneWidget);
    expect(find.text('Pharmacovigilance pour les points focaux'), findsOneWidget);
    expect(find.text('Tout est envoyé'), findsOneWidget);
    expect(find.text('1 / 4 leçons'), findsOneWidget);

    final profils = await services.profils.profils();
    expect(profils.single.nom, 'Awa Diop');
    expect(await services.profils.pinDefini(profils.single.id), isTrue);
    await terminer(tester, conteneur);
  });

  testWidgets('téléphone partagé : choix du profil puis code secret, mauvais code refusé', (tester) async {
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url);
    // Petit téléphone (320 points de large) : rien ne doit déborder.
    await tester.runAsync(() async {
      for (final (id, nom) in [(1, 'Awa Diop'), (2, 'Moussa Ba')]) {
        final p = await services.profils.ouvrirSession(sessionDeTest(id, nom));
        await services.profils.definirPin(p.id, '1234');
      }
    });
    final conteneur = await lancerAppli(tester, services, taille: const Size(320, 640));
    expect(find.text('Qui apprend ?'), findsOneWidget);
    expect(find.text('Moussa Ba'), findsOneWidget);

    await tester.tap(find.text('Moussa Ba'));
    await attendre(tester);
    expect(find.text('Bonjour Moussa'), findsOneWidget);
    await taperPin(tester, '9999');
    await tester.ensureVisible(find.byIcon(Icons.check_rounded));
    await tester.tap(find.byIcon(Icons.check_rounded));
    await attendre(tester, fois: 10);
    expect(find.textContaining('Code secret incorrect'), findsOneWidget);

    await taperPin(tester, '1234');
    await tester.ensureVisible(find.byIcon(Icons.check_rounded));
    await tester.tap(find.byIcon(Icons.check_rounded));
    await attendre(tester, fois: 15);
    expect(find.text('Mes formations'), findsOneWidget);
    expect(conteneur.read(profilOuvertProvider)?.profil.nom, 'Moussa Ba');
    await terminer(tester, conteneur);
  });

  testWidgets('hors ligne : la liste locale reste, l’indicateur montre les éléments en attente', (tester) async {
    await chargerPolices();
    final connectivite = ConnectiviteTest()..valeur = TypeReseau.aucun;
    final services = servicesDeTest(dossier, 'http://127.0.0.1:9/api/v1', connectivite: connectivite);
    late String id;
    await tester.runAsync(() async {
      final p = await services.profils.ouvrirSession(sessionDeTest(1, 'Awa Diop'));
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
    final ouvert = conteneur.read(profilOuvertProvider)!;
    // Écritures lancées dans la zone de l'écran (comme le ferait un lecteur), puis on laisse le temps passer.
    var fini = false;
    () async {
      await ouvert.journal.leconOuverte(12, 1);
      await ouvert.journal.leconTerminee(12, 1);
      await ouvert.journal.tempsPasse(12, 1, 120);
      fini = true;
    }();
    await attendre(tester, fois: 15);
    expect(fini, isTrue);
    expect(find.text('3 éléments en attente'), findsOneWidget);
    expect(find.text('Sans réseau'), findsOneWidget);
    await terminer(tester, conteneur);
  });
}
