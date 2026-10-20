import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:storage_space/storage_space.dart';

import 'api/api_client.dart';
import 'api/modeles.dart';
import 'contenus/depot_contenus.dart';
import 'contenus/telechargeur.dart';
import 'db/base.dart';
import 'env.dart';
import 'profils/coffre_fort.dart';
import 'profils/profils.dart';
import 'reglages/reglages.dart';
import 'serveur_local/serveur_local.dart';
import 'sync/journal.dart';
import 'sync/moteur_synchro.dart';

/// Version affichée et envoyée au serveur.
const versionAppli = '0.1.0';

enum TypeReseau { aucun, wifi, mobile }

/// Réseau disponible (abstrait pour les tests).
abstract class Connectivite {
  Future<TypeReseau> actuel();
  Stream<TypeReseau> get changements;
}

class ConnectiviteSysteme implements Connectivite {
  final _c = Connectivity();

  static TypeReseau _type(List<ConnectivityResult> r) {
    if (r.contains(ConnectivityResult.wifi) || r.contains(ConnectivityResult.ethernet)) return TypeReseau.wifi;
    if (r.contains(ConnectivityResult.mobile) || r.contains(ConnectivityResult.vpn)) return TypeReseau.mobile;
    return TypeReseau.aucun;
  }

  @override
  Future<TypeReseau> actuel() async => _type(await _c.checkConnectivity());

  @override
  Stream<TypeReseau> get changements => _c.onConnectivityChanged.map(_type).distinct();
}

/// Tout ce qui est commun aux profils du téléphone.
class Services {
  Services({
    required this.coffre,
    required this.profils,
    required this.depot,
    required this.reglages,
    required this.serveurLocal,
    required this.dossierBases,
    required this.connectivite,
    required this.baseUrl,
    this.placeLibre,
    this.adaptateur,
    this.plateforme = 'android',
  });

  final CoffreFort coffre;
  final ProfilStore profils;
  final DepotContenus depot;
  final Reglages reglages;
  final ServeurLocal serveurLocal;
  final Directory dossierBases;
  final Connectivite connectivite;
  final String baseUrl;
  final Future<int?> Function()? placeLibre;

  /// Adaptateur HTTP (remplacé dans les tests).
  final HttpClientAdapter? adaptateur;
  final String plateforme;

  /// Client sans session : demander un code, ouvrir une session, aide.
  late final ApiClient apiPublic = ApiClient(
    baseUrl: baseUrl,
    adaptateur: adaptateur,
    compteur: reglages.ajouterOctets,
    gzip: !baseUrl.contains('4010'),
  );

  static Future<Services> demarrer() async {
    final support = await getApplicationSupportDirectory();
    final coffre = CoffreFortSysteme();
    final depot = DepotContenus(Directory(p.join(support.path, 'contenus')));
    await depot.preparer();
    final reglages = Reglages(File(p.join(support.path, 'reglages.json')));
    await reglages.charger();
    final services = Services(
      coffre: coffre,
      profils: ProfilStore(coffre),
      depot: depot,
      reglages: reglages,
      serveurLocal: ServeurLocal(
        depot: depot,
        lecon: (c, l) => depot.manifestLocal(c)?.lecons.where((x) => x.id == l).firstOrNull,
        scormAgain: () async => (await rootBundle.load('assets/scorm/scorm-again.min.js')).buffer.asUint8List(),
      ),
      dossierBases: Directory(p.join(support.path, 'profils')),
      connectivite: ConnectiviteSysteme(),
      baseUrl: Env.apiBaseUrl,
      placeLibre: () async {
        try {
          return (await getStorageSpace(lowOnSpaceThreshold: 0, fractionDigits: 1)).free;
        } catch (_) {
          return null;
        }
      },
      plateforme: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
    );
    await services.serveurLocal.demarrer();
    return services;
  }

  File fichierBase(String profilId) => File(p.join(dossierBases.path, '$profilId.sqlite'));

  Future<Map<String, dynamic>> descriptionAppareil() async => {
    'id': await profils.appareilId(),
    'plateforme': plateforme,
    'versionAppli': versionAppli,
  };

  /// Ouvre la base et les outils d'un profil (après le PIN, ou en tâche de fond).
  Future<ProfilOuvert> ouvrirProfil(
    Profil profil, {
    bool enArrierePlan = true,
    Future<void> Function()? surEffacement,
    Future<void> Function()? surSessionFermee,
  }) async {
    final cle = await profils.cleBase(profil.id);
    if (cle == null) throw StateError('Clé du profil introuvable');
    await dossierBases.create(recursive: true);
    final db = BaseProfil.ouvrir(fichierBase(profil.id), cle, enArrierePlan: enArrierePlan);
    final jetons = JetonsProfil(profils, profil.id);
    final journal = JournalApprenant(db);
    late final ProfilOuvert ouvert;
    final api = ApiClient(
      baseUrl: baseUrl,
      jetons: jetons,
      adaptateur: adaptateur,
      compteur: reglages.ajouterOctets,
      gzip: !baseUrl.contains('4010'),
      onProfilEfface: () async {
        await ouvert.effacer();
        await surEffacement?.call();
      },
      onSessionFermee: surSessionFermee,
    );
    final moteur = MoteurSynchro(db: db, api: api, journal: journal, appareilId: await profils.appareilId());
    ouvert = ProfilOuvert(
      services: this,
      profil: profil,
      db: db,
      api: api,
      journal: journal,
      moteur: moteur,
      telechargeur: Telechargeur(depot: depot, api: api, placeLibre: placeLibre),
    );
    return ouvert;
  }

