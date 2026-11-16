import 'dart:async';
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

/// Profil progressif : écran obligatoire, institution, sexe, Mon profil, langue.
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
    dossier = Directory.systemTemp.createTempSync('arc_profil_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  /// Lance l'appli et ouvre le profil d'Awa par son code secret.
  Future<(ProviderContainer, Services)> ouvrir(
    WidgetTester tester, {
    ConnectiviteTest? connectivite,
    Locale langueTelephone = const Locale('fr', 'SN'),
  }) async {
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url, connectivite: connectivite);
    late String id;
    await tester.runAsync(() async {
      final p = await services.profils.ouvrirSession(sessionDeTest(42, 'Awa Diop'));
      id = p.id;
      await services.profils.definirPin(p.id, '1234');
    });
    final conteneur = await lancerAppli(tester, services, langueTelephone: langueTelephone);
    await tester.tap(find.byKey(Key('profil_$id')));
    await attendre(tester);
    await taperPin(tester, '1234');
    await tester.ensureVisible(find.byIcon(Icons.check_rounded));
    await tester.tap(find.byIcon(Icons.check_rounded));
    await attendre(tester, fois: 15);
    return (conteneur, services);
  }

  /// Fait défiler la page jusqu'à l'élément (les listes ne construisent que ce qui est à l'écran).
  Future<void> voir(WidgetTester tester, Finder f) async {
    if (f.evaluate().isEmpty) {
      // Retour en haut, puis on descend jusqu'à l'élément.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      if (f.evaluate().isEmpty) await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(f);
    await tester.pump();
  }

  Future<void> choisirDansListe(WidgetTester tester, String cle, String libelle) async {
    await voir(tester, find.byKey(Key(cle)));
    await tester.tap(find.byKey(Key(cle)));
    await attendre(tester, fois: 2);
    await tester.tap(find.text(libelle).last);
    await attendre(tester, fois: 2);
  }

  testWidgets('première connexion : « Ton profil » bloque sans pays ni métier, puis Mes formations', (tester) async {
    serveur.profil = FauxServeur.profilVide();
    final (conteneur, _) = await ouvrir(tester);
    expect(find.text('Ton profil'), findsOneWidget);
    expect(find.text('Mes formations'), findsNothing);
    // Seulement les questions demandées (3 au plus) : pas d'institution ici.
    expect(find.byKey(const Key('champ_institution')), findsNothing);

    await tester.tap(find.byKey(const Key('bouton_profil_continuer')));
    await attendre(tester, fois: 2);
    expect(find.byKey(const Key('profil_manque')), findsOneWidget);
    expect(serveur.modificationsProfil, isEmpty);

    // Les routes de l'appli restent fermées tant que le profil est incomplet.
    conteneur.read(routeurProvider).go('/formations');
    await attendre(tester, fois: 2);
    expect(find.text('Ton profil'), findsOneWidget);

    await tester.tap(find.byKey(const Key('champ_pays')));
    await attendre(tester, fois: 2);
    await tester.enterText(find.byKey(const Key('recherche_pays')), 'sene');
    await attendre(tester, fois: 2);
    expect(find.byKey(const Key('pays_BJ')), findsNothing);
    await tester.tap(find.byKey(const Key('pays_SN')));
    await attendre(tester, fois: 2);
    await choisirDansListe(tester, 'champ_metier', 'Sage-femme');

    await tester.tap(find.byKey(const Key('bouton_profil_continuer')));
    await attendre(tester, fois: 15);
    expect(find.text('Mes formations'), findsOneWidget);
    expect(serveur.modificationsProfil.single, {'pays': 'SN', 'metier': 'sage_femme', 'langue': 'fr'});
    await terminer(tester, conteneur);
  });

  testWidgets('profil jamais lu et pas de réseau : explication, puis Réessayer', (tester) async {
    serveur.profilInjoignable = true;
    final (conteneur, _) = await ouvrir(tester);
    expect(find.textContaining('Il faut du réseau une fois'), findsOneWidget);
    expect(find.text('Mes formations'), findsNothing);

    serveur.profilInjoignable = false;
    await tester.tap(find.byKey(const Key('bouton_profil_reessayer')));
    await attendre(tester, fois: 15);
    expect(find.text('Mes formations'), findsOneWidget);
    await terminer(tester, conteneur);
  });

  testWidgets('hors ligne avec un profil déjà lu : pas bloqué, même incomplet', (tester) async {
    final connectivite = ConnectiviteTest()..valeur = TypeReseau.aucun;
    serveur.profilInjoignable = true;
    final profil = {...FauxServeur.profilComplet(), 'completude': 67, 'typeInstitution': null, 'niveau': null};
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url, connectivite: connectivite);
    late String id;
    await tester.runAsync(() async {
      final p = await services.profils.ouvrirSession(sessionDeTest(42, 'Awa Diop'));
      id = p.id;
      await services.profils.definirPin(p.id, '1234');
      await memoriserProfilApprenant(services, p, profil);
    });
    final conteneur = await lancerAppli(tester, services);
    await tester.tap(find.byKey(Key('profil_$id')));
    await attendre(tester);
    await taperPin(tester, '1234');
    await tester.tap(find.byIcon(Icons.check_rounded));
    await attendre(tester, fois: 15);
    expect(find.text('Mes formations'), findsOneWidget);
    expect(find.text('Profil complété à 67 %'), findsOneWidget);
    await terminer(tester, conteneur);
  });

  Map<String, dynamic> profilSansInstitution() => {
    ...FauxServeur.profilComplet(),
    'institution': null,
    'typeInstitution': null,
    'niveau': null,
    'completude': 50,
    'questionsAPoser': ['institution', 'typeInstitution', 'niveau'],
  };

  Future<void> telechargerCours(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('formation_12')));
    await attendre(tester, fois: 8);
    expect(find.byKey(const Key('carte_institution')), findsNothing);
    await tester.tap(find.byKey(const Key('bouton_telecharger')));
    await attendre(tester, fois: 12);
  }

  testWidgets('« Ton institution » au premier téléchargement ; « Plus tard » la passe', (tester) async {
    serveur.profil = profilSansInstitution();
    final (conteneur, _) = await ouvrir(tester);
    expect(find.text('Profil complété à 50 %'), findsOneWidget);
    await telechargerCours(tester);
    expect(find.byKey(const Key('carte_institution')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('bouton_institution_plus_tard')));
    await tester.tap(find.byKey(const Key('bouton_institution_plus_tard')));
    await attendre(tester, fois: 8);
    expect(find.byKey(const Key('carte_institution')), findsNothing);
    expect(serveur.modificationsProfil.single, {
      'ignorer': ['institution', 'typeInstitution', 'niveau'],
    });
    await terminer(tester, conteneur);
  });

  testWidgets('« Ton institution » : recherche dans les institutions d’ARC, type et niveau', (tester) async {
    serveur.profil = profilSansInstitution();
    final (conteneur, _) = await ouvrir(tester);
    await telechargerCours(tester);
    await tester.ensureVisible(find.byKey(const Key('bouton_institution_repondre')));
    await tester.tap(find.byKey(const Key('bouton_institution_repondre')));
    await attendre(tester, fois: 4);
    expect(find.text('Ton institution'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('champ_institution')), 'Ko');
    await tester.pump(const Duration(milliseconds: 500));
    await attendre(tester, fois: 4);
    expect(serveur.recherchesOrganisations, isEmpty);
    await tester.enterText(find.byKey(const Key('champ_institution')), 'kolda');
    await tester.pump(const Duration(milliseconds: 500));
    await attendre(tester, fois: 6);
    expect(serveur.recherchesOrganisations, ['kolda']);
    expect(find.byKey(const Key('organisation_5')), findsOneWidget);
    expect(find.byKey(const Key('organisation_7')), findsNothing);
    await tester.tap(find.byKey(const Key('organisation_6')));
    await attendre(tester, fois: 2);
    await choisirDansListe(tester, 'champ_type_institution', 'Hôpital');
    await choisirDansListe(tester, 'champ_niveau', 'Régional');
    await tester.tap(find.byKey(const Key('bouton_institution_enregistrer')));
    await attendre(tester, fois: 10);

    expect(find.byKey(const Key('carte_institution')), findsNothing);
    expect(serveur.modificationsProfil.single, {
      'institutionId': 6,
      'typeInstitution': 'hopital',
      'niveau': 'regional',
    });
    expect((serveur.profil['institution'] as Map)['nom'], 'Hôpital régional de Kolda');
    await terminer(tester, conteneur);
  });

  testWidgets('institution tapée sans réseau : gardée, puis envoyée au retour du réseau', (tester) async {
    serveur.profil = profilSansInstitution();
    final connectivite = ConnectiviteTest();
    final (conteneur, _) = await ouvrir(tester, connectivite: connectivite);
    await telechargerCours(tester);

    // Le réseau tombe.
    serveur.profilInjoignable = true;
    connectivite.changer(TypeReseau.aucun);
    await attendre(tester, fois: 2);
    await tester.ensureVisible(find.byKey(const Key('bouton_institution_repondre')));
    await tester.tap(find.byKey(const Key('bouton_institution_repondre')));
    await attendre(tester, fois: 4);
    await tester.enterText(find.byKey(const Key('champ_institution')), 'Poste de santé de Médina');
    await tester.pump(const Duration(milliseconds: 500));
    await attendre(tester, fois: 4);
    expect(find.textContaining('Sans réseau : tape le nom'), findsOneWidget);
    expect(serveur.recherchesOrganisations, isEmpty);
    await tester.tap(find.byKey(const Key('bouton_institution_enregistrer')));
    await attendre(tester, fois: 8);
    expect(find.textContaining('Envoi à ARC dès que le réseau revient'), findsOneWidget);
    expect(find.byKey(const Key('carte_institution')), findsNothing, reason: 'déjà répondu sur le téléphone');
    expect(serveur.modificationsProfil, isEmpty);
    final service = conteneur.read(profilOuvertProvider)!.profilApprenant;
    expect(service.actuel.envoiEnAttente, isTrue);
    expect(service.actuel.profil!.institution!.nom, 'Poste de santé de Médina');

    // Le réseau revient : la modification part (une seule fois).
    serveur.profilInjoignable = false;
    connectivite.changer(TypeReseau.wifi);
    await attendre(tester, fois: 15);
    expect(serveur.modificationsProfil.single, {
      'institutionNom': 'Poste de santé de Médina',
      // Type et niveau laissés vides : passés, pour ne pas les redemander.
      'ignorer': ['typeInstitution', 'niveau'],
    });
    expect(service.actuel.envoiEnAttente, isFalse);
    expect((serveur.profil['institution'] as Map)['nom'], 'Poste de santé de Médina');
    await terminer(tester, conteneur);
  });

  testWidgets('sexe facultatif dans Mes formations : « Passer » ne le redemande plus', (tester) async {
    serveur.profil = {
      ...FauxServeur.profilComplet(),
      'questionsAPoser': ['sexe'],
    };
    final (conteneur, _) = await ouvrir(tester);
    expect(find.byKey(const Key('carte_sexe')), findsOneWidget);
    expect(find.textContaining('statistiques anonymes'), findsOneWidget);
    expect(find.byKey(const Key('barre_completude')), findsNothing);
    await tester.tap(find.byKey(const Key('bouton_sexe_passer')));
    await attendre(tester, fois: 8);
    expect(find.byKey(const Key('carte_sexe')), findsNothing);
    expect(serveur.modificationsProfil.single, {
      'ignorer': ['sexe'],
    });

    // Relu du serveur : la question ne revient pas.
    unawaited(conteneur.read(profilOuvertProvider)!.rafraichir());
    await attendre(tester, fois: 8);
    expect(find.byKey(const Key('carte_sexe')), findsNothing);
    await terminer(tester, conteneur);
  });

  testWidgets('Mon profil : modification, accord WhatsApp avec sa version, retrait en un clic', (tester) async {
    serveur.profil = {...FauxServeur.profilComplet(), 'typeInstitution': null, 'completude': 83};
    final (conteneur, _) = await ouvrir(tester);
    await tester.tap(find.byKey(const Key('bouton_reglages')));
    await attendre(tester, fois: 4);
    expect(find.text('Profil complété à 83 %'), findsOneWidget);
    await tester.tap(find.byKey(const Key('lien_mon_profil')));
    await attendre(tester, fois: 6);
    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.text('Sénégal'), findsOneWidget);
    expect(find.text('Centre de santé de Kolda'), findsOneWidget);
    await voir(tester, find.byKey(const Key('case_whatsapp_accord')));
    final accord = tester.widget<CheckboxListTile>(find.byKey(const Key('case_whatsapp_accord')));
    expect(accord.value, isFalse, reason: 'jamais cochée d’avance');

    await choisirDansListe(tester, 'mon_profil_metier', 'Pharmacien(ne)');
    await choisirDansListe(tester, 'mon_profil_typeInstitution', 'Centre de santé');
    await tester.enterText(find.byKey(const Key('champ_whatsapp')), '77 123');
    await voir(tester, find.byKey(const Key('case_whatsapp_accord')));
    await tester.tap(find.byKey(const Key('case_whatsapp_accord')));
    await voir(tester, find.byKey(const Key('bouton_mon_profil_enregistrer')));
    await tester.tap(find.byKey(const Key('bouton_mon_profil_enregistrer')));
    await attendre(tester, fois: 4);
    expect(find.textContaining('Numéro incomplet'), findsOneWidget);
    expect(serveur.modificationsProfil, isEmpty);

    await tester.enterText(find.byKey(const Key('champ_whatsapp')), '+221 77 123 45 67');
    await voir(tester, find.byKey(const Key('bouton_mon_profil_enregistrer')));
    await tester.tap(find.byKey(const Key('bouton_mon_profil_enregistrer')));
    await attendre(tester, fois: 10);
    expect(serveur.modificationsProfil.single, {
      'metier': 'pharmacien',
      'typeInstitution': 'centre_sante',
      'whatsapp': '+221771234567',
      'whatsappAccord': true,
      'whatsappAccordVersion': 'whatsapp-2026-11-v1',
    });
    expect(find.text('Profil complété à 83 %'), findsNothing);
    expect(find.textContaining('Tu as accepté'), findsOneWidget);

    await voir(tester, find.byKey(const Key('bouton_whatsapp_retirer')));
    await tester.tap(find.byKey(const Key('bouton_whatsapp_retirer')));
    await attendre(tester, fois: 10);
    expect(serveur.modificationsProfil.last, {'whatsappAccord': false});
    expect(serveur.profil['whatsappAccord'], isFalse);
    expect(find.byKey(const Key('case_whatsapp_accord')), findsOneWidget);
    await terminer(tester, conteneur);
  });

  testWidgets('anglais : téléphone en anglais, puis langue du profil', (tester) async {
    serveur.profil = {...FauxServeur.profilComplet(), 'langue': 'en'};
    await chargerPolices();
    final services = servicesDeTest(dossier, serveur.url);
    final conteneur = await lancerAppli(tester, services, langueTelephone: const Locale('en', 'GH'));
    expect(find.text('Get my code'), findsOneWidget);
    await terminer(tester, conteneur);
  });

  testWidgets('anglais : la langue du profil choisit les textes et les listes', (tester) async {
    serveur.profil = {...FauxServeur.profilComplet(), 'langue': 'en'};
    final (conteneur, _) = await ouvrir(tester);
    expect(find.text('My courses'), findsOneWidget);
    expect(serveur.languesReferentiels, contains('en'));
    await tester.tap(find.byKey(const Key('bouton_reglages')));
    await attendre(tester, fois: 4);
    await tester.tap(find.byKey(const Key('lien_mon_profil')));
    await attendre(tester, fois: 6);
    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('Senegal'), findsOneWidget);
    expect(find.text('Nurse'), findsOneWidget);

    // Retour au français depuis Mon profil.
    await choisirDansListe(tester, 'mon_profil_langue', 'French');
    await voir(tester, find.byKey(const Key('bouton_mon_profil_enregistrer')));
    await tester.tap(find.byKey(const Key('bouton_mon_profil_enregistrer')));
    await attendre(tester, fois: 12);
    expect(find.text('Mon profil'), findsOneWidget);
    expect(serveur.languesReferentiels.last, 'fr');
    await voir(tester, find.byKey(const Key('mon_profil_metier')));
    expect(find.text('Infirmier(ère)'), findsOneWidget);
    expect(serveur.modificationsProfil.single, {'langue': 'fr'});
    await terminer(tester, conteneur);
  });
}
