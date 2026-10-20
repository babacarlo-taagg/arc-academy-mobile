import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Réglages du téléphone, communs aux profils (aucune donnée personnelle) : Wi-Fi seulement, taille du texte,
/// données consommées par mois.
class Reglages {
  Reglages(this._fichier);

  final File _fichier;

  bool wifiSeulement = true;

  /// Facteur de taille du texte des articles (1 = normal).
  double tailleTexte = 1.15;

  /// Octets échangés avec le serveur, par mois (`2026-10` → octets).
  final Map<String, int> octetsParMois = {};

  Timer? _sauvegarde;
  final _changements = StreamController<void>.broadcast();
  Stream<void> get changements => _changements.stream;

  static String cleMois(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';

  int octetsDuMois([DateTime? d]) => octetsParMois[cleMois(d ?? DateTime.now())] ?? 0;

  Future<void> charger() async {
    if (!_fichier.existsSync()) return;
    try {
      final j = jsonDecode(await _fichier.readAsString()) as Map<String, dynamic>;
      wifiSeulement = j['wifiSeulement'] as bool? ?? true;
      tailleTexte = (j['tailleTexte'] as num?)?.toDouble() ?? 1.15;
      octetsParMois
        ..clear()
        ..addAll({
          for (final e in (j['octetsParMois'] as Map? ?? const {}).entries) '${e.key}': (e.value as num).toInt(),
        });
    } on FormatException {
      // fichier abîmé : on repart des valeurs par défaut
    }
  }

  void ajouterOctets(int n) {
    final cle = cleMois(DateTime.now());
    octetsParMois[cle] = (octetsParMois[cle] ?? 0) + n;
    _planifierSauvegarde();
  }

  void modifier({bool? wifiSeulement, double? tailleTexte}) {
    if (wifiSeulement != null) this.wifiSeulement = wifiSeulement;
    if (tailleTexte != null) this.tailleTexte = tailleTexte;
    _planifierSauvegarde(immediat: true);
  }

  void _planifierSauvegarde({bool immediat = false}) {
    if (!_changements.isClosed) _changements.add(null);
    _sauvegarde?.cancel();
    _sauvegarde = Timer(immediat ? Duration.zero : const Duration(seconds: 2), sauvegarder);
  }

  Future<void> sauvegarder() async {
    _sauvegarde?.cancel();
    // On ne garde que les 12 derniers mois.
    final mois = octetsParMois.keys.toList()..sort();
    for (final ancien in mois.take(mois.length > 12 ? mois.length - 12 : 0)) {
      octetsParMois.remove(ancien);
    }
    await _fichier.parent.create(recursive: true);
    final tmp = File('${_fichier.path}.tmp');
    await tmp.writeAsString(
      jsonEncode({'wifiSeulement': wifiSeulement, 'tailleTexte': tailleTexte, 'octetsParMois': octetsParMois}),
      flush: true,
    );
    await tmp.rename(_fichier.path);
  }
}
