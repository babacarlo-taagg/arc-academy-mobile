import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/modeles.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';

String messageErreur(AppLocalizations t, Object e) {
  if (e is ApiException) {
    if (e.estReseau) return t.erreurReseau;
    if (e.code == 'trop_de_demandes') return t.erreurTropDeDemandes;
    if (e.code == 'code_expire') return t.codeExpire;
    if (e.code == 'code_invalide') return t.codeIncorrect((e.extra['essaisRestants'] as num?)?.toInt() ?? 0);
  }
  return t.erreurInconnue;
}

final _emailValide = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Étape 1 : l'adresse e-mail.
class EcranConnexion extends ConsumerStatefulWidget {
  const EcranConnexion({super.key, this.emailInitial});

  final String? emailInitial;

  @override
  ConsumerState<EcranConnexion> createState() => _EcranConnexionState();
}

class _EcranConnexionState extends ConsumerState<EcranConnexion> {
  late final _email = TextEditingController(text: widget.emailInitial ?? '');
  String? _erreur;
  bool _envoi = false;

  Future<void> _envoyer() async {
    final t = AppLocalizations.of(context);
    final email = _email.text.trim().toLowerCase();
    if (!_emailValide.hasMatch(email)) return setState(() => _erreur = t.connexionEmailInvalide);
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      final envoi = await ref.read(servicesProvider).apiPublic.demanderCode(email);
      if (!mounted) return;
      context.push('/connexion/code', extra: (email, envoi));
    } catch (e) {
      setState(() => _erreur = messageErreur(t, e));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final profils = ref.watch(profilsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: profils.isNotEmpty || context.canPop()
            ? BackButton(onPressed: () => context.canPop() ? context.pop() : context.go('/profils'))
            : null,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            const Icon(Icons.local_hospital_rounded, size: 56, color: ArcCouleurs.primaire),
            const SizedBox(height: 12),
            Text(t.nomAppli, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            Text(t.sousTitreAppli, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            TextField(
              key: const Key('champ_email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _envoyer(),
              style: const TextStyle(fontSize: 19),
              decoration: InputDecoration(
                labelText: t.connexionEmailLibelle,
                helperText: t.connexionEmailAide,
                prefixIcon: const Icon(Icons.mail_outline_rounded),
              ),
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Encadre(texte: _erreur!, attention: true, icone: Icons.error_outline_rounded),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('bouton_recevoir_code'),
              onPressed: _envoi ? null : _envoyer,
              child: _envoi
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : Text(t.connexionRecevoirCode),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => afficherAide(context, ref),
              icon: const Icon(Icons.help_outline_rounded),
              label: Text(t.connexionPasEmail),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fenêtre d'aide : coordonnées du support (demandées au serveur, avec un texte de secours hors ligne).
Future<void> afficherAide(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  Aide? aide;
  try {
    aide = await ref.read(servicesProvider).apiPublic.aide();
  } catch (_) {
    aide = null;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.aideTitre),
      content: Text(aide?.messageSansEmail ?? t.aideSansEmail, style: Theme.of(context).textTheme.bodyLarge),
      actions: [
        if (aide != null && aide.emailSupport.isNotEmpty)
          TextButton(
            onPressed: () => launchUrl(Uri(scheme: 'mailto', path: aide!.emailSupport)),
            child: Text(t.aideContact(aide.emailSupport)),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.fermer)),
      ],
    ),
  );
}

/// Étape 2 : le code reçu par e-mail.
class EcranCode extends ConsumerStatefulWidget {
  const EcranCode({super.key, required this.email, required this.envoi});

  final String email;
  final CodeEnvoye envoi;

  @override
  ConsumerState<EcranCode> createState() => _EcranCodeState();
}

class _EcranCodeState extends ConsumerState<EcranCode> {
  final _code = TextEditingController();
  String? _erreur;
  bool _envoi = false;
  late int _attente = widget.envoi.renvoiPossibleDans;
  Timer? _minuteur;

  @override
  void initState() {
    super.initState();
    _demarrerMinuteur();
  }

  void _demarrerMinuteur() {
    _minuteur?.cancel();
    _minuteur = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_attente <= 0) return timer.cancel();
      setState(() => _attente--);
    });
  }

  @override
  void dispose() {
    _minuteur?.cancel();
    super.dispose();
  }

  Future<void> _valider() async {
    final t = AppLocalizations.of(context);
    final code = _code.text.trim();
    if (code.length != 6) return;
    setState(() {
      _envoi = true;
      _erreur = null;
    });
    try {
      final services = ref.read(servicesProvider);
      final session = await services.apiPublic.verifierCode(
        email: widget.email,
        code: code,
        appareil: await services.descriptionAppareil(),
      );
      final profil = await services.profils.ouvrirSession(session);
      ref.invalidate(profilsProvider);
      // Nouveau profil, ou PIN oublié : on (re)choisit le code secret.
      if (!mounted) return;
      context.go('/pin/${profil.id}/creer');
    } catch (e) {
      setState(() => _erreur = messageErreur(t, e));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  Future<void> _renvoyer() async {
    final t = AppLocalizations.of(context);
    try {
      final envoi = await ref.read(servicesProvider).apiPublic.demanderCode(widget.email);
      setState(() {
        _attente = envoi.renvoiPossibleDans;
        _erreur = null;
      });
      _demarrerMinuteur();
    } catch (e) {
      setState(() => _erreur = messageErreur(t, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.codeTitre)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Encadre(texte: t.codeEnvoye(widget.envoi.emailMasque), icone: Icons.mark_email_read_outlined),
            const SizedBox(height: 8),
            Text(t.codeVerifierSpams, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            TextField(
              key: const Key('champ_code'),
              controller: _code,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 34, letterSpacing: 12, fontWeight: FontWeight.w600),
              decoration: InputDecoration(labelText: t.codeLibelle),
              onChanged: (v) {
                if (v.length == 6) _valider();
              },
            ),
            if (_erreur != null) ...[
              const SizedBox(height: 16),
              Encadre(texte: _erreur!, attention: true, icone: Icons.error_outline_rounded),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('bouton_valider_code'),
              onPressed: _envoi ? null : _valider,
              child: _envoi
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                  : Text(t.codeValider),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _attente > 0 ? null : _renvoyer,
              child: Text(_attente > 0 ? t.codeRenvoyerDans(_attente) : t.codeRenvoyer),
            ),
          ],
        ),
      ),
    );
  }
}
