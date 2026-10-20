/// Règles de conflit écrites dans le contrat, appliquées de la même façon par le serveur et par l'appli :
/// - une leçon terminée le reste ;
/// - « réussi » ne redevient jamais « échoué » ;
/// - le meilleur score gagne ;
/// - l'état SCORM gardé pour la reprise est le plus avancé (à égalité, le plus récent) ;
/// - le temps passé ne recule pas.
library;

int rangCompletion(String? s) => switch (s) {
  'completed' => 2,
  'incomplete' => 1,
  _ => 0,
};

int rangReussite(String? s) => switch (s) {
  'passed' => 2,
  'failed' => 1,
  _ => 0,
};

/// État SCORM résumé, tel que gardé sur le téléphone.
class EtatScormLocal {
  const EtatScormLocal({
    this.completionStatus = 'unknown',
    this.successStatus = 'unknown',
    this.scorePourcent,
    this.totalTimeSeconds = 0,
    this.cmi,
  });

  final String completionStatus;
  final String successStatus;
  final double? scorePourcent;
  final int totalTimeSeconds;

  /// État cmi complet (JSON), pour la reprise.
  final String? cmi;

  /// Terminé au sens d'Odoo : module terminé ou réussi, et pas échoué.
  bool get estTermine => successStatus != 'failed' && (completionStatus == 'completed' || successStatus == 'passed');

  /// Le nouvel état est-il au moins aussi avancé que celui-ci ?
  bool estDepassePar(EtatScormLocal autre) {
    final a = (rangCompletion(completionStatus), rangReussite(successStatus));
    final b = (rangCompletion(autre.completionStatus), rangReussite(autre.successStatus));
    return b.$1 > a.$1 || (b.$1 == a.$1 && b.$2 >= a.$2);
  }
}

/// Fusionne un nouvel état (venu du module sur le téléphone, ou du serveur) avec l'état gardé.
EtatScormLocal fusionnerScorm(EtatScormLocal garde, EtatScormLocal nouveau) {
  final completion = rangCompletion(nouveau.completionStatus) > rangCompletion(garde.completionStatus)
      ? nouveau.completionStatus
      : garde.completionStatus;
  final reussite = rangReussite(nouveau.successStatus) > rangReussite(garde.successStatus)
      ? nouveau.successStatus
      : garde.successStatus;
  final double? score = switch ((garde.scorePourcent, nouveau.scorePourcent)) {
    (null, final n) => n,
    (final g, null) => g,
    (final g?, final n?) => n > g ? n : g,
  };
  final cmi = nouveau.cmi != null && garde.estDepassePar(nouveau) ? nouveau.cmi : (garde.cmi ?? nouveau.cmi);
  return EtatScormLocal(
    completionStatus: completion,
    successStatus: reussite,
    scorePourcent: score,
    totalTimeSeconds: nouveau.totalTimeSeconds > garde.totalTimeSeconds
        ? nouveau.totalTimeSeconds
        : garde.totalTimeSeconds,
    cmi: cmi,
  );
}

/// Score en pourcentage à partir du score SCORM (raw, min, max), comme le serveur.
double? scorePourcent(Map<String, dynamic>? score) {
  final raw = score?['raw'];
  if (raw is! num) return null;
  final min = (score!['min'] is num ? score['min'] as num : 0).toDouble();
  final max = (score['max'] is num ? score['max'] as num : 100).toDouble();
  final ecart = max - min;
  if (ecart == 0) return 0;
  return ((raw.toDouble() - min) / ecart * 100).clamp(0, 100).toDouble();
}
