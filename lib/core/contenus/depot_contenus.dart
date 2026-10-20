import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../api/modeles.dart';

/// État du hors-ligne pour un cours.
enum EtatHorsLigne { aucun, partiel, complet, miseAJour }

/// Contenus des cours sur le téléphone, communs à tous les profils.
///
/// Chaque fichier est rangé par son empreinte SHA-256 (`objets/ab/abcd…`) : un fichier présent dans deux cours,
/// ou déjà téléchargé par un autre profil, n'est jamais téléchargé ni stocké deux fois. Les manifests des cours
/// téléchargés sont gardés dans `manifestes/` ; un fichier qu'aucun manifest n'utilise plus est supprimé.
class DepotContenus {
  DepotContenus(this.racine);

  final Directory racine;

  Directory get _objets => Directory(p.join(racine.path, 'objets'));
  Directory get _temporaires => Directory(p.join(racine.path, 'temporaires'));
  Directory get _manifestes => Directory(p.join(racine.path, 'manifestes'));
  Directory get _scorm => Directory(p.join(racine.path, 'scorm'));

  File fichierObjet(String empreinte) => File(p.join(_objets.path, empreinte.substring(0, 2), empreinte));
  File fichierPartiel(String empreinte) => File(p.join(_temporaires.path, '$empreinte.part'));

  bool possede(String empreinte) => fichierObjet(empreinte).existsSync();

  /// Range un fichier téléchargé et vérifié à sa place définitive.
  Future<File> ranger(File source, String empreinte) async {
    final cible = fichierObjet(empreinte);
    await cible.parent.create(recursive: true);
    return source.rename(cible.path);
  }

  Future<void> preparer() async {
    for (final d in [_objets, _temporaires, _manifestes, _scorm]) {
      await d.create(recursive: true);
    }
  }

  // ───────── Manifests ─────────

  File _fichierManifest(int coursId) => File(p.join(_manifestes.path, '$coursId.json'));

  /// Manifest du cours tel qu'il a été téléchargé (ou mis en cache pour afficher les leçons).
  Manifest? manifestLocal(int coursId) {
    final f = _fichierManifest(coursId);
    if (!f.existsSync()) return null;
    try {
      return Manifest.fromJson(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
    } on FormatException {
      return null;
    }
  }

  Future<void> enregistrerManifest(Manifest m) async {
    await _manifestes.create(recursive: true);
    final tmp = File('${_fichierManifest(m.coursId).path}.tmp');
    await tmp.writeAsString(jsonEncode(m.toJson()), flush: true);
    await tmp.rename(_fichierManifest(m.coursId).path);
  }

  /// Fichiers du manifest qui ne sont pas encore sur le téléphone.
  List<Fichier> manquants(Manifest m) => [
    for (final f in m.fichiersDistincts.values)
      if (!possede(f.empreinte)) f,
  ];

  /// Octets qui restent à télécharger (en tenant compte des morceaux déjà reçus).
  int octetsManquants(Manifest m) {
    var total = 0;
    for (final f in manquants(m)) {
      final partiel = fichierPartiel(f.empreinte);
      total += f.taille - (partiel.existsSync() ? partiel.lengthSync().clamp(0, f.taille) : 0);
    }
    return total;
  }

  EtatHorsLigne etat(int coursId, {String? versionServeur}) {
    final m = manifestLocal(coursId);
    if (m == null || m.fichiersDistincts.isEmpty) return EtatHorsLigne.aucun;
    final presents = m.fichiersDistincts.keys.where(possede).length;
    if (presents == 0 && m.fichiersDistincts.isNotEmpty) return EtatHorsLigne.aucun;
    if (presents < m.fichiersDistincts.length) return EtatHorsLigne.partiel;
    if (versionServeur != null && versionServeur.isNotEmpty && versionServeur != m.version) {
      return EtatHorsLigne.miseAJour;
    }
    return EtatHorsLigne.complet;
  }

  /// Une leçon est lisible hors ligne si tous ses fichiers sont là.
  bool leconDisponible(Lecon l) =>
      l.horsLigne && l.fichiers.isNotEmpty && l.fichiers.every((f) => possede(f.empreinte));

  // ───────── SCORM ─────────

  /// Dossier où le paquet SCORM est décompressé (une seule fois, partagé entre profils).
  Future<Directory> extraireScorm(String empreinte) async {
    final cible = Directory(p.join(_scorm.path, empreinte));
    if (cible.existsSync()) return cible;
    final tmp = Directory('${cible.path}.tmp');
    if (tmp.existsSync()) await tmp.delete(recursive: true);
    await tmp.create(recursive: true);
    final archive = ZipDecoder().decodeStream(InputFileStream(fichierObjet(empreinte).path));
    final base = p.canonicalize(tmp.path);
    for (final entree in archive) {
      final chemin = p.canonicalize(p.join(base, entree.name));
      // Protection : aucun fichier ne doit sortir du dossier (« zip slip »).
      if (!p.isWithin(base, chemin)) continue;
      if (entree.isFile) {
        await File(chemin).parent.create(recursive: true);
        final sortie = OutputFileStream(chemin);
        entree.writeContent(sortie);
        await sortie.close();
      }
    }
    await archive.clear();
    await tmp.rename(cible.path);
    return cible;
  }

  Directory dossierScorm(String empreinte) => Directory(p.join(_scorm.path, empreinte));

  // ───────── Ménage ─────────

  /// Retire un cours du téléphone, puis supprime les fichiers qu'aucun autre cours n'utilise.
  Future<void> supprimerCours(int coursId) async {
    final f = _fichierManifest(coursId);
    if (f.existsSync()) await f.delete();
    await nettoyer();
  }

  /// Supprime les fichiers, morceaux et dossiers SCORM qu'aucun manifest n'utilise.
  Future<int> nettoyer() async {
    final utiles = <String>{};
    if (_manifestes.existsSync()) {
      for (final f in _manifestes.listSync().whereType<File>().where((f) => f.path.endsWith('.json'))) {
        try {
          final m = Manifest.fromJson(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
          utiles.addAll(m.fichiersDistincts.keys);
        } on FormatException {
          continue;
        }
      }
    }
    var liberes = 0;
    for (final dossier in [_objets, _temporaires]) {
      if (!dossier.existsSync()) continue;
      for (final f in dossier.listSync(recursive: true).whereType<File>()) {
        final nom = p.basename(f.path).replaceAll('.part', '');
        if (!utiles.contains(nom)) {
          liberes += f.lengthSync();
          f.deleteSync();
        }
      }
    }
    if (_scorm.existsSync()) {
      for (final d in _scorm.listSync().whereType<Directory>()) {
        if (!utiles.contains(p.basename(d.path))) d.deleteSync(recursive: true);
      }
    }
    return liberes;
  }

  /// Place occupée par les contenus.
  int tailleTotale() {
    if (!racine.existsSync()) return 0;
    return racine.listSync(recursive: true).whereType<File>().fold(0, (s, f) => s + f.lengthSync());
  }
}

/// SHA-256 d'un fichier, lu par morceaux (pas de gros fichier en mémoire).
Future<String> empreinteFichier(File f) async => (await sha256.bind(f.openRead()).first).toString();
