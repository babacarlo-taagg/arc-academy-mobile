import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Faux serveur ARC (routes du contrat), en mémoire, pour tester l'appli sans Odoo.
///
/// Il sait simuler les ennuis du terrain : réponse perdue après traitement, connexion coupée au milieu d'un
/// fichier, session expirée, profil à effacer.
class FauxServeur {
  late HttpServer _serveur;
  String get url => 'http://127.0.0.1:${_serveur.port}/api/v1';

  /// Événements reçus (identifiant → événement), comme le journal du serveur.
  final Map<String, Map<String, dynamic>> evenementsRecus = {};
  final List<int> taillesPaquets = [];
  int requetesGzip = 0;

  /// Leçons inconnues : les événements qui les visent sont refusés.
  final Set<int> leconsInconnues = {};

  /// Traite le prochain paquet puis coupe la connexion sans répondre (la réponse « se perd »).
  bool perdreProchaineReponse = false;

  /// Fichiers servis par empreinte.
  final Map<String, List<int>> fichiers = {};
  final List<String> fichiersDemandes = [];
  final List<String?> rangesRecus = [];

  /// Coupe la connexion après ce nombre d'octets au prochain fichier servi (une seule fois).
  int? couperFichierApres;

  /// Sert un contenu différent de son empreinte (fichier abîmé).
  bool servirFichierAbime = false;

  // Session
  final Set<String> jetonsValides = {'acces-1'};
  String jetonRafraichissement = 'rafraichir-1';
  int rafraichissements = 0;
  bool profilEfface = false;
  bool sessionRevoquee = false;
  int _numero = 1;

  List<Map<String, dynamic>> formations = [];
  final Map<int, Map<String, dynamic>> manifestes = {};
  final Map<String, int> appels = {};

  Future<void> demarrer() async {
    _serveur = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _serveur.listen(_traiter);
  }

  Future<void> arreter() => _serveur.close(force: true);

  void ajouterFichier(List<int> contenu) => fichiers[sha256.convert(contenu).toString()] = contenu;

  static String empreinte(List<int> contenu) => sha256.convert(contenu).toString();

  Future<void> _json(HttpResponse r, int statut, Object? corps) async {
    r.statusCode = statut;
    if (corps != null) {
      r.headers.contentType = statut >= 400 ? ContentType('application', 'problem+json') : ContentType.json;
      r.write(jsonEncode(corps));
    }
    await r.close();
  }

  Future<void> _probleme(HttpResponse r, int statut, String code) =>
      _json(r, statut, {'type': 'about:blank', 'title': code, 'status': statut, 'code': code});

  bool _autorise(HttpRequest q) {
    final entete = q.headers.value('authorization') ?? '';
    return entete.startsWith('Bearer ') && jetonsValides.contains(entete.substring(7));
  }

  Future<void> _traiter(HttpRequest q) async {
    final r = q.response;
    final chemin = q.uri.path.replaceFirst('/api/v1', '');
    appels[chemin] = (appels[chemin] ?? 0) + 1;
    try {
      if (chemin == '/auth/rafraichir') return await _rafraichir(q);
      if (chemin == '/auth/code') {
        await utf8.decodeStream(q);
        return await _json(r, 202, {'emailMasque': 'a•••@example.org', 'expireDans': 600, 'renvoiPossibleDans': 45});
      }
      if (chemin == '/auth/verification') {
        final corps = jsonDecode(await utf8.decodeStream(q)) as Map;
        if (corps['code'] != '123456') {
          return await _json(r, 401, {
            'title': 'Code incorrect',
            'status': 401,
            'code': 'code_invalide',
            'essaisRestants': 4,
          });
        }
        return await _json(r, 200, _session());
      }
      if (profilEfface) return await _probleme(r, 401, 'profil_efface');
      if (!_autorise(q)) return await _probleme(r, 401, 'jeton_expire');
      if (chemin == '/formations') return await _json(r, 200, {'formations': formations});
      if (chemin == '/sync/etat') return await _json(r, 200, {'genereLe': _maintenant(), 'formations': []});
      if (chemin == '/sync/evenements') return await _evenements(q);
      final manifest = RegExp(r'^/formations/(\d+)/manifest$').firstMatch(chemin);
      if (manifest != null) {
        final m = manifestes[int.parse(manifest.group(1)!)];
        if (m == null) return await _probleme(r, 404, 'introuvable');
        if (q.headers.value('if-none-match') == m['version']) return await _json(r, 304, null);
        return await _json(r, 200, m);
      }
      final fichier = RegExp(r'^/fichiers/([0-9a-f]{64})$').firstMatch(chemin);
      if (fichier != null) return await _fichier(q, fichier.group(1)!);
      return await _probleme(r, 404, 'introuvable');
    } catch (_) {
      // connexion déjà coupée volontairement
    }
  }

