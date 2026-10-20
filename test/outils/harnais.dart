import 'dart:async';
import 'dart:io';

import 'package:arc_academy/app.dart';
import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/contenus/depot_contenus.dart';
import 'package:arc_academy/core/profils/coffre_fort.dart';
import 'package:arc_academy/core/profils/profils.dart';
import 'package:arc_academy/core/providers.dart';
import 'package:arc_academy/core/reglages/reglages.dart';
import 'package:arc_academy/core/serveur_local/serveur_local.dart';
import 'package:arc_academy/core/services.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class ConnectiviteTest implements Connectivite {
  TypeReseau valeur = TypeReseau.wifi;
  final _flux = StreamController<TypeReseau>.broadcast();

  void changer(TypeReseau r) {
    valeur = r;
    _flux.add(r);
  }

  @override
  Future<TypeReseau> actuel() async => valeur;
  @override
  Stream<TypeReseau> get changements => _flux.stream;
}

HttpClient? _clientReel;

/// À appeler dans `setUp` (hors de la zone de `testWidgets`, où les requêtes HTTP sont simulées) :
/// les écrans parlent alors vraiment au faux serveur.
void preparerReseauReel() {
  // Le cadre de test remplace HttpClient par une version qui répond toujours 400 : on garde un vrai client.
  final avant = HttpOverrides.current;
  HttpOverrides.global = null;
  _clientReel ??= HttpClient();
  HttpOverrides.global = avant;
}

/// Services du téléphone pour les tests : dossiers temporaires, coffre-fort en mémoire, faux serveur.
Services servicesDeTest(Directory dossier, String baseUrl, {ConnectiviteTest? connectivite}) {
  final coffre = CoffreFortMemoire();
  final depot = DepotContenus(Directory('${dossier.path}/contenus'));
  return Services(
    coffre: coffre,
    profils: ProfilStore(coffre),
    depot: depot,
    reglages: Reglages(File('${dossier.path}/reglages.json')),
    serveurLocal: ServeurLocal(depot: depot, lecon: (_, _) => null, scormAgain: () async => const []),
    dossierBases: Directory('${dossier.path}/profils'),
    connectivite: connectivite ?? ConnectiviteTest(),
    baseUrl: baseUrl,
    placeLibre: () async => 2 * 1024 * 1024 * 1024,
    basesEnArrierePlan: false,
    adaptateur: _clientReel == null ? null : IOHttpClientAdapter(createHttpClient: () => _clientReel!),
  );
}

bool _policesChargees = false;

/// Charge les vraies polices (Lexend et icônes) pour que les captures ressemblent à l'appli.
Future<void> chargerPolices() async {
  if (_policesChargees) return;
  _policesChargees = true;
  final lexend = FontLoader('Lexend');
  for (final f in ['Regular', 'SemiBold', 'Bold']) {
    lexend.addFont(Future.value(ByteData.sublistView(File('assets/fonts/Lexend-$f.ttf').readAsBytesSync())));
  }
  await lexend.load();
  final icones = FontLoader('MaterialIcons')..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icones.load();
}

Future<ProviderContainer> lancerAppli(
  WidgetTester tester,
  Services services, {
  Size taille = const Size(360, 740),
}) async {
  tester.view.physicalSize = taille * 2;
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  final conteneur = ProviderContainer(overrides: [servicesProvider.overrideWithValue(services)]);
  addTearDown(conteneur.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(container: conteneur, child: const AppliArc()));
  await attendre(tester);
  return conteneur;
}

/// Laisse passer le vrai temps (réseau, base, isolats), puis redessine.
Future<void> attendre(WidgetTester tester, {int fois = 6}) async {
  for (var i = 0; i < fois; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> taperPin(WidgetTester tester, String pin) async {
  for (final c in pin.split('')) {
    await tester.tap(find.text(c).last);
    await tester.pump();
  }
}

Session sessionDeTest(int id, String nom) => Session(
  jetonAcces: 'acces-1',
  expireDans: 3600,
  jetonRafraichissement: 'rafraichir-1',
  apprenant: Apprenant(id: id, nom: nom, email: '$id@example.org', roles: const ['apprenant']),
);

/// Ferme le profil et laisse s'écouler les minuteurs (sauvegarde des réglages, flux de la base).
Future<void> terminer(WidgetTester tester, ProviderContainer conteneur) async {
  await tester.runAsync(() => conteneur.read(profilOuvertProvider.notifier).fermer());
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 20));
}
