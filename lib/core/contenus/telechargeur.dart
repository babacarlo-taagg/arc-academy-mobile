import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../api/modeles.dart';
import 'depot_contenus.dart';

class PlaceInsuffisante implements Exception {
  const PlaceInsuffisante({required this.necessaire, required this.libre});
  final int necessaire;
  final int libre;
}

class EmpreinteIncorrecte implements Exception {
  const EmpreinteIncorrecte(this.empreinte);
  final String empreinte;
}

/// Coupure réseau pendant le téléchargement : les morceaux reçus sont gardés, la reprise repartira de là.
class TelechargementInterrompu implements Exception {
  const TelechargementInterrompu([this.cause]);
  final Object? cause;
}

/// Avancement d'un téléchargement de cours.
class Progres {
  const Progres({required this.recus, required this.total, required this.fichiersFaits, required this.fichiers});
  final int recus;
  final int total;
  final int fichiersFaits;
  final int fichiers;
  double get fraction => total == 0 ? 1 : (recus / total).clamp(0, 1);
}

/// Télécharge les fichiers d'un cours, un par un, avec reprise (`Range`) après une coupure.
///
/// - seuls les fichiers absents du téléphone sont demandés (mise à jour différentielle) ;
/// - chaque fichier est d'abord écrit dans `temporaires/<empreinte>.part`, puis vérifié (taille et SHA-256)
///   avant d'être rangé : un fichier abîmé n'est jamais utilisé ;
/// - après une coupure, la suite du fichier est demandée à partir de l'octet déjà reçu.
class Telechargeur {
  Telechargeur({
    required this.depot,
    required this.api,
    this.placeLibre,
    this.margeSecurite = 50 * 1024 * 1024,
    this.essaisParFichier = 3,
    this.attente = _attenteParDefaut,
  });

  final DepotContenus depot;
  final ApiClient api;

  /// Octets libres sur le téléphone (null : inconnu).
  final Future<int?> Function()? placeLibre;

  /// Place à laisser libre en plus (le téléphone doit continuer à vivre).
  final int margeSecurite;
  final int essaisParFichier;
  final Duration Function(int essai) attente;

  static Duration _attenteParDefaut(int essai) => Duration(seconds: 2 << (essai - 1));

  /// Vérifie la place libre avant de commencer.
  Future<void> verifierPlace(Manifest m) async {
    final libre = await placeLibre?.call();
    if (libre == null) return;
    final besoin = depot.octetsManquants(m) + margeSecurite;
    if (libre < besoin) throw PlaceInsuffisante(necessaire: besoin, libre: libre);
  }

  Future<void> telechargerCours(Manifest m, {void Function(Progres)? onProgres, CancelToken? annulation}) async {
    await depot.preparer();
    // Le manifest est gardé tout de suite : ce qui est déjà là sert hors ligne, et la reprise sait quoi faire.
    await depot.enregistrerManifest(m);
    await verifierPlace(m);
    final aFaire = depot.manquants(m);
    final total = aFaire.fold<int>(0, (s, f) => s + f.taille);
    var dejaFaits = 0;
    var octetsFaits = 0;
    for (final f in aFaire) {
      await telechargerFichier(
        f,
        annulation: annulation,
        onOctets: (n) => onProgres?.call(
          Progres(recus: octetsFaits + n, total: total, fichiersFaits: dejaFaits, fichiers: aFaire.length),
        ),
      );
      octetsFaits += f.taille;
      dejaFaits++;
      onProgres?.call(Progres(recus: octetsFaits, total: total, fichiersFaits: dejaFaits, fichiers: aFaire.length));
    }
    for (final l in m.lecons.where((l) => l.type == TypeLecon.scorm && l.fichiers.isNotEmpty)) {
      await depot.extraireScorm(l.fichiers.first.empreinte);
    }
    await depot.nettoyer();
  }

  /// Télécharge un fichier, en reprenant là où il s'était arrêté. Réessaie quelques fois avant d'abandonner.
  Future<File> telechargerFichier(Fichier f, {CancelToken? annulation, void Function(int octets)? onOctets}) async {
    if (depot.possede(f.empreinte)) return depot.fichierObjet(f.empreinte);
    for (var essai = 1; ; essai++) {
      try {
        return await _unEssai(f, annulation, onOctets);
      } on TelechargementInterrompu {
        if (annulation?.isCancelled ?? false) rethrow;
        if (essai >= essaisParFichier) rethrow;
        await Future<void>.delayed(attente(essai));
      }
    }
  }

  Future<File> _unEssai(Fichier f, CancelToken? annulation, void Function(int)? onOctets) async {
    final partiel = depot.fichierPartiel(f.empreinte);
    await partiel.parent.create(recursive: true);
    var debut = partiel.existsSync() ? partiel.lengthSync() : 0;
    if (debut > f.taille) {
      await partiel.delete();
      debut = 0;
    }
    if (debut < f.taille) {
      Response<ResponseBody> r;
      try {
        r = await api.dio.get<ResponseBody>(
          '/fichiers/${f.empreinte}',
          cancelToken: annulation,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: const Duration(seconds: 30),
            headers: {if (debut > 0) 'Range': 'bytes=$debut-'},
          ),
        );
      } on DioException catch (e) {
        final erreur = ApiException.fromDio(e);
        if (erreur.estReseau || e.type == DioExceptionType.cancel) throw TelechargementInterrompu(e);
        if (e.response?.statusCode == 416) {
          // Le serveur dit que tout est déjà reçu : on passe à la vérification.
          return _verifierEtRanger(f, partiel);
        }
        throw erreur;
      }
      // 200 : le serveur renvoie tout depuis le début (il ne gère pas Range pour ce fichier).
      final mode = r.statusCode == 206 ? FileMode.append : FileMode.write;
      if (mode == FileMode.write) debut = 0;
      final sortie = partiel.openWrite(mode: mode);
      var recus = debut;
      try {
        await for (final Uint8List morceau in r.data!.stream) {
          sortie.add(morceau);
          recus += morceau.length;
          onOctets?.call(recus);
        }
        await sortie.flush();
      } catch (e) {
        throw TelechargementInterrompu(e);
      } finally {
        await sortie.close();
      }
    }
    return _verifierEtRanger(f, partiel);
  }

  Future<File> _verifierEtRanger(Fichier f, File partiel) async {
    final taille = partiel.lengthSync();
    if (taille < f.taille) throw const TelechargementInterrompu('fichier incomplet');
    if (taille != f.taille || await empreinteFichier(partiel) != f.empreinte) {
      await partiel.delete();
      throw EmpreinteIncorrecte(f.empreinte);
    }
    return depot.ranger(partiel, f.empreinte);
  }
}
