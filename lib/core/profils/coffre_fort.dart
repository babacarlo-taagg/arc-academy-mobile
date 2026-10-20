import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Petit coffre-fort clé → texte : Keystore d'Android, trousseau d'iOS.
///
/// Abstrait pour que les tests utilisent une version en mémoire.
abstract class CoffreFort {
  Future<String?> lire(String cle);
  Future<void> ecrire(String cle, String valeur);
  Future<void> effacer(String cle);
}

class CoffreFortSysteme implements CoffreFort {
  CoffreFortSysteme() : _stockage = const FlutterSecureStorage();

  final FlutterSecureStorage _stockage;

  @override
  Future<String?> lire(String cle) => _stockage.read(key: cle);

  @override
  Future<void> ecrire(String cle, String valeur) => _stockage.write(key: cle, value: valeur);

  @override
  Future<void> effacer(String cle) => _stockage.delete(key: cle);
}

class CoffreFortMemoire implements CoffreFort {
  final Map<String, String> valeurs = {};

  @override
  Future<String?> lire(String cle) async => valeurs[cle];

  @override
  Future<void> ecrire(String cle, String valeur) async => valeurs[cle] = valeur;

  @override
  Future<void> effacer(String cle) async => valeurs.remove(cle);
}
