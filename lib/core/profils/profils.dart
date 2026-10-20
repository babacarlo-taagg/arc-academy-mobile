import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../api/modeles.dart';
import 'coffre_fort.dart';

/// Un profil du téléphone (un apprenant). Rien de sensible ici : nom et e-mail pour la liste des profils.
class Profil {
  const Profil({required this.id, required this.apprenantId, required this.nom, required this.email});

  final String id;
  final int apprenantId;
  final String nom;
  final String email;

  factory Profil.fromJson(Map<String, dynamic> j) => Profil(
    id: j['id'] as String,
    apprenantId: (j['apprenantId'] as num).toInt(),
    nom: j['nom'] as String? ?? '',
    email: j['email'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'apprenantId': apprenantId, 'nom': nom, 'email': email};

  /// Initiales affichées dans la pastille du profil.
  String get initiales {
    final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).toList();
    if (mots.isEmpty) return '?';
    return (mots.first[0] + (mots.length > 1 ? mots.last[0] : '')).toUpperCase();
  }
}

/// Résultat d'un essai de PIN.
class ResultatPin {
  const ResultatPin.bon() : ok = true, attente = Duration.zero, essaisAvantAttente = 0;
  const ResultatPin.mauvais({required this.attente, required this.essaisAvantAttente}) : ok = false;

  final bool ok;

  /// Temps à attendre avant le prochain essai (zéro si on peut réessayer tout de suite).
  final Duration attente;
  final int essaisAvantAttente;
}

/// Profils du téléphone partagé : liste, jetons de session, clé de la base, PIN.
///
/// Modèle de sécurité : la clé de la base de chaque profil est tirée au hasard et rangée dans le coffre-fort
/// du système (Keystore Android / trousseau iOS, liés à l'appareil). Le PIN (4 à 6 chiffres) protège l'accès
/// dans l'appli : son empreinte PBKDF2 est gardée, et après 5 erreurs il faut attendre de plus en plus longtemps.
/// On ne dérive pas la clé de la base du PIN : un PIN de 6 chiffres se devine hors ligne en quelques minutes,
/// alors que le coffre-fort du système empêche de lire la base hors du téléphone, et la synchronisation en
/// tâche de fond peut ouvrir la base sans PIN.
class ProfilStore {
  ProfilStore(this._coffre, {DateTime Function()? horloge}) : _horloge = horloge ?? DateTime.now;

  final CoffreFort _coffre;
  final DateTime Function() _horloge;

  static const essaisLibres = 5;
  static const iterationsPin = 20000;

  Future<String> appareilId() async {
    final existant = await _coffre.lire('appareil_id');
    if (existant != null) return existant;
    final id = const Uuid().v4();
    await _coffre.ecrire('appareil_id', id);
    return id;
  }

  Future<List<Profil>> profils() async {
    final brut = await _coffre.lire('profils');
    if (brut == null) return [];
    return [for (final p in jsonDecode(brut) as List) Profil.fromJson((p as Map).cast<String, dynamic>())];
  }