  Map<String, dynamic> _session() {
    _numero++;
    final acces = 'acces-$_numero';
    jetonsValides.add(acces);
    jetonRafraichissement = 'rafraichir-$_numero';
    return {
      'jetonAcces': acces,
      'expireDans': 3600,
      'jetonRafraichissement': jetonRafraichissement,
      'apprenant': {
        'id': 42,
        'nom': 'Awa Diop',
        'email': 'awa@example.org',
        'roles': ['apprenant'],
        'langue': 'fr',
      },
    };
  }

  /// Fait expirer tous les jetons d'accès (le jeton de rafraîchissement reste bon).
  void expirerJetons() => jetonsValides.clear();

  Future<void> _rafraichir(HttpRequest q) async {
    final corps = jsonDecode(await utf8.decodeStream(q)) as Map;
    rafraichissements++;
    if (profilEfface) return _probleme(q.response, 401, 'profil_efface');
    if (sessionRevoquee || corps['jetonRafraichissement'] != jetonRafraichissement) {
      return _probleme(q.response, 401, 'session_revoquee');
    }
    await _json(q.response, 200, _session());
  }

  String _maintenant() => DateTime.now().toUtc().toIso8601String();

  Future<void> _evenements(HttpRequest q) async {
    var octets = <int>[];
    await for (final m in q) {
      octets.addAll(m);
    }
    if (q.headers.value('content-encoding') == 'gzip') {
      requetesGzip++;
      octets = gzip.decode(octets);
    }
    final paquet = jsonDecode(utf8.decode(octets)) as Map<String, dynamic>;
    final evenements = (paquet['evenements'] as List).cast<Map<String, dynamic>>();
    taillesPaquets.add(evenements.length);
    final resultats = <Map<String, dynamic>>[];
    for (final e in evenements) {
      final id = e['id'] as String;
      if (leconsInconnues.contains(e['leconId'])) {
        resultats.add({'id': id, 'statut': 'refuse', 'raison': 'lecon_inconnue'});
      } else if (evenementsRecus.containsKey(id)) {
        resultats.add({'id': id, 'statut': 'deja_recu'});
      } else {
        evenementsRecus[id] = e;
        resultats.add({'id': id, 'statut': 'accepte'});
      }
    }
    if (perdreProchaineReponse) {
      perdreProchaineReponse = false;
      final socket = await q.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    await _json(q.response, 200, {
      'resultats': resultats,
      'etat': {'genereLe': _maintenant(), 'formations': []},
    });
  }

  Future<void> _fichier(HttpRequest q, String empreinte) async {
    fichiersDemandes.add(empreinte);
    final range = q.headers.value('range');
    rangesRecus.add(range);
    var contenu = fichiers[empreinte];
    if (contenu == null) return _probleme(q.response, 404, 'introuvable');
    if (servirFichierAbime) contenu = [...contenu]..[0] ^= 0xff;
    var debut = 0;
    final r = q.response;
    final m = RegExp(r'bytes=(\d+)-').firstMatch(range ?? '');
    if (m != null) {
      debut = int.parse(m.group(1)!);
      if (debut >= contenu.length) {
        r.statusCode = 416;
        return r.close();
      }
      r.statusCode = 206;
      r.headers.set('content-range', 'bytes $debut-${contenu.length - 1}/${contenu.length}');
    }
    r.headers.contentType = ContentType.binary;
    r.headers.contentLength = contenu.length - debut;
    final morceau = contenu.sublist(debut);
    final coupure = couperFichierApres;
    if (coupure != null && coupure < morceau.length) {
      couperFichierApres = null;
      // On annonce tout le fichier mais on n'en envoie qu'une partie : la connexion se ferme en cours de route.
      r.add(morceau.sublist(0, coupure));
      try {
        await r.close();
      } catch (_) {}
      return;
    }
    r.add(morceau);
    await r.close();
  }
}
