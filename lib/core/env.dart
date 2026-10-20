/// Réglages qui changent selon l'environnement.
///
/// Passés au lancement, jamais écrits dans le code :
///   flutter run --dart-define=API_BASE_URL=https://2-28-114-138.sslip.io/api/v1
///
/// Par défaut, l'appli vise le serveur bouchon lancé sur l'ordinateur :
/// `10.0.2.2` est l'adresse de l'ordinateur vue depuis l'émulateur Android.
class Env {
  const Env._();

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:4010');

  /// Vrai quand l'appli parle au bouchon Prism (routes servies à la racine).
  static bool get isMock => !apiBaseUrl.contains('/api/v1');

  /// Délai au-delà duquel une requête est considérée perdue (réseau 2G/3G instable).
  static const requestTimeout = Duration(seconds: 15);

  /// Délai pour un fichier de cours : on attend plus longtemps les premiers octets.
  static const telechargementTimeout = Duration(seconds: 30);
}
