import 'dart:io';

import 'package:arc_academy/core/db/base.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dossier;
  setUp(() => dossier = Directory.systemTemp.createTempSync('arc_base_'));
  tearDown(() => dossier.deleteSync(recursive: true));

  const cle = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

  test('la base est chiffrée sur le disque et se rouvre avec la bonne clé', () async {
    final fichier = File('${dossier.path}/p1.sqlite');
    var base = BaseProfil.ouvrir(fichier, cle, enArrierePlan: false);
    await base.ecrireMeta('secret', 'données de Awa');
    await base.close();

    final octets = fichier.readAsBytesSync();
    expect(String.fromCharCodes(octets.take(15)), isNot('SQLite format 3'));
    expect(String.fromCharCodes(octets).contains('données'), isFalse);

    base = BaseProfil.ouvrir(fichier, cle, enArrierePlan: false);
    expect(await base.lireMeta('secret'), 'données de Awa');
    await base.close();
  });

  test('une mauvaise clé ne lit rien', () async {
    final fichier = File('${dossier.path}/p2.sqlite');
    final base = BaseProfil.ouvrir(fichier, cle, enArrierePlan: false);
    await base.ecrireMeta('a', 'b');
    await base.close();

    final autre = BaseProfil.ouvrir(fichier, 'ff' * 32, enArrierePlan: false);
    await expectLater(autre.lireMeta('a'), throwsA(anything));
    await autre.close();
  });

  test('compteur des événements en attente', () async {
    final base = BaseProfil.ouvrir(File('${dossier.path}/p3.sqlite'), cle, enArrierePlan: false);
    expect(await base.compterEnAttente(), 0);
    await base
        .into(base.evenements)
        .insert(
          EvenementsCompanion.insert(
            id: 'e1',
            type: 'lecon_ouverte',
            coursId: 1,
            leconId: 2,
            survenuLe: DateTime.now(),
          ),
        );
    expect(await base.compterEnAttente(), 1);
    expect(await base.surveillerEnAttente().first, 1);
    await base.close();
    expect(Value(1).present, isTrue);
  });
}
