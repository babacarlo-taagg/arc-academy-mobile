import 'dart:io';

import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/profils/coffre_fort.dart';
import 'package:arc_academy/core/profils/profils.dart';
import 'package:arc_academy/core/services.dart';
import 'package:arc_academy/core/contenus/depot_contenus.dart';
import 'package:arc_academy/core/reglages/reglages.dart';
import 'package:arc_academy/core/serveur_local/serveur_local.dart';
import 'package:flutter_test/flutter_test.dart';

Session session(int id, String nom) => Session(
  jetonAcces: 'a$id',
  expireDans: 3600,
  jetonRafraichissement: 'r$id',
  apprenant: Apprenant(id: id, nom: nom, email: '$id@example.org', roles: const ['apprenant']),
);

class ConnectiviteFixe implements Connectivite {
  @override
  Future<TypeReseau> actuel() async => TypeReseau.aucun;
  @override
  Stream<TypeReseau> get changements => const Stream.empty();
}

void main() {
  test('PBKDF2-HMAC-SHA256 : vecteur connu (RFC 7914)', () {
    expect(pbkdf2Sha256Hex('passwd', 'salt', 1), '55ac046e56e3089fec1691c22544b605f94185216dde0465e68b9d57c20dacbc');
  });

  test('PIN : bon, mauvais, puis attente croissante après 5 erreurs', () async {
    var maintenant = DateTime(2026, 10, 21, 9);
    final store = ProfilStore(CoffreFortMemoire(), horloge: () => maintenant);
    final p = await store.ouvrirSession(session(1, 'Awa Diop'));
    await store.definirPin(p.id, '2468');
    expect((await store.verifierPin(p.id, '2468')).ok, isTrue);

    for (var i = 1; i <= 4; i++) {
      final r = await store.verifierPin(p.id, '0000');
      expect(r.ok, isFalse);
      expect(r.attente, Duration.zero);
      expect(r.essaisAvantAttente, 5 - i);
    }
    final cinquieme = await store.verifierPin(p.id, '0000');
    expect(cinquieme.attente, const Duration(seconds: 30));
    // Même le bon PIN est refusé pendant l'attente.
    expect((await store.verifierPin(p.id, '2468')).ok, isFalse);
    maintenant = maintenant.add(const Duration(seconds: 31));
    final sixieme = await store.verifierPin(p.id, '1111');
    expect(sixieme.attente, const Duration(minutes: 1));
    maintenant = maintenant.add(const Duration(minutes: 2));
    expect((await store.verifierPin(p.id, '2468')).ok, isTrue);
    expect(await store.attenteAvantEssai(p.id), Duration.zero);
  });

  test('deux profils : bases et clés séparées ; effacer l’un ne touche pas l’autre', () async {
    final dossier = Directory.systemTemp.createTempSync('arc_profils_');
    addTearDown(() => dossier.deleteSync(recursive: true));
    final coffre = CoffreFortMemoire();
    final depot = DepotContenus(Directory('${dossier.path}/contenus'));
    final services = Services(
      coffre: coffre,
      profils: ProfilStore(coffre),
      depot: depot,
      reglages: Reglages(File('${dossier.path}/reglages.json')),
      serveurLocal: ServeurLocal(depot: depot, lecon: (_, _) => null, scormAgain: () async => []),
      dossierBases: Directory('${dossier.path}/profils'),
      connectivite: ConnectiviteFixe(),
      baseUrl: 'http://127.0.0.1:9/api/v1',
    );
    final awa = await services.profils.ouvrirSession(session(1, 'Awa Diop'));
    final moussa = await services.profils.ouvrirSession(session(2, 'Moussa Ba'));
    expect(await services.profils.cleBase(awa.id), isNot(await services.profils.cleBase(moussa.id)));

    final oa = await services.ouvrirProfil(awa, enArrierePlan: false);
    await oa.db.ecrireMeta('note', 'Awa');
    final om = await services.ouvrirProfil(moussa, enArrierePlan: false);
    await om.db.ecrireMeta('note', 'Moussa');
    expect(await oa.db.lireMeta('note'), 'Awa');
    expect(await om.db.lireMeta('note'), 'Moussa');

    await oa.effacer();
    expect(services.fichierBase(awa.id).existsSync(), isFalse);
    expect(await services.profils.cleBase(awa.id), isNull);
    expect((await services.profils.profils()).map((p) => p.nom), ['Moussa Ba']);
    expect(await om.db.lireMeta('note'), 'Moussa');
    await om.fermer();
  });

  test('reconnexion du même apprenant : même profil, même clé, nouveaux jetons', () async {
    final store = ProfilStore(CoffreFortMemoire());
    final p1 = await store.ouvrirSession(session(1, 'Awa'));
    final cle = await store.cleBase(p1.id);
    final p2 = await store.ouvrirSession(
      Session(
        jetonAcces: 'neuf',
        expireDans: 3600,
        jetonRafraichissement: 'neuf-r',
        apprenant: const Apprenant(id: 1, nom: 'Awa Diop', email: 'awa@example.org', roles: ['apprenant']),
      ),
    );
    expect(p2.id, p1.id);
    expect(await store.cleBase(p2.id), cle);
    expect(await store.jetonAcces(p2.id), 'neuf');
    expect((await store.profils()).single.nom, 'Awa Diop');
    expect(p2.initiales, 'AD');
  });
}
