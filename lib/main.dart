import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/services.dart';
import 'core/sync/tache_fond.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await Services.demarrer();
  runApp(ProviderScope(overrides: [servicesProvider.overrideWithValue(services)], child: const AppliArc()));
  // Après le premier affichage : rien ne doit retarder l'ouverture.
  unawaited(programmerSynchroDeFond().catchError((Object _) {}));
}
