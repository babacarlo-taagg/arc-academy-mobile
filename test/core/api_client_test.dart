import 'package:arc_academy/core/api/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

import '../outils/faux_serveur.dart';
import '../outils/jetons_memoire.dart';

void main() {
  late FauxServeur serveur;
  setUp(() async {
    serveur = FauxServeur();
    await serveur.demarrer();
  });
  tearDown(() => serveur.arreter());

  test('jeton expiré : la session est renouvelée une seule fois et les requêtes rejouées', () async {
    final jetons = JetonsMemoire();
    final api = ApiClient(baseUrl: serveur.url, jetons: jetons);
    serveur.expirerJetons();
    final resultats = await Future.wait([api.formations(), api.formations(), api.etat()]);
    expect(resultats, hasLength(3));
    expect(serveur.rafraichissements, 1);
    expect(jetons.acces, isNot('acces-1'));
    expect(jetons.rafraichissement, serveur.jetonRafraichissement, reason: 'rotation du jeton de rafraîchissement');
  });

  test('profil à effacer : le rappel d’effacement est appelé', () async {
    var efface = false;
    final api = ApiClient(baseUrl: serveur.url, jetons: JetonsMemoire(), onProfilEfface: () async => efface = true);
    serveur.profilEfface = true;
    await expectLater(api.formations(), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'profil_efface')));
    expect(efface, isTrue);
  });

  test('profil à effacer découvert au renouvellement', () async {
    var efface = false;
    final api = ApiClient(baseUrl: serveur.url, jetons: JetonsMemoire(), onProfilEfface: () async => efface = true);
    serveur.expirerJetons();
    serveur.profilEfface = true;
    await expectLater(api.formations(), throwsA(isA<ApiException>()));
    expect(efface, isTrue);
  });

  test('session révoquée : jetons oubliés, données gardées, l’apprenant redonnera un code', () async {
    final jetons = JetonsMemoire();
    var fermee = false;
    final api = ApiClient(baseUrl: serveur.url, jetons: jetons, onSessionFermee: () async => fermee = true);
    serveur.expirerJetons();
    serveur.sessionRevoquee = true;
    await expectLater(api.formations(), throwsA(isA<ApiException>().having((e) => e.status, 'statut', 401)));
    expect(fermee, isTrue);
    expect(jetons.oublie, isTrue);
  });

  test('hors ligne : erreur « reseau », la session est gardée', () async {
    final jetons = JetonsMemoire();
    final api = ApiClient(baseUrl: serveur.url, jetons: jetons, delai: const Duration(seconds: 2));
    await serveur.arreter();
    await expectLater(api.formations(), throwsA(isA<ApiException>().having((e) => e.estReseau, 'réseau', isTrue)));
    expect(jetons.acces, 'acces-1');
    serveur = FauxServeur();
    await serveur.demarrer();
  });

  test('connexion par code : mauvais code puis bon code', () async {
    final api = ApiClient(baseUrl: serveur.url);
    final envoi = await api.demanderCode('awa@example.org');
    expect(envoi.emailMasque, contains('•'));
    await expectLater(
      api.verifierCode(email: 'awa@example.org', code: '000000', appareil: const {'id': 'x', 'plateforme': 'android'}),
      throwsA(isA<ApiException>().having((e) => e.extra['essaisRestants'], 'essais', 4)),
    );
    final session = await api.verifierCode(
      email: 'awa@example.org',
      code: '123456',
      appareil: const {'id': 'x', 'plateforme': 'android'},
    );
    expect(session.apprenant.nom, 'Awa Diop');
  });

  test('manifest : 304 quand la version locale est à jour', () async {
    serveur.manifestes[3] = {'coursId': 3, 'version': 'v9', 'titre': 'T', 'tailleTotale': 0, 'lecons': []};
    final api = ApiClient(baseUrl: serveur.url, jetons: JetonsMemoire());
    expect((await api.manifest(3))!.version, 'v9');
    expect(await api.manifest(3, versionLocale: 'v9'), isNull);
  });

  test('les octets échangés sont comptés', () async {
    var octets = 0;
    final api = ApiClient(baseUrl: serveur.url, jetons: JetonsMemoire(), compteur: (n) => octets += n);
    await api.formations();
    expect(octets, greaterThan(0));
  });
}
