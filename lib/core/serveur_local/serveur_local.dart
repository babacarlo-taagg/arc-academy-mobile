import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../api/modeles.dart';
import '../contenus/depot_contenus.dart';

/// Reçoit un enregistrement SCORM (format « commit » de scorm-again) et rend l'état fusionné.
typedef SurCommitScorm = Future<void> Function(int coursId, int leconId, Map<String, dynamic> commit);

/// Petit serveur web sur le téléphone (`127.0.0.1`, port au hasard) qui sert les contenus téléchargés à la
/// WebView, sans réseau.
///
/// Les modules Articulate refusent souvent de tourner depuis `file://` (le navigateur bloque leurs chargements) :
/// servis en `http://127.0.0.1`, ils marchent comme sur le site. Toutes les adresses commencent par un jeton
/// tiré au hasard à chaque lancement : une autre appli du téléphone ne peut pas lire les contenus.
///
/// Adresses :
/// - `/<jeton>/lecon/<cours>/<leçon>/<chemin>` : fichier d'une leçon (article, PDF), retrouvé par empreinte ;
/// - `/<jeton>/scorm/<cours>/<leçon>/lanceur.html` : page qui charge scorm-again et le module ;
/// - `/<jeton>/scorm/<cours>/<leçon>/contenu/<chemin>` : fichiers du paquet décompressé ;
/// - `POST /<jeton>/scorm/<cours>/<leçon>/commit` : enregistrement du module, écrit dans la base du profil ;
/// - `/<jeton>/outils/scorm-again.min.js`.
class ServeurLocal {
  ServeurLocal({required this.depot, required this.lecon, required this.scormAgain, String? jeton})
    : jeton = jeton ?? _jetonAleatoire();

  final DepotContenus depot;

  /// Retrouve une leçon dans les manifests du téléphone.
  final Lecon? Function(int coursId, int leconId) lecon;

  /// Contenu de scorm-again (lu dans les assets de l'appli).
  final Future<List<int>> Function() scormAgain;
  final String jeton;

  /// Branché par le profil ouvert ; sans profil, les enregistrements sont refusés.
  SurCommitScorm? surCommit;

  /// État sauvegardé (cmi) et identité, pour la reprise d'un module.
  Future<Map<String, dynamic>> Function(int coursId, int leconId)? configScorm;

  HttpServer? _serveur;

  int get port => _serveur?.port ?? 0;
  String get base => 'http://127.0.0.1:$port/$jeton';

  String urlLecon(int coursId, int leconId, String chemin) => '$base/lecon/$coursId/$leconId/$chemin';
  String urlScorm(int coursId, int leconId) => '$base/scorm/$coursId/$leconId/lanceur.html';

