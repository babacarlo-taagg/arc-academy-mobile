import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Lance le parcours sur l'émulateur et range les captures dans build/captures/.
Future<void> main() => integrationDriver(
  onScreenshot: (nom, octets, [args]) async {
    final f = File('build/captures/$nom.png');
    await f.parent.create(recursive: true);
    await f.writeAsBytes(octets);
    return true;
  },
);
