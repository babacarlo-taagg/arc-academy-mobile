import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import '../api/api_client.dart';
import '../db/base.dart';
import '../env.dart';
import '../profils/coffre_fort.dart';
import '../profils/profils.dart';
import '../services.dart';
import 'journal.dart';
import 'moteur_synchro.dart';

const nomTacheSynchro = 'arc_synchro';

/// Programme l'envoi de la file toutes les 15 minutes environ, même appli fermée, quand le réseau est là
/// (Android : WorkManager ; iOS : le système décide du moment, souvent moins souvent).
Future<void> programmerSynchroDeFond() async {
  await Workmanager().initialize(executerTacheDeFond);
  await Workmanager().registerPeriodicTask(
    nomTacheSynchro,
    nomTacheSynchro,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}

@pragma('vm:entry-point')
void executerTacheDeFond() {
  Workmanager().executeTask((tache, donnees) async {
    WidgetsFlutterBinding.ensureInitialized();
    await synchroniserTousLesProfils();
    return true;
  });
}

/// Envoie la file de chaque profil du téléphone. Les clés des bases sont dans le coffre-fort du système :
/// pas besoin du PIN.
Future<void> synchroniserTousLesProfils() async {
  final support = await getApplicationSupportDirectory();
  final coffre = CoffreFortSysteme();
  final profils = ProfilStore(coffre);
  final appareil = await profils.appareilId();
  for (final profil in await profils.profils()) {
    final cle = await profils.cleBase(profil.id);
    final fichier = File(p.join(support.path, 'profils', '${profil.id}.sqlite'));
    if (cle == null || !fichier.existsSync()) continue;
    final db = BaseProfil.ouvrir(fichier, cle, enArrierePlan: false);
    try {
      if (await db.compterEnAttente() == 0) continue;
      final api = ApiClient(baseUrl: Env.apiBaseUrl, jetons: JetonsProfil(profils, profil.id), gzip: !Env.isMock);
      final moteur = MoteurSynchro(db: db, api: api, journal: JournalApprenant(db), appareilId: appareil);
      await moteur.envoyer();
      await moteur.fermer();
    } catch (_) {
      // On réessaiera au prochain passage.
    } finally {
      await db.close();
    }
  }
}