  static String _jetonAleatoire() {
    final r = Random.secure();
    return [for (var i = 0; i < 16; i++) r.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
  }

  Future<void> demarrer() async {
    if (_serveur != null) return;
    _serveur = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _serveur!.listen((requete) => _traiter(requete).catchError((Object _) {}));
  }

  Future<void> arreter() async {
    await _serveur?.close(force: true);
    _serveur = null;
  }

  Future<void> _traiter(HttpRequest requete) async {
    final r = requete.response;
    r.headers.set('Cache-Control', 'no-store');
    try {
      final morceaux = requete.uri.pathSegments;
      if (morceaux.length < 2 || morceaux.first != jeton) return await _erreur(r, HttpStatus.notFound);
      final suite = morceaux.sublist(1);
      if (suite.length == 2 && suite[0] == 'outils' && suite[1] == 'scorm-again.min.js') {
        r.headers.contentType = ContentType('text', 'javascript', charset: 'utf-8');
        r.add(await scormAgain());
        return await r.close();
      }
      if (suite.length < 4) return await _erreur(r, HttpStatus.notFound);
      final coursId = int.tryParse(suite[1]);
      final leconId = int.tryParse(suite[2]);
      final l = coursId == null || leconId == null ? null : lecon(coursId, leconId);
      if (l == null) return await _erreur(r, HttpStatus.notFound);
      final reste = suite.sublist(3);
      if (suite[0] == 'lecon') return await _servirFichierLecon(r, l, reste.join('/'));
      if (suite[0] == 'scorm') {
        if (reste.length == 1 && reste.first == 'lanceur.html') return await _servirLanceur(r, coursId!, l);
        if (reste.length == 1 && reste.first == 'commit' && requete.method == 'POST') {
          return await _recevoirCommit(requete, coursId!, l);
        }
        if (reste.length > 1 && reste.first == 'contenu') return await _servirScorm(r, l, reste.sublist(1));
      }
      return await _erreur(r, HttpStatus.notFound);
    } catch (_) {
      return await _erreur(r, HttpStatus.internalServerError);
    }
  }

  Future<void> _erreur(HttpResponse r, int statut) async {
    r.statusCode = statut;
    await r.close();
  }

  Future<void> _servirFichierLecon(HttpResponse r, Lecon l, String chemin) async {
    final fichier = l.fichiers.where((f) => f.chemin == chemin).firstOrNull;
    if (fichier == null || !depot.possede(fichier.empreinte)) return _erreur(r, HttpStatus.notFound);
    r.headers.contentType = ContentType.parse(_typeMime(chemin, fichier.typeMime));
    await r.addStream(depot.fichierObjet(fichier.empreinte).openRead());
    await r.close();
  }

  Future<void> _servirScorm(HttpResponse r, Lecon l, List<String> chemin) async {
    if (l.fichiers.isEmpty) return _erreur(r, HttpStatus.notFound);
    final dossier = depot.dossierScorm(l.fichiers.first.empreinte);
    final base = p.canonicalize(dossier.path);
    final cible = p.canonicalize(p.joinAll([base, ...chemin.map(Uri.decodeComponent)]));
    if (!p.isWithin(base, cible) || !File(cible).existsSync()) return _erreur(r, HttpStatus.notFound);
    r.headers.contentType = ContentType.parse(_typeMime(cible, null));
    await r.addStream(File(cible).openRead());
    await r.close();
  }

  Future<void> _servirLanceur(HttpResponse r, int coursId, Lecon l) async {
    final config = {
      'version': l.scormVersion ?? '1.2',
      'commitUrl': '$base/scorm/$coursId/${l.id}/commit',
      'launchUrl': '$base/scorm/$coursId/${l.id}/contenu/${l.entree ?? 'index.html'}',
      ...?await configScorm?.call(coursId, l.id),
    };
    r.headers.contentType = ContentType.html;
    r.write(pageLanceur(jsonEncode(config), '$base/outils/scorm-again.min.js'));
    await r.close();
  }

  Future<void> _recevoirCommit(HttpRequest requete, int coursId, Lecon l) async {
    final r = requete.response;
    final rappel = surCommit;
    r.headers.contentType = ContentType.json;
    if (rappel == null) {
      r.write(jsonEncode({'result': false, 'errorCode': 101}));
      return r.close();
    }
    final corps = await utf8.decodeStream(requete);
    final commit = jsonDecode(corps);
    if (commit is! Map) {
      r.write(jsonEncode({'result': false, 'errorCode': 101}));
      return r.close();
    }
    await rappel(coursId, l.id, commit.cast<String, dynamic>());
    r.write(jsonEncode({'result': true, 'errorCode': 0}));
    await r.close();
  }

  static String _typeMime(String chemin, String? defaut) {
    final ext = p.extension(chemin.split('?').first).toLowerCase();
    return switch (ext) {
      '.html' || '.htm' => 'text/html; charset=utf-8',
      '.js' || '.mjs' => 'text/javascript; charset=utf-8',
      '.css' => 'text/css; charset=utf-8',
      '.json' => 'application/json',
      '.xml' || '.xsd' => 'application/xml',
      '.png' => 'image/png',
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      '.svg' => 'image/svg+xml',
      '.woff' => 'font/woff',
      '.woff2' => 'font/woff2',
      '.ttf' => 'font/ttf',
      '.mp4' => 'video/mp4',
      '.webm' => 'video/webm',
      '.mp3' => 'audio/mpeg',
      '.m4a' => 'audio/mp4',
      '.vtt' => 'text/vtt',
      '.pdf' => 'application/pdf',
      _ => defaut ?? 'application/octet-stream',
    };
  }
}

/// Page qui expose l'API SCORM (window.API en 1.2, window.API_1484_11 en 2004) grâce à scorm-again, recharge
/// l'état sauvegardé, puis ouvre le module dans un cadre. Chaque enregistrement part vers le serveur local, qui
/// l'écrit dans la base du profil (même réglages que le lecteur web d'arc_scorm).
String pageLanceur(String configJson, String urlScormAgain) =>
    '''<!DOCTYPE html>
<html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Module</title>
<style>html,body{margin:0;height:100%;background:#fff}iframe{border:0;width:100%;height:100%;display:block}</style>
<script src="$urlScormAgain"></script>
<script>
(function () {
  "use strict";
  var config = $configJson;
  var is2004 = config.version === "2004";
  function lire(texte) {
    try { var c = JSON.parse(texte); return { result: !!c.result, errorCode: c.errorCode || 0 }; }
    catch (e) { return { result: false, errorCode: 101 }; }
  }
  var settings = {
    autocommit: true,
    autocommitSeconds: 30,
    logLevel: 4,
    renderCommonCommitFields: true,
    selfReportSessionTime: true,
    lmsCommitUrl: config.commitUrl,
    commitRequestDataType: "application/json;charset=UTF-8",
    terminationCommitContentType: "application/json;charset=UTF-8",
    xhrResponseHandler: function (xhr) { return lire(xhr.responseText); },
    responseHandler: function (response) { return response.text().then(lire); }
  };
  var api = is2004 ? new window.Scorm2004API(settings) : new window.Scorm12API(settings);
  var saved = (config.saved && config.saved.cmi) || null;
  if (saved) {
    var core = is2004 ? saved : saved.core || {};
    delete core.session_time; delete core.entry; delete core.exit;
    try { api.loadFromJSON(saved); } catch (e) { console.warn("Reprise impossible", e); }
  }
  var reprise = saved && (saved.suspend_data || (is2004 ? saved.location : (saved.core || {}).lesson_location));
  try {
    if (is2004) {
      api.cmi.learner_id = config.learnerId || ""; api.cmi.learner_name = config.learnerName || "";
      api.cmi.entry = reprise ? "resume" : "ab-initio";
    } else {
      api.cmi.core.student_id = config.learnerId || ""; api.cmi.core.student_name = config.learnerName || "";
      api.cmi.core.entry = reprise ? "resume" : "ab-initio";
    }
  } catch (e) {}
  if (is2004) { window.API_1484_11 = api; } else { window.API = api; }
  document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("module").src = config.launchUrl;
  });
})();
</script></head>
<body><iframe id="module" allow="fullscreen; autoplay" allowfullscreen></iframe></body></html>''';
