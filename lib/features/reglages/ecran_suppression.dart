import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/providers.dart';
import '../../core/services.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';

/// Demande de suppression du compte (exigée par Google Play et l'App Store).
///
/// La demande n'est jamais mise en file : elle doit être confirmée par le serveur. Après la réponse, le profil est
/// effacé de ce téléphone (les autres téléphones le feront au prochain passage réseau).
class EcranSuppression extends ConsumerStatefulWidget {
  const EcranSuppression({super.key});

  @override
  ConsumerState<EcranSuppression> createState() => _EcranSuppressionState();
}

enum _Erreur { horsLigne, session, autre }

class _EcranSuppressionState extends ConsumerState<EcranSuppression> {
  final _motif = TextEditingController();
  final _confirmation = TextEditingController();
  bool _envoi = false;
  _Erreur? _erreur;

  @override
  void dispose() {
    _motif.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  bool _confirme(AppLocalizations t) => _confirmation.text.trim().toUpperCase() == t.suppressionMotCle;

  Future<void> _envoyer() async {
    final t = AppLocalizations.of(context);
    final ouvert = ref.read(profilOuvertProvider);
    if (ouvert == null) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      if (await ref.read(servicesProvider).connectivite.actuel() == TypeReseau.aucun) {
        throw ApiException(code: 'reseau');
      }
      final reponse = await ouvert.api.demanderSuppression(motif: _motif.text);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: Text(t.suppressionFaite),
          content: Text(reponse.message, style: Theme.of(c).textTheme.bodyLarge),
          actions: [FilledButton(onPressed: () => Navigator.of(c).pop(), child: Text(t.suppressionOk))],
        ),
      );
      await ref.read(profilOuvertProvider.notifier).effacer();
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _envoi = false;
        _erreur = e.estReseau ? _Erreur.horsLigne : (e.status == 401 ? _Erreur.session : _Erreur.autre);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme;
    final couleurErreur = Theme.of(context).colorScheme.error;
    return Scaffold(
      appBar: AppBar(title: Text(t.suppressionTitre)),
      body: SafeArea(
        child: ListView(
          key: const Key('liste_suppression'),
          padding: const EdgeInsets.all(20),
          children: [
            Text(t.suppressionExplication, style: style.bodyLarge),
            const SizedBox(height: 8),
            for (final point in [t.suppressionPoint1, t.suppressionPoint2, t.suppressionPoint3])
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 4), child: Icon(Icons.remove_circle_outline, size: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(point, style: style.bodyLarge)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Encadre(texte: t.suppressionAttestations),
            const SizedBox(height: 20),
            TextField(
              key: const Key('champ_motif'),
              controller: _motif,
              maxLength: 500,
              maxLines: 3,
              minLines: 2,
              decoration: InputDecoration(labelText: t.suppressionMotif),
            ),
            const SizedBox(height: 8),
            Text(t.suppressionConfirmer, style: style.titleMedium),
            const SizedBox(height: 8),
            TextField(
              key: const Key('champ_confirmation'),
              controller: _confirmation,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(hintText: t.suppressionMotCle),
              onChanged: (_) => setState(() {}),
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Encadre(
                attention: true,
                icone: _erreur == _Erreur.horsLigne ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                texte: switch (_erreur!) {
                  _Erreur.horsLigne => t.suppressionHorsLigne,
                  _Erreur.session => t.suppressionSession,
                  _Erreur.autre => t.suppressionErreur,
                },
              ),
              if (_erreur == _Erreur.horsLigne)
                TextButton(
                  key: const Key('lien_suppression_web'),
                  onPressed: () => launchUrl(Uri.parse(t.suppressionLienWeb), mode: LaunchMode.externalApplication),
                  child: Text(t.suppressionLienWeb, textAlign: TextAlign.center),
                ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('bouton_supprimer_compte'),
              style: FilledButton.styleFrom(backgroundColor: couleurErreur),
              onPressed: _envoi || !_confirme(t) ? null : _envoyer,
              icon: _envoi
                  ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.delete_forever_rounded),
              label: Text(t.suppressionBouton),
            ),
          ],
        ),
      ),
    );
  }
}
