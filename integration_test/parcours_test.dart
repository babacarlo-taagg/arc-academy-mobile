import 'package:arc_academy/main.dart' as appli;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Parcours complet sur un vrai téléphone (ou un émulateur), contre le serveur bouchon du contrat
/// (`api/` : npx prism mock openapi.yaml) ou l'adresse donnée par --dart-define=API_BASE_URL.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Attend qu'un élément apparaisse (sans pumpAndSettle : les indicateurs tournent sans fin).
  Future<void> attendre(WidgetTester tester, Finder f, {Duration max = const Duration(seconds: 40)}) async {
    final fin = DateTime.now().add(max);
    while (DateTime.now().isBefore(fin)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (f.evaluate().isNotEmpty) return;
    }
    throw TestFailure('Introuvable après ${max.inSeconds} s : $f');
  }

  Future<void> capture(WidgetTester tester, String nom) async {
    await tester.pump(const Duration(milliseconds: 500));
    await binding.takeScreenshot(nom);
  }

  testWidgets('connexion, code secret, Mes formations, cours, réglages', (tester) async {
    final chrono = Stopwatch()..start();
    appli.main();
    await binding.convertFlutterSurfaceToImage();
    await attendre(tester, find.byKey(const Key('champ_email')));
    final ouvertureMs = chrono.elapsedMilliseconds;
    binding.reportData = {'ouvertureMs': ouvertureMs};
    await capture(tester, '01_connexion');

    await tester.enterText(find.byKey(const Key('champ_email')), 'awa.diop@example.org');
    await tester.tap(find.byKey(const Key('bouton_recevoir_code')));
    await attendre(tester, find.byKey(const Key('champ_code')));
    await capture(tester, '02_code');

    await tester.enterText(find.byKey(const Key('champ_code')), '123456');
    await attendre(tester, find.text('Choisis ton code secret'));
    for (final pin in ['1357', '1357']) {
      for (final c in pin.split('')) {
        await tester.ensureVisible(find.text(c).last);
        await tester.tap(find.text(c).last);
        await tester.pump();
      }
      await tester.ensureVisible(find.byIcon(Icons.check_rounded));
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump(const Duration(seconds: 1));
    }
    await attendre(tester, find.text('Mes formations'));
    await attendre(tester, find.byKey(const Key('formation_12')));
    await capture(tester, '03_mes_formations');

    await tester.tap(find.byKey(const Key('formation_12')));
    await attendre(tester, find.byKey(const Key('bouton_telecharger')));
    await capture(tester, '04_cours');

    await tester.tap(find.byKey(const Key('bouton_telecharger')));
    await tester.pump(const Duration(seconds: 8));
    await capture(tester, '05_telechargement');

    await tester.tap(find.byType(BackButton));
    await attendre(tester, find.byKey(const Key('bouton_reglages')));
    await tester.tap(find.byKey(const Key('bouton_reglages')));
    await attendre(tester, find.byKey(const Key('donnees_consommees')));
    await capture(tester, '06_reglages');
  });
}