  Future<Profil?> profil(String id) async {
    for (final p in await profils()) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _enregistrerListe(List<Profil> liste) =>
      _coffre.ecrire('profils', jsonEncode([for (final p in liste) p.toJson()]));

  /// Crée le profil de cet apprenant (ou le met à jour s'il existe déjà) et range les jetons.
  Future<Profil> ouvrirSession(Session session) async {
    final a = session.apprenant;
    final profil = Profil(id: 'p${a.id}', apprenantId: a.id, nom: a.nom, email: a.email);
    final liste = await profils();
    final i = liste.indexWhere((p) => p.id == profil.id);
    if (i >= 0) {
      liste[i] = profil;
    } else {
      liste.add(profil);
    }
    await _enregistrerListe(liste);
    if (await _coffre.lire('${profil.id}.cle') == null) {
      await _coffre.ecrire('${profil.id}.cle', _aleatoireHex(32));
    }
    await enregistrerJetons(profil.id, acces: session.jetonAcces, rafraichissement: session.jetonRafraichissement);
    return profil;
  }

  Future<void> enregistrerJetons(String profilId, {required String acces, required String rafraichissement}) async {
    await _coffre.ecrire('$profilId.acces', acces);
    await _coffre.ecrire('$profilId.rafraichissement', rafraichissement);
  }

  Future<String?> jetonAcces(String profilId) => _coffre.lire('$profilId.acces');
  Future<String?> jetonRafraichissement(String profilId) => _coffre.lire('$profilId.rafraichissement');

  /// Session fermée (déconnexion ou refus du serveur) : on garde le profil et ses données, sans jetons.
  Future<void> oublierJetons(String profilId) async {
    await _coffre.effacer('$profilId.acces');
    await _coffre.effacer('$profilId.rafraichissement');
  }

  /// Clé de la base du profil (64 caractères hexadécimaux).
  Future<String?> cleBase(String profilId) => _coffre.lire('$profilId.cle');

  Future<bool> pinDefini(String profilId) async => await _coffre.lire('$profilId.pin') != null;

  Future<void> definirPin(String profilId, String pin) async {
    final sel = _aleatoireHex(16);
    final empreinte = await compute(_pbkdf2Hex, _DemandePbkdf2(pin, sel, iterationsPin));
    await _coffre.ecrire(
      '$profilId.pin',
      jsonEncode({'sel': sel, 'empreinte': empreinte, 'iterations': iterationsPin}),
    );
    await _coffre.effacer('$profilId.essais');
  }

  /// Temps qu'il reste à attendre avant de pouvoir essayer un PIN.
  Future<Duration> attenteAvantEssai(String profilId) async {
    final essais = await _lireEssais(profilId);
    final bloque = essais.$2;
    if (bloque == null) return Duration.zero;
    final reste = bloque.difference(_horloge());
    return reste.isNegative ? Duration.zero : reste;
  }

  Future<ResultatPin> verifierPin(String profilId, String pin) async {
    final attente = await attenteAvantEssai(profilId);
    if (attente > Duration.zero) return ResultatPin.mauvais(attente: attente, essaisAvantAttente: 0);
    final brut = await _coffre.lire('$profilId.pin');
    if (brut == null) return const ResultatPin.mauvais(attente: Duration.zero, essaisAvantAttente: 0);
    final stocke = jsonDecode(brut) as Map<String, dynamic>;
    final calcule = await compute(
      _pbkdf2Hex,
      _DemandePbkdf2(pin, stocke['sel'] as String, (stocke['iterations'] as num).toInt()),
    );
    if (_egalTempsConstant(calcule, stocke['empreinte'] as String)) {
      await _coffre.effacer('$profilId.essais');
      return const ResultatPin.bon();
    }
    final nb = (await _lireEssais(profilId)).$1 + 1;
    DateTime? bloque;
    var nouvelleAttente = Duration.zero;
    if (nb >= essaisLibres) {
      // 30 s, puis 1 min, 2 min, 4 min… au plus 1 heure.
      final secondes = min(30 * pow(2, nb - essaisLibres).toInt(), 3600);
      nouvelleAttente = Duration(seconds: secondes);
      bloque = _horloge().add(nouvelleAttente);
    }
    await _coffre.ecrire('$profilId.essais', jsonEncode({'nb': nb, 'bloque': bloque?.toIso8601String()}));
    return ResultatPin.mauvais(attente: nouvelleAttente, essaisAvantAttente: max(essaisLibres - nb, 0));
  }

  Future<(int, DateTime?)> _lireEssais(String profilId) async {
    final brut = await _coffre.lire('$profilId.essais');
    if (brut == null) return (0, null);
    final j = jsonDecode(brut) as Map<String, dynamic>;
    return ((j['nb'] as num).toInt(), DateTime.tryParse(j['bloque'] as String? ?? ''));
  }

  /// Retire le profil du téléphone (la base et les fichiers propres au profil sont effacés par l'appelant).
  Future<void> effacerProfil(String profilId) async {
    for (final suffixe in ['cle', 'acces', 'rafraichissement', 'pin', 'essais']) {
      await _coffre.effacer('$profilId.$suffixe');
    }
    final liste = await profils()
      ..removeWhere((p) => p.id == profilId);
    await _enregistrerListe(liste);
  }

  static String _aleatoireHex(int octets) {
    final r = Random.secure();
    return [for (var i = 0; i < octets; i++) r.nextInt(256).toRadixString(16).padLeft(2, '0')].join();
  }

  static bool _egalTempsConstant(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

class _DemandePbkdf2 {
  const _DemandePbkdf2(this.pin, this.sel, this.iterations);
  final String pin;
  final String sel;
  final int iterations;
}

/// PBKDF2-HMAC-SHA256 (RFC 8018), un seul bloc de 32 octets.
String _pbkdf2Hex(_DemandePbkdf2 d) {
  final hmac = Hmac(sha256, utf8.encode(d.pin));
  final sel = utf8.encode(d.sel);
  var u = Uint8List.fromList(hmac.convert([...sel, 0, 0, 0, 1]).bytes);
  final resultat = Uint8List.fromList(u);
  for (var i = 1; i < d.iterations; i++) {
    u = Uint8List.fromList(hmac.convert(u).bytes);
    for (var k = 0; k < resultat.length; k++) {
      resultat[k] ^= u[k];
    }
  }
  return [for (final o in resultat) o.toRadixString(16).padLeft(2, '0')].join();
}

/// Exposé pour les tests (vecteurs connus).
@visibleForTesting
String pbkdf2Sha256Hex(String motDePasse, String sel, int iterations) =>
    _pbkdf2Hex(_DemandePbkdf2(motDePasse, sel, iterations));
