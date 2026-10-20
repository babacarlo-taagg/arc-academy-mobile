import 'package:flutter/material.dart';

import '../core/api/modeles.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';

/// Encadré de message (erreur, information) lisible d'un coup d'œil.
class Encadre extends StatelessWidget {
  const Encadre({super.key, required this.texte, this.icone = Icons.info_outline_rounded, this.attention = false});

  final String texte;
  final IconData icone;
  final bool attention;

  @override
  Widget build(BuildContext context) {
    final couleur = attention ? ArcCouleurs.attention : ArcCouleurs.primaire;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: attention ? ArcCouleurs.attentionClair : ArcCouleurs.primaireClair,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleur),
          const SizedBox(width: 10),
          Expanded(child: Text(texte, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// Barre de progression épaisse avec le pourcentage.
class BarreProgression extends StatelessWidget {
  const BarreProgression({super.key, required this.pourcent});

  final int pourcent;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: pourcent / 100, minHeight: 10),
          ),
        ),
        const SizedBox(width: 12),
        Text(t.progressionPourcent(pourcent), style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

IconData iconeLecon(TypeLecon type) => switch (type) {
  TypeLecon.article => Icons.article_outlined,
  TypeLecon.pdf => Icons.picture_as_pdf_outlined,
  TypeLecon.video => Icons.play_circle_outline_rounded,
  TypeLecon.scorm => Icons.touch_app_outlined,
  TypeLecon.quiz => Icons.quiz_outlined,
  TypeLecon.certification => Icons.workspace_premium_outlined,
  TypeLecon.autre => Icons.description_outlined,
};

String libelleType(AppLocalizations t, TypeLecon type) => switch (type) {
  TypeLecon.article => t.typeArticle,
  TypeLecon.pdf => t.typePdf,
  TypeLecon.video => t.typeVideo,
  TypeLecon.scorm => t.typeScorm,
  TypeLecon.quiz => t.typeQuiz,
  TypeLecon.certification => t.typeCertification,
  TypeLecon.autre => t.typeAutre,
};