  /// Efface un profil du téléphone : base, jetons, clé, PIN. Les contenus communs restent.
  Future<void> effacerProfil(String profilId) async {
    for (final suffixe in ['', '-wal', '-shm', '-journal']) {
      final f = File('${fichierBase(profilId).path}$suffixe');
      if (f.existsSync()) await f.delete();
    }
    await profils.effacerProfil(profilId);
  }
}

/// Jetons d'un profil, lus et écrits dans le coffre-fort.
class JetonsProfil implements JetonsSession {
  JetonsProfil(this._profils, this._id);
  final ProfilStore _profils;
  final String _id;

  @override
  Future<String?> jetonAcces() => _profils.jetonAcces(_id);
  @override
  Future<String?> jetonRafraichissement() => _profils.jetonRafraichissement(_id);
  @override
  Future<String> appareilId() => _profils.appareilId();
  @override
  Future<void> enregistrer({required String acces, required String rafraichissement}) =>
      _profils.enregistrerJetons(_id, acces: acces, rafraichissement: rafraichissement);
  @override
  Future<void> oublier() => _profils.oublierJetons(_id);
}

/// Un profil déverrouillé : sa base, son client API, sa synchronisation.
class ProfilOuvert {
  ProfilOuvert({
    required this.services,
    required this.profil,
    required this.db,
    required this.api,
    required this.journal,
    required this.moteur,
    required this.telechargeur,
  });

  final Services services;
  final Profil profil;
  final BaseProfil db;
  final ApiClient api;
  final JournalApprenant journal;
  final MoteurSynchro moteur;
  final Telechargeur telechargeur;

  bool _ferme = false;
  bool get estFerme => _ferme;

  /// Branche le serveur local, déclenche la synchro après chaque action et au retour du réseau.
  StreamSubscription<TypeReseau>? _reseau;
  Timer? _attenteEnvoi;

  void activer() {
    final serveur = services.serveurLocal;
    serveur.surCommit = (c, l, commit) async => journal.etatScorm(c, l, commit);
    serveur.configScorm = (c, l) async {
      final etat = await journal.lireEtatScorm(l);
      return {
        'learnerId': '${profil.apprenantId}',
        'learnerName': profil.nom,
        // Même forme que sur le site : `runtimeData` de scorm-again, qui contient `cmi`.
        if (etat.cmi != null) 'saved': _decoder(etat.cmi!),
      };
    };
    journal.apresEcriture = () {
      _attenteEnvoi?.cancel();
      _attenteEnvoi = Timer(const Duration(seconds: 2), () => unawaited(moteur.envoyer()));
    };
    _reseau = services.connectivite.changements.listen((r) {
      if (r != TypeReseau.aucun) unawaited(rafraichir());
    });
    unawaited(rafraichir());
  }

  static Object? _decoder(String json) {
    try {
      return jsonDecode(json);
    } on FormatException {
      return null;
    }
  }

  /// Envoie la file puis met à jour la liste des cours. Silencieux hors ligne.
  Future<void> rafraichir() async {
    if (_ferme) return;
    await moteur.envoyer();
    try {
      await mettreAJourFormations();
    } on ApiException {
      // hors ligne ou session à renouveler : on garde la copie locale
    }
  }

  Future<void> mettreAJourFormations() async {
    final liste = await api.formations();
    if (_ferme) return;
    await journal.enregistrerFormations(liste);
    try {
      await journal.appliquerEtatServeur(await api.etat());
    } on ApiException {
      // pas grave : la liste suffit
    }
  }

  /// Leçons d'un cours : manifest gardé sur le téléphone, sinon demandé au serveur (et gardé pour plus tard).
  Future<Manifest?> manifest(int coursId, {bool reseau = true}) async {
    final local = services.depot.manifestLocal(coursId);
    if (!reseau) return local;
    try {
      final m = await api.manifest(coursId, versionLocale: local?.version);
      if (m == null) return local;
      if (local == null || services.depot.etat(coursId) == EtatHorsLigne.aucun) {
        await services.depot.enregistrerManifest(m);
      }
      return m;
    } on ApiException {
      return local;
    }
  }

  Future<void> fermer() async {
    if (_ferme) return;
    _ferme = true;
    _attenteEnvoi?.cancel();
    await _reseau?.cancel();
    services.serveurLocal.surCommit = null;
    services.serveurLocal.configScorm = null;
    await moteur.fermer();
    await db.close();
  }

  /// Effacement à distance (ou demandé) : tout ce qui est propre au profil disparaît du téléphone.
  Future<void> effacer() async {
    await fermer();
    await services.effacerProfil(profil.id);
  }
}
