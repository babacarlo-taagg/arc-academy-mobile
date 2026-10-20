import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/services.dart';
import '../core/theme.dart';
import '../l10n/app_localizations.dart';

/// Bandeau toujours visible : « Tout est envoyé » ou « 3 éléments en attente ».
class IndicateurSynchro extends ConsumerWidget {
  const IndicateurSynchro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final enAttente = ref.watch(enAttenteProvider).value ?? 0;
    final envoi = ref.watch(envoiEnCoursProvider).value ?? false;
    final reseau = ref.watch(reseauProvider).value ?? TypeReseau.wifi;
    final ok = enAttente == 0;
    final (icone, texte, couleur, fond) = switch ((ok, envoi, reseau)) {
      (true, _, _) => (Icons.cloud_done_rounded, t.synchroToutEnvoye, ArcCouleurs.primaire, ArcCouleurs.primaireClair),
      (false, true, _) => (
        Icons.cloud_upload_rounded,
        t.synchroEnvoiEnCours,
        ArcCouleurs.primaire,
        ArcCouleurs.primaireClair,
      ),
      (false, false, _) => (
        Icons.schedule_rounded,
        t.synchroEnAttente(enAttente),
        ArcCouleurs.attention,
        ArcCouleurs.attentionClair,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: InkWell(
        onTap: ok ? null : () => ref.read(profilOuvertProvider)?.moteur.envoyer(),
        child: Container(
          width: double.infinity,
          color: fond,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icone, color: couleur, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  texte,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: couleur, fontWeight: FontWeight.w600),
                ),
              ),
              if (reseau == TypeReseau.aucun) ...[
                const Icon(Icons.signal_cellular_off_rounded, size: 20, color: ArcCouleurs.texteDiscret),
                const SizedBox(width: 6),
                Text(t.synchroHorsLigne, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
