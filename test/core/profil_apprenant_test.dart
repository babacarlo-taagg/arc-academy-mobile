import 'dart:io';

import 'package:arc_academy/core/profil/service_profil.dart';
import 'package:arc_academy/core/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/harnais.dart';

void main() {
  late FauxServeur serveur;
  late Directory dossier;

  setUp(() async {
    serveur = FauxServeur();
    await serveur.demarrer();
    dossier = Directory.systemTemp.createTempSync('arc_profil_apprenant_');
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  Future<ProfilOuvert> ouvrir(Services services) async {
    final p = await services.profils.ouvrirSession(sessionDeTest(42, 'Awa Diop'));
    final ouvert = await services.ouvrirProfil(p, enArrierePlan: false);
    await ouvert.profilApprenant.charger();
    return ouvert;
  }

  test('référentiels gardés hors ligne : redemandés avec If-None-Match, 304 si rien n’a changé', () async {
    final services = servicesDeTest(dossier, serveur.url);
    var ouvert = await ouvrir(services);
    await ouvert.profilApprenant.rafraichir();
    expect(ouvert.profilApprenant.actuel.referentiels!.version, 'r1');
    expect(serveur.referentielsNonModifies, 0);
    await ouvert.profilApprenant.rafraichir();
    expect(serveur.referentielsNonModifies, 1);
    expect(serveur.languesReferentiels, ['fr', 'fr']);
    final profilId = ouvert.profil.id;
    await ouvert.fermer();

    // Plus de réseau : profil et listes viennent du téléphone, sans écran bloquant.
    await serveur.arreter();
    final profil = (await services.profils.profil(profilId))!;
    ouvert = await services.ouvrirProfil(profil, enArrierePlan: false);
    await ouvert.profilApprenant.charger();
    await ouvert.profilApprenant.rafraichir();
    final actuel = ouvert.profilApprenant.actuel;
    expect(actuel.etat, EtatProfil.pret);
    expect(actuel.referentiels!.pays.map((c) => c.cle), contains('SN'));
    await ouvert.fermer();
    await serveur.demarrer();
  });

  test('modifications hors ligne fusionnées puis envoyées en un seul PATCH', () async {
    serveur.profil = {
      ...FauxServeur.profilComplet(),
      'typeInstitution': null,
      'niveau': null,
      'sexe': null,
      'questionsAPoser': ['typeInstitution', 'niveau', 'sexe'],
    };
    final services = servicesDeTest(dossier, serveur.url);
    final ouvert = await ouvrir(services);
    await ouvert.profilApprenant.rafraichir();
    serveur.profilInjoignable = true;
    await ouvert.profilApprenant.modifier({'typeInstitution': 'hopital'});
    await ouvert.profilApprenant.ignorer(['sexe']);
    await ouvert.profilApprenant.ignorer(['niveau']);
    await ouvert.profilApprenant.rafraichir();
    expect(serveur.modificationsProfil, isEmpty);
    expect(ouvert.profilApprenant.actuel.profil!.questionsAPoser, isEmpty);
    expect(ouvert.profilApprenant.actuel.envoiEnAttente, isTrue);

    serveur.profilInjoignable = false;
    await ouvert.profilApprenant.rafraichir();
    expect(serveur.modificationsProfil.single, {
      'typeInstitution': 'hopital',
      'ignorer': ['sexe', 'niveau'],
    });
    expect(ouvert.profilApprenant.actuel.envoiEnAttente, isFalse);
    await ouvert.profilApprenant.rafraichir();
    expect(serveur.modificationsProfil, hasLength(1), reason: 'rien n’est renvoyé deux fois');
    await ouvert.fermer();
  });
}
