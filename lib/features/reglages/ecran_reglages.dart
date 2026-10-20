import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/services.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/indicateur_synchro.dart';

class EcranReglages extends ConsumerWidget {
  const EcranReglages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final services = ref.watch(servicesProvider);
    final reglages = ref.watch(reglagesProvider).value ?? services.reglages;
    final enAttente = ref.watch(enAttenteProvider).value ?? 0;
    final style = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.reglagesTitre)),
      body: Column(
        children: [
          const IndicateurSynchro(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  key: const Key('donnees_consommees'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.data_usage_rounded, size: 30),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.reglagesDonnees, style: style.titleMedium),
                              Text(tailleLisible(reglages.octetsDuMois()), style: style.headlineSmall),
                              Text(t.reglagesDonneesAide, style: style.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.wifi_rounded, size: 30),
                    title: Text(t.reglagesWifi, style: style.titleMedium),
                    subtitle: Text(t.reglagesWifiAide),
                    value: reglages.wifiSeulement,
                    onChanged: (v) => services.reglages.modifier(wifiSeulement: v),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.reglagesTailleTexte, style: style.titleMedium),
                        Slider(
                          value: reglages.tailleTexte,
                          min: 0.9,
                          max: 1.8,
                          divisions: 9,
                          label: '${(reglages.tailleTexte * 100).round()} %',
                          onChanged: (v) => services.reglages.modifier(tailleTexte: v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.outbox_rounded, size: 30),
                    title: Text(t.reglagesEnAttente, style: style.titleMedium),
                    trailing: Text('$enAttente', style: style.titleLarge),
                  ),
                ),
                if (enAttente > 0) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => ref.read(profilOuvertProvider)?.moteur.envoyer(),
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(t.reglagesEnvoyer),
                  ),
                ],
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sd_storage_outlined, size: 30),
                    title: Text(t.reglagesContenus, style: style.titleMedium),
                    trailing: Text(tailleLisible(services.depot.tailleTotale()), style: style.titleLarge),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(profilOuvertProvider.notifier).fermer();
                    if (context.mounted) context.go('/profils');
                  },
                  icon: const Icon(Icons.switch_account_rounded),
                  label: Text(t.autrePersonne),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                  onPressed: () => _deconnecter(context, ref, enAttente),
                  icon: const Icon(Icons.person_remove_outlined),
                  label: Text(t.reglagesDeconnexion),
                ),
                const SizedBox(height: 16),
                Center(child: Text(t.reglagesVersion(versionAppli), style: style.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deconnecter(BuildContext context, WidgetRef ref, int enAttente) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.reglagesDeconnexionConfirmer, style: Theme.of(c).textTheme.bodyLarge),
            if (enAttente > 0) ...[
              const SizedBox(height: 12),
              Text(
                t.reglagesDeconnexionEnAttente(enAttente),
                style: Theme.of(c).textTheme.bodyLarge?.copyWith(color: Theme.of(c).colorScheme.error),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(t.annuler)),
          FilledButton(onPressed: () => Navigator.of(c).pop(true), child: Text(t.confirmer)),
        ],
      ),
    );
    if (!(ok ?? false)) return;
    final ouvert = ref.read(profilOuvertProvider);
    try {
      await ouvert?.moteur.envoyer();
      await ouvert?.api.seDeconnecter();
    } catch (_) {
      // hors ligne : la session expirera d'elle-même côté serveur
    }
    await ref.read(profilOuvertProvider.notifier).effacer();
    if (context.mounted) context.go('/');
  }
}
