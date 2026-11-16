import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/modeles.dart';
import '../../core/notifications/service_notifications.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';
import '../../widgets/indicateur_synchro.dart';

ServiceNotifications? _service(WidgetRef ref) => ref.read(profilOuvertProvider)?.notifications;

/// Bouton « Mes messages » de la barre du haut, avec le nombre de messages non lus.
class BoutonMessages extends ConsumerWidget {
  const BoutonMessages({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final nonLues = ref.watch(notificationsProvider.select((n) => n.value?.nonLues ?? 0));
    return IconButton(
      key: const Key('bouton_messages'),
      tooltip: t.boiteTitre,
      icon: Badge(
        key: const Key('badge_messages'),
        isLabelVisible: nonLues > 0,
        label: Text(nonLues > 99 ? '99+' : '$nonLues'),
        child: const Icon(Icons.notifications_none_rounded),
      ),
      onPressed: () => context.push('/notifications'),
    );
  }
}

/// « Mes messages » : les 30 derniers messages d'ARC.
class EcranBoiteReception extends ConsumerWidget {
  const EcranBoiteReception({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final instant = ref.watch(notificationsProvider).value;
    final messages = instant?.boite.notifications ?? const <NotificationArc>[];
    return Scaffold(
      appBar: AppBar(
        title: Text(t.boiteTitre),
        leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/formations')),
        actions: [
          if ((instant?.nonLues ?? 0) > 0)
            IconButton(
              key: const Key('bouton_tout_lu'),
              tooltip: t.boiteToutLu,
              icon: const Icon(Icons.done_all_rounded),
              onPressed: () => _service(ref)?.marquerLues([for (final m in messages) m.id]),
            ),
        ],
      ),
      body: Column(
        children: [
          const IndicateurSynchro(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _service(ref)?.rafraichir(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (messages.isEmpty) Encadre(texte: t.boiteVide),
                  for (final m in messages) ...[CarteMessage(message: m), const SizedBox(height: 10)],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarteMessage extends ConsumerWidget {
  const CarteMessage({super.key, required this.message});

  final NotificationArc message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = Theme.of(context).textTheme;
    final langue = Localizations.localeOf(context).languageCode;
    final date = DateFormat.yMMMMd(langue).format(message.envoyeeLe.toLocal());
    final cible = message.cible;
    final ouvrable = cible != null && (cible.route != null || (cible.url ?? '').isNotEmpty);
    return Card(
      key: Key('message_${message.id}'),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _ouvrir(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 12),
                child: Icon(
                  Icons.circle,
                  size: 12,
                  color: message.lue ? Colors.transparent : ArcCouleurs.primaire,
                  semanticLabel: message.lue ? null : AppLocalizations.of(context).boiteNonLu,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.titre,
                      style: style.titleMedium?.copyWith(fontWeight: message.lue ? FontWeight.w400 : FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(message.texte, style: style.bodyLarge),
                    const SizedBox(height: 6),
                    Text(date, style: style.bodySmall?.copyWith(color: ArcCouleurs.texteDiscret)),
                  ],
                ),
              ),
              if (ouvrable) const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _ouvrir(BuildContext context, WidgetRef ref) async {
    await _service(ref)?.marquerLues([message.id]);
    final cible = message.cible;
    if (cible == null || !context.mounted) return;
    final route = cible.route;
    if (route != null) {
      unawaited(context.push(route));
    } else if ((cible.url ?? '').isNotEmpty) {
      final uri = Uri.tryParse(cible.url!);
      if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
        unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
      }
    }
  }
}

/// Réglages › Notifications : ce que l'apprenant reçoit, par sujet et par canal.
class EcranPreferencesNotifications extends ConsumerWidget {
  const EcranPreferencesNotifications({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final instant = ref.watch(notificationsProvider).value;
    final prefs = instant?.preferences;
    final style = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(t.notifsTitre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (prefs == null) ...[
            Encadre(key: const Key('notifs_reseau'), texte: t.notifsReseau, attention: true),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('bouton_notifs_reessayer'),
              onPressed: () => _service(ref)?.rafraichir(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.reessayer),
            ),
          ] else ...[
            Text(t.notifsIntro, style: style.bodyLarge),
            const SizedBox(height: 12),
            if (instant!.envoiEnAttente) ...[
              Encadre(texte: t.notifsEnAttente, icone: Icons.cloud_off_rounded),
              const SizedBox(height: 12),
            ],
            for (final sujet in prefs.sujets) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Text(sujet.libelle, style: style.titleMedium),
                      ),
                      for (final canal in prefs.canaux)
                        _LigneCanal(sujet: sujet.cle, canal: canal, prefs: prefs, pushDispo: instant.pushDisponible),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _LigneCanal extends ConsumerWidget {
  const _LigneCanal({required this.sujet, required this.canal, required this.prefs, required this.pushDispo});

  final String sujet;
  final CanalDisponible canal;
  final PreferencesNotifications prefs;
  final bool pushDispo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final actif = prefs.actif(canal.cle, sujet);
    final estPush = canal.cle == CanalNotification.push;
    final possible = canal.disponible && (!estPush || pushDispo);
    final aide = switch (canal.cle) {
      _ when possible => null,
      CanalNotification.whatsapp => t.notifsWhatsappIndisponible,
      CanalNotification.push => t.notifsPushIndisponible,
      _ => null,
    };
    return SwitchListTile(
      key: Key('pref_${canal.cle}_$sujet'),
      title: Text(canal.libelle),
      subtitle: aide == null ? null : Text(aide),
      value: actif,
      // On peut toujours couper un canal, même devenu indisponible.
      onChanged: possible || actif ? (v) => _changer(context, ref, v) : null,
    );
  }

  Future<void> _changer(BuildContext context, WidgetRef ref, bool actif) async {
    final service = _service(ref);
    if (service == null) return;
    if (actif && canal.cle == CanalNotification.push && !await service.push.demanderPermission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).notifsPermissionRefusee)));
      }
      return;
    }
    await service.modifierPreference(canal.cle, sujet, actif);
  }
}

/// Question posée une fois par profil : « Recevoir les rappels de tes cours sur ce téléphone ? »
class CartePropositionPush extends ConsumerWidget {
  const CartePropositionPush({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final proposer = ref.watch(notificationsProvider.select((n) => n.value?.proposerPush ?? false));
    if (!proposer) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme;
    return Card(
      key: const Key('carte_proposition_push'),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined, color: ArcCouleurs.primaire),
                const SizedBox(width: 10),
                Expanded(child: Text(t.pushPropositionTitre, style: style.titleMedium)),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.pushPropositionAide, style: style.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('bouton_push_non'),
                  onPressed: () => _service(ref)?.repondrePropositionPush(false),
                  child: Text(t.pushNon),
                ),
                FilledButton(
                  key: const Key('bouton_push_oui'),
                  onPressed: () async {
                    final ok = await _service(ref)?.repondrePropositionPush(true) ?? false;
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(ok ? t.pushActive : t.notifsPermissionRefusee)));
                  },
                  child: Text(t.pushOui),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
