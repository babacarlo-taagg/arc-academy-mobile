import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/api/modeles.dart';
import '../../core/providers.dart';
import '../../core/services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';

/// Ouvre une leçon : article, PDF ou module SCORM sur le téléphone ; sinon propose de l'ouvrir en ligne.
class EcranLecteur extends ConsumerStatefulWidget {
  const EcranLecteur({super.key, required this.coursId, required this.leconId});

  final int coursId;
  final int leconId;

  @override
  ConsumerState<EcranLecteur> createState() => _EcranLecteurState();
}

class _EcranLecteurState extends ConsumerState<EcranLecteur> with WidgetsBindingObserver {
  final _chrono = Stopwatch();
  ProfilOuvert? _profil;
  bool _ouverteNotee = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _profil = ref.read(profilOuvertProvider);
    _chrono.start();
  }

  /// Le temps passé est noté quand on quitte la leçon, et quand l'appli passe en arrière-plan
  /// (elle peut être tuée ensuite).
  void _noterTemps() {
    final secondes = _chrono.elapsed.inSeconds;
    _chrono
      ..reset()
      ..start();
    final p = _profil;
    if (p != null && !p.estFerme) unawaited(p.journal.tempsPasse(widget.coursId, widget.leconId, secondes));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState etat) {
    if (etat == AppLifecycleState.paused) {
      _noterTemps();
      _chrono.stop();
    } else if (etat == AppLifecycleState.resumed) {
      _chrono.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _noterTemps();
    super.dispose();
  }

  void _noterOuverture() {
    if (_ouverteNotee) return;
    _ouverteNotee = true;
    final p = _profil;
    if (p != null) unawaited(p.journal.leconOuverte(widget.coursId, widget.leconId));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final manifest = ref.watch(manifestProvider(widget.coursId));
    final lecon = manifest.value?.lecons.where((l) => l.id == widget.leconId).firstOrNull;
    if (lecon == null) {
      return Scaffold(
        appBar: AppBar(),
        body: manifest.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(child: Text(t.lecteurNonTelechargee)),
      );
    }
    final services = ref.watch(servicesProvider);
    final disponible = services.depot.leconDisponible(lecon);
    if (!disponible) return _EnLigne(lecon: lecon);
    _noterOuverture();
    final serveur = services.serveurLocal;
    return switch (lecon.type) {
      TypeLecon.scorm => _LecteurScorm(titre: lecon.titre, url: serveur.urlScorm(widget.coursId, lecon.id)),
      TypeLecon.pdf => _LecteurPdf(
        lecon: lecon,
        chemin: services.depot
            .fichierObjet(lecon.fichiers.firstWhere((f) => f.chemin == (lecon.entree ?? f.chemin)).empreinte)
            .path,
        coursId: widget.coursId,
      ),
      _ => _LecteurArticle(
        lecon: lecon,
        coursId: widget.coursId,
        url: serveur.urlLecon(widget.coursId, lecon.id, lecon.entree ?? lecon.fichiers.first.chemin),
      ),
    };
  }
}

/// Bouton « J'ai terminé cette leçon » (articles et PDF).
class _BoutonTerminer extends ConsumerWidget {
  const _BoutonTerminer({required this.coursId, required this.leconId, required this.termineeServeur});

  final int coursId;
  final int leconId;
  final bool termineeServeur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final terminee = termineeServeur || (ref.watch(etatsLeconsProvider(coursId)).value?[leconId]?.terminee ?? false);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: terminee
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: ArcCouleurs.progression, size: 28),
                  const SizedBox(width: 8),
                  Text(t.lecteurDejaTerminee, style: Theme.of(context).textTheme.titleMedium),
                ],
              )
            : FilledButton.icon(
                key: const Key('bouton_terminer'),
                onPressed: () => ref.read(profilOuvertProvider)?.journal.leconTerminee(coursId, leconId),
                icon: const Icon(Icons.check_rounded),
                label: Text(t.lecteurTerminer),
              ),
      ),
    );
  }
}

class _LecteurArticle extends ConsumerStatefulWidget {
  const _LecteurArticle({required this.lecon, required this.coursId, required this.url});

  final Lecon lecon;
  final int coursId;
  final String url;

  @override
  ConsumerState<_LecteurArticle> createState() => _LecteurArticleState();
}

class _LecteurArticleState extends ConsumerState<_LecteurArticle> {
  late final WebViewController _web;
  final _tts = FlutterTts();
  bool _lecture = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _appliquerTaille(ref.read(servicesProvider).reglages.tailleTexte),
          // Aucun lien vers l'extérieur dans la WebView : ils s'ouvrent dans le navigateur.
          onNavigationRequest: (r) {
            if (r.url.startsWith('http://127.0.0.1')) return NavigationDecision.navigate;
            unawaited(launchUrl(Uri.parse(r.url), mode: LaunchMode.externalApplication));
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    unawaited(_tts.stop());
    super.dispose();
  }

  void _appliquerTaille(double facteur) {
    final pourcent = (facteur * 100).round();
    unawaited(
      _web.runJavaScript(
        "document.documentElement.style.fontSize='$pourcent%';"
        "document.body.style.webkitTextSizeAdjust='$pourcent%';",
      ),
    );
  }

