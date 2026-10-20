import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/profils/profils.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';
import '../../widgets/pave_pin.dart';

/// « Qui apprend ? » : les profils du téléphone partagé.
class EcranProfils extends ConsumerWidget {
  const EcranProfils({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final profils = ref.watch(profilsProvider);
    final message = ref.watch(messageProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.profilsTitre), automaticallyImplyLeading: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (message == 'profil_efface') ...[
              Encadre(texte: t.profilEfface, attention: true),
              const SizedBox(height: 16),
            ],
            Text(t.profilsAide, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            for (final p in profils.value ?? const <Profil>[]) ...[
              Card(
                child: ListTile(
                  key: Key('profil_${p.id}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: ArcCouleurs.primaireClair,
                    child: Text(
                      p.initiales,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ArcCouleurs.primaireFonce,
                      ),
                    ),
                  ),
                  title: Text(p.nom, style: Theme.of(context).textTheme.titleMedium),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 30),
                  onTap: () {
                    ref.read(messageProvider.notifier).afficher(null);
                    context.push('/pin/${p.id}');
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('bouton_ajouter_profil'),
              onPressed: () => context.push('/connexion'),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(t.profilsAjouter),
            ),
          ],
        ),
      ),
    );
  }
}

/// Choisir son code secret (nouveau profil, ou après « code oublié »).
class EcranCreerPin extends ConsumerStatefulWidget {
  const EcranCreerPin({super.key, required this.profilId});

  final String profilId;

  @override
  ConsumerState<EcranCreerPin> createState() => _EcranCreerPinState();
}

class _EcranCreerPinState extends ConsumerState<EcranCreerPin> {
  String? _premier;
  String? _erreur;
  bool _travail = false;
  final _pave = GlobalKey<PavePinState>();

  Future<void> _valider(String pin) async {
    final t = AppLocalizations.of(context);
    if (_premier == null) {
      setState(() {
        _premier = pin;
        _erreur = null;
      });
      _pave.currentState?.vider();
      return;
    }
    if (pin != _premier) {
      setState(() {
        _premier = null;
        _erreur = t.pinDifferent;
      });
      _pave.currentState?.vider();
      return;
    }
    setState(() => _travail = true);
    final services = ref.read(servicesProvider);
    await services.profils.definirPin(widget.profilId, pin);
    final profil = await services.profils.profil(widget.profilId);
    if (profil == null || !mounted) return;
    await ref.read(profilOuvertProvider.notifier).ouvrir(profil);
    if (mounted) context.go('/formations');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                _premier == null ? t.pinCreerTitre : t.pinConfirmerTitre,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(t.pinCreerAide, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              if (_erreur != null) ...[Encadre(texte: _erreur!, attention: true), const SizedBox(height: 16)],
              PavePin(key: _pave, onValider: _valider, actif: !_travail),
            ],
          ),
        ),
      ),
    );
  }
}

/// Déverrouiller un profil avec son code secret.
class EcranPin extends ConsumerStatefulWidget {
  const EcranPin({super.key, required this.profilId});

  final String profilId;

  @override
  ConsumerState<EcranPin> createState() => _EcranPinState();
}

class _EcranPinState extends ConsumerState<EcranPin> {
  String? _erreur;
  Duration _attente = Duration.zero;
  Timer? _minuteur;
  bool _travail = false;
  final _pave = GlobalKey<PavePinState>();

  @override
  void initState() {
    super.initState();
    ref.read(servicesProvider).profils.attenteAvantEssai(widget.profilId).then(_attendre);
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  void _attendre(Duration d) {
    if (!mounted) return;
    setState(() => _attente = d);
    _minuteur?.cancel();
    if (d <= Duration.zero) return;
    _minuteur = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _attente -= const Duration(seconds: 1));
      if (_attente <= Duration.zero) {
        timer.cancel();
        setState(() => _erreur = null);
      }
    });
  }

  static String _duree(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return m > 0 ? '$m min ${s.toString().padLeft(2, '0')} s' : '$s s';
  }

  Future<void> _valider(String pin) async {
    final t = AppLocalizations.of(context);
    setState(() => _travail = true);
    final services = ref.read(servicesProvider);
    final r = await services.profils.verifierPin(widget.profilId, pin);
    if (!mounted) return;
    if (r.ok) {
      final profil = await services.profils.profil(widget.profilId);
      if (profil == null || !mounted) return;
      await ref.read(profilOuvertProvider.notifier).ouvrir(profil);
      if (mounted) context.go('/formations');
      return;
    }
    _pave.currentState?.vider();
    setState(() {
      _travail = false;
      _erreur = r.essaisAvantAttente > 0 && r.attente == Duration.zero
          ? t.pinFauxEssais(r.essaisAvantAttente)
          : t.pinFaux;
    });
    _attendre(r.attente);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final profil = (ref.watch(profilsProvider).value ?? const <Profil>[])
        .where((p) => p.id == widget.profilId)
        .firstOrNull;
    final bloque = _attente > Duration.zero;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                t.pinTitre(profil?.nom.split(' ').first ?? ''),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(t.pinAide, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              if (bloque)
                Encadre(texte: t.pinAttente(_duree(_attente)), attention: true, icone: Icons.timer_outlined)
              else if (_erreur != null)
                Encadre(texte: _erreur!, attention: true),
              const SizedBox(height: 16),
              PavePin(key: _pave, onValider: _valider, actif: !bloque && !_travail),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(t.pinOublie),
                    content: Text(t.pinOublieAide, style: Theme.of(context).textTheme.bodyLarge),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.annuler)),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/connexion', extra: profil?.email);
                        },
                        child: Text(t.confirmer),
                      ),
                    ],
                  ),
                ),
                child: Text(t.pinOublie),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