  Future<void> _lireOuArreter() async {
    if (_lecture) {
      await _tts.stop();
      setState(() => _lecture = false);
      return;
    }
    final brut = await _web.runJavaScriptReturningResult('document.body.innerText');
    var texte = '$brut';
    if (texte.startsWith('"')) texte = jsonDecode(texte) as String;
    setState(() => _lecture = true);
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.45);
    await _tts.awaitSpeakCompletion(true);
    // Android limite la longueur de chaque lecture : on lit phrase par phrase, par paquets.
    for (final morceau in decouperTexte(texte)) {
      if (!_lecture || !mounted) break;
      await _tts.speak(morceau);
    }
    if (mounted) setState(() => _lecture = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final reglages = ref.watch(servicesProvider).reglages;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lecon.titre, maxLines: 2),
        actions: [
          IconButton(
            tooltip: _lecture ? t.lecteurArreterLecture : t.lecteurLireVoixHaute,
            icon: Icon(_lecture ? Icons.stop_circle_outlined : Icons.volume_up_rounded, size: 30),
            onPressed: _lireOuArreter,
          ),
          IconButton(
            tooltip: t.lecteurTailleTexte,
            icon: const Icon(Icons.format_size_rounded, size: 28),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              builder: (c) => StatefulBuilder(
                builder: (c, setLocal) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.lecteurTailleTexte, style: Theme.of(c).textTheme.titleMedium),
                      Slider(
                        value: reglages.tailleTexte,
                        min: 0.9,
                        max: 1.8,
                        divisions: 9,
                        onChanged: (v) {
                          setLocal(() => reglages.modifier(tailleTexte: v));
                          _appliquerTaille(v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: WebViewWidget(controller: _web),
      bottomNavigationBar: _BoutonTerminer(
        coursId: widget.coursId,
        leconId: widget.lecon.id,
        termineeServeur: widget.lecon.terminee,
      ),
    );
  }
}

/// Découpe un texte en morceaux d'au plus [max] caractères, en coupant entre les phrases.
List<String> decouperTexte(String texte, {int max = 3000}) {
  final phrases = texte.replaceAll(RegExp(r'\s+'), ' ').split(RegExp(r'(?<=[.!?…])\s'));
  final morceaux = <String>[];
  var courant = StringBuffer();
  for (final p in phrases) {
    if (courant.length + p.length + 1 > max && courant.isNotEmpty) {
      morceaux.add(courant.toString().trim());
      courant = StringBuffer();
    }
    if (p.length > max) {
      for (var i = 0; i < p.length; i += max) {
        morceaux.add(p.substring(i, i + max > p.length ? p.length : i + max));
      }
    } else {
      courant.write('$p ');
    }
  }
  if (courant.toString().trim().isNotEmpty) morceaux.add(courant.toString().trim());
  return morceaux;
}

class _LecteurPdf extends StatefulWidget {
  const _LecteurPdf({required this.lecon, required this.chemin, required this.coursId});

  final Lecon lecon;
  final String chemin;
  final int coursId;

  @override
  State<_LecteurPdf> createState() => _LecteurPdfState();
}

class _LecteurPdfState extends State<_LecteurPdf> {
  // Lecteur natif du système (PdfRenderer d'Android, PDFKit d'iOS) : rien de plus dans l'appli.
  late final _pdf = PdfControllerPinch(document: PdfDocument.openFile(widget.chemin));

  @override
  void dispose() {
    _pdf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.lecon.titre, maxLines: 2)),
    body: PdfViewPinch(controller: _pdf),
    bottomNavigationBar: _BoutonTerminer(
      coursId: widget.coursId,
      leconId: widget.lecon.id,
      termineeServeur: widget.lecon.terminee,
    ),
  );
}

class _LecteurScorm extends StatefulWidget {
  const _LecteurScorm({required this.titre, required this.url});

  final String titre;
  final String url;

  @override
  State<_LecteurScorm> createState() => _LecteurScormState();
}

class _LecteurScormState extends State<_LecteurScorm> {
  late final WebViewController _web = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(Colors.white)
    ..loadRequest(Uri.parse(widget.url));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.titre, maxLines: 1), toolbarHeight: 48),
    body: SafeArea(top: false, child: WebViewWidget(controller: _web)),
  );
}

/// Leçon absente du téléphone : vidéo, quiz, ou cours pas encore téléchargé.
class _EnLigne extends ConsumerWidget {
  const _EnLigne({required this.lecon});

  final Lecon lecon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final reseau = ref.watch(reseauProvider).value ?? TypeReseau.aucun;
    final url = lecon.urlEnLigne;
    return Scaffold(
      appBar: AppBar(title: Text(lecon.titre, maxLines: 2)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Icon(iconeLecon(lecon.type), size: 64, color: ArcCouleurs.primaire),
          const SizedBox(height: 16),
          Encadre(texte: lecon.horsLigne ? t.lecteurTelechargerAvant : t.lecteurNonTelechargee),
          const SizedBox(height: 20),
          if (url != null)
            FilledButton.icon(
              onPressed: reseau == TypeReseau.aucun
                  ? null
                  : () => launchUrl(
                      Uri.parse(_absolue(ref.read(servicesProvider).baseUrl, url)),
                      mode: LaunchMode.externalApplication,
                    ),
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(t.lecteurOuvrirEnLigne),
            ),
          if (reseau == TypeReseau.aucun) ...[
            const SizedBox(height: 12),
            Encadre(texte: t.erreurReseau, attention: true),
          ],
        ],
      ),
    );
  }

  static String _absolue(String baseApi, String url) {
    if (url.startsWith('http')) return url;
    final base = Uri.parse(baseApi);
    return base.replace(path: url, query: null).toString();
  }
}
