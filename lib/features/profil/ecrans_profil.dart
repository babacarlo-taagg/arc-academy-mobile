import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/api/modeles.dart';
import '../../core/profil/service_profil.dart';
import '../../core/providers.dart';
import '../../core/services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';

ServiceProfil? _service(WidgetRef ref) => ref.read(profilOuvertProvider)?.profilApprenant;

const _languesParDefaut = [Choix('fr', 'Français'), Choix('en', 'English')];

/// Confirme l'enregistrement : envoyé, ou gardé sur le téléphone en attendant le réseau.
void _confirmer(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context);
  final horsLigne = ref.read(reseauProvider).value == TypeReseau.aucun;
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(horsLigne ? t.profilEnregistreHorsLigne : t.profilEnregistre)));
}

// ───────────────────────── Champs ─────────────────────────

/// Liste déroulante sur un référentiel.
class ListeChoix extends StatelessWidget {
  const ListeChoix({
    super.key,
    required this.libelle,
    required this.choix,
    required this.valeur,
    required this.onChanged,
  });

  final String libelle;
  final List<Choix> choix;
  final String? valeur;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [...choix, if (valeur != null && !choix.any((c) => c.cle == valeur)) Choix(valeur!, valeur!)];
    return DropdownButtonFormField<String>(
      initialValue: valeur,
      isExpanded: true,
      decoration: InputDecoration(labelText: libelle),
      items: [
        for (final c in options)
          DropdownMenuItem(
            value: c.cle,
            child: Text(c.libelle, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

/// Choix du pays dans une liste avec recherche.
class ChoixPays extends StatelessWidget {
  const ChoixPays({super.key, required this.pays, required this.valeur, required this.onChanged});

  final List<Choix> pays;
  final String? valeur;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      key: const Key('champ_pays'),
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final choisi = await showDialog<Choix>(
          context: context,
          builder: (_) => _DialoguePays(pays: pays),
        );
        if (choisi != null) onChanged(choisi.cle);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: t.profilPays, suffixIcon: const Icon(Icons.search_rounded)),
        isEmpty: valeur == null,
        child: valeur == null ? null : Text(Referentiels.libelle(pays, valeur)),
      ),
    );
  }
}

class _DialoguePays extends StatefulWidget {
  const _DialoguePays({required this.pays});
  final List<Choix> pays;

  @override
  State<_DialoguePays> createState() => _DialoguePaysState();
}

class _DialoguePaysState extends State<_DialoguePays> {
  String _filtre = '';

  static String _simple(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('ç', 'c');

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final f = _simple(_filtre.trim());
    final liste = [
      for (final p in widget.pays)
        if (f.isEmpty || _simple(p.libelle).contains(f) || p.cle.toLowerCase() == f) p,
    ];
    return AlertDialog(
      title: Text(t.profilPaysChoisir),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            TextField(
              key: const Key('recherche_pays'),
              autofocus: true,
              decoration: InputDecoration(labelText: t.profilPaysRecherche, prefixIcon: const Icon(Icons.search)),
              onChanged: (v) => setState(() => _filtre = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: liste.isEmpty
                  ? Center(child: Text(t.profilAucunResultat))
                  : ListView.builder(
                      itemCount: liste.length,
                      itemBuilder: (_, i) => ListTile(
                        key: Key('pays_${liste[i].cle}'),
                        title: Text(liste[i].libelle),
                        onTap: () => Navigator.of(context).pop(liste[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t.annuler))],
    );
  }
}

/// Institution : recherche parmi celles d'ARC (en ligne, 3 lettres au moins), sinon nom tapé.
class ChampInstitution extends ConsumerStatefulWidget {
  const ChampInstitution({super.key, this.initiale, required this.onChanged});

  final InstitutionProfil? initiale;

  /// Identifiant (institution de la liste) ou null (nom tapé), et nom.
  final void Function(int? id, String nom) onChanged;

  @override
  ConsumerState<ChampInstitution> createState() => _ChampInstitutionState();
}

class _ChampInstitutionState extends ConsumerState<ChampInstitution> {
  late final _texte = TextEditingController(text: widget.initiale?.nom ?? '');
  Timer? _attente;
  List<Organisation> _resultats = const [];
  bool _horsLigne = false;
  int _numero = 0;

  @override
  void dispose() {
    _attente?.cancel();
    _texte.dispose();
    super.dispose();
  }

  void _tape(String v) {
    widget.onChanged(null, v.trim());
    _attente?.cancel();
    if (v.trim().length < 3) {
      setState(() => _resultats = const []);
      return;
    }
    _attente = Timer(const Duration(milliseconds: 400), () => _chercher(v.trim()));
  }

  Future<void> _chercher(String recherche) async {
    final ouvert = ref.read(profilOuvertProvider);
    if (ouvert == null) return;
    final numero = ++_numero;
    if (await ouvert.services.connectivite.actuel() == TypeReseau.aucun) {
      if (mounted) setState(() => _horsLigne = true);
      return;
    }
    try {
      final r = await ouvert.api.chercherOrganisations(recherche);
      if (!mounted || numero != _numero) return;
      setState(() {
        _resultats = r;
        _horsLigne = false;
      });
    } on ApiException catch (e) {
      if (mounted && numero == _numero) setState(() => _horsLigne = e.estReseau);
    }
  }

  void _choisir(Organisation o) {
    _attente?.cancel();
    _numero++;
    _texte.text = o.nom;
    setState(() => _resultats = const []);
    widget.onChanged(o.id, o.nom);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final nom = _texte.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('champ_institution'),
          controller: _texte,
          maxLength: 160,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: t.institutionNom,
            helperText: _horsLigne ? t.institutionHorsLigne : t.institutionRechercheAide,
            helperMaxLines: 2,
            prefixIcon: const Icon(Icons.apartment_rounded),
            counterText: '',
          ),
          onChanged: _tape,
        ),
        if (_resultats.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                for (final o in _resultats)
                  ListTile(
                    key: Key('organisation_${o.id}'),
                    leading: const Icon(Icons.apartment_rounded),
                    title: Text(o.nom),
                    onTap: () => _choisir(o),
                  ),
                ListTile(
                  key: const Key('institution_nom_tape'),
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(t.institutionUtiliserNom(nom)),
                  onTap: () => setState(() => _resultats = const []),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// « Profil complété à X % » (touche : Mon profil).
class BarreCompletude extends ConsumerWidget {
  const BarreCompletude({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final profil = ref.watch(profilApprenantProvider).value?.profil;
    if (profil == null || profil.completude >= 100) return const SizedBox.shrink();
    return Card(
      key: const Key('barre_completude'),
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/reglages/profil'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(t.profilCompletude(profil.completude), style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: profil.completude / 100,
                  minHeight: 10,
                  color: ArcCouleurs.progression,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encadré « Tu es… » (facultatif) dans « Mes formations ».
class CarteSexe extends ConsumerWidget {
  const CarteSexe({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final instant = ref.watch(profilApprenantProvider).value;
    final sexes = instant?.referentiels?.sexes ?? const [];
    if (instant == null || !instant.demanderSexe || sexes.isEmpty) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme;
    return Card(
      key: const Key('carte_sexe'),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.sexeTitre, style: style.titleMedium),
            const SizedBox(height: 4),
            Text(t.sexeAide, style: style.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in sexes)
                  ActionChip(
                    key: Key('sexe_${s.cle}'),
                    label: Text(s.libelle),
                    onPressed: () => _service(ref)?.modifier({'sexe': s.cle}),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('bouton_sexe_passer'),
                onPressed: () => _service(ref)?.ignorer(const [ChampProfil.sexe]),
                child: Text(t.sexePasser),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Proposition « Ton institution » (après le premier téléchargement d'un cours), jamais bloquante.
class CarteInstitution extends ConsumerWidget {
  const CarteInstitution({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final questions = ref.watch(profilApprenantProvider).value?.questionsInstitution ?? const [];
    if (questions.isEmpty) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme;
    return Card(
      key: const Key('carte_institution'),
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.apartment_rounded, color: ArcCouleurs.primaire),
                const SizedBox(width: 10),
                Expanded(child: Text(t.institutionTitre, style: style.titleMedium)),
              ],
            ),
            const SizedBox(height: 6),
            Text(t.institutionIntro, style: style.bodyMedium),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                TextButton(
                  key: const Key('bouton_institution_plus_tard'),
                  onPressed: () => _service(ref)?.ignorer(questions),
                  child: Text(t.institutionPlusTard),
                ),
                FilledButton(
                  key: const Key('bouton_institution_repondre'),
                  onPressed: () => context.push('/institution'),
                  child: Text(t.institutionRepondre),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Écrans ─────────────────────────

/// « Ton profil » : pays et métier, obligatoires à la première connexion.
class EcranProfilObligatoire extends ConsumerStatefulWidget {
  const EcranProfilObligatoire({super.key});

  @override
  ConsumerState<EcranProfilObligatoire> createState() => _EcranProfilObligatoireState();
}

class _EcranProfilObligatoireState extends ConsumerState<EcranProfilObligatoire> {
  final _valeurs = <String, String?>{};
  bool _manque = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final instant = ref.watch(profilApprenantProvider).value;
    final style = Theme.of(context).textTheme;
    final Widget corps;
    switch (instant?.etat) {
      case EtatProfil.reseauNecessaire:
        corps = ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Encadre(texte: t.profilReseauNecessaire, icone: Icons.wifi_off_rounded, attention: true),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const Key('bouton_profil_reessayer'),
              onPressed: () => _service(ref)?.reessayer(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.reessayer),
            ),
          ],
        );
      case EtatProfil.aCompleter || EtatProfil.pret:
        corps = _formulaire(context, instant!);
      case EtatProfil.chargement || null:
        corps = Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(t.profilChargement, style: style.bodyLarge),
            ],
          ),
        );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(t.profilTitre),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: t.autrePersonne,
            icon: const Icon(Icons.switch_account_rounded),
            onPressed: () async {
              await ref.read(profilOuvertProvider.notifier).fermer();
              if (context.mounted) context.go('/profils');
            },
          ),
        ],
      ),
      body: corps,
    );
  }

  Widget _formulaire(BuildContext context, InstantaneProfil instant) {
    final t = AppLocalizations.of(context);
    final profil = instant.profil!;
    final ref_ = instant.referentiels;
    // Seulement les questions demandées par le serveur (3 au plus), les obligatoires d'abord.
    final champs = {
      ...profil.obligatoires,
      ...profil.questionsAPoser,
    }.where((c) => const {ChampProfil.pays, ChampProfil.metier, ChampProfil.langue}.contains(c)).toList();
    String? valeur(String champ, String? initiale) => _valeurs.containsKey(champ) ? _valeurs[champ] : initiale;
    void changer(String champ, String? v) => setState(() {
      _valeurs[champ] = v;
      _manque = false;
    });
    final enfants = <Widget>[
      Text(t.profilIntro, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 20),
    ];
    for (final champ in champs) {
      enfants.add(switch (champ) {
        ChampProfil.pays => ChoixPays(
          pays: ref_?.pays ?? const [],
          valeur: valeur(champ, profil.pays),
          onChanged: (v) => changer(champ, v),
        ),
        ChampProfil.metier => ListeChoix(
          key: const Key('champ_metier'),
          libelle: t.profilMetier,
          choix: ref_?.metiers ?? const [],
          valeur: valeur(champ, profil.metier),
          onChanged: (v) => changer(champ, v),
        ),
        _ => ListeChoix(
          key: const Key('champ_langue'),
          libelle: t.profilLangue,
          choix: (ref_?.langues.isNotEmpty ?? false) ? ref_!.langues : _languesParDefaut,
          valeur: valeur(champ, profil.langue ?? Localizations.localeOf(context).languageCode),
          onChanged: (v) => changer(champ, v),
        ),
      });
      enfants.add(const SizedBox(height: 16));
    }
    if (_manque) {
      enfants.addAll([
        Encadre(key: const Key('profil_manque'), texte: t.profilManque, attention: true),
        const SizedBox(height: 16),
      ]);
    }
    enfants.add(
      FilledButton(
        key: const Key('bouton_profil_continuer'),
        onPressed: () {
          final modification = <String, dynamic>{
            for (final champ in champs)
              if (valeur(champ, champ == ChampProfil.langue ? Localizations.localeOf(context).languageCode : null)
                  case final String v)
                champ: v,
          };
          if (profil.obligatoires.any((c) => !modification.containsKey(c))) {
            setState(() => _manque = true);
            return;
          }
          _service(ref)?.modifier(modification);
        },
        child: Text(t.profilContinuer),
      ),
    );
    return ListView(padding: const EdgeInsets.all(20), children: enfants);
  }
}

/// « Ton institution » : institution, type et niveau (seulement les questions demandées).
class EcranInstitution extends ConsumerStatefulWidget {
  const EcranInstitution({super.key});

  @override
  ConsumerState<EcranInstitution> createState() => _EcranInstitutionState();
}

class _EcranInstitutionState extends ConsumerState<EcranInstitution> {
  int? _institutionId;
  String _institutionNom = '';
  String? _type;
  String? _niveau;
  List<String>? _questions;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final instant = ref.watch(profilApprenantProvider).value;
    // Les questions sont fixées à l'ouverture : elles ne disparaissent pas pendant qu'on répond.
    final questions = _questions ??= instant?.profil?.questionsInstitution ?? const [];
    final ref_ = instant?.referentiels;
    return Scaffold(
      appBar: AppBar(title: Text(t.institutionTitre)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(t.institutionIntro, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 20),
          if (questions.contains(ChampProfil.institution)) ...[
            ChampInstitution(
              initiale: instant?.profil?.institution,
              onChanged: (id, nom) {
                _institutionId = id;
                _institutionNom = nom;
              },
            ),
            const SizedBox(height: 16),
          ],
          if (questions.contains(ChampProfil.typeInstitution)) ...[
            ListeChoix(
              key: const Key('champ_type_institution'),
              libelle: t.institutionType,
              choix: ref_?.typesInstitution ?? const [],
              valeur: _type,
              onChanged: (v) => setState(() => _type = v),
            ),
            const SizedBox(height: 16),
          ],
          if (questions.contains(ChampProfil.niveau)) ...[
            ListeChoix(
              key: const Key('champ_niveau'),
              libelle: t.institutionNiveau,
              choix: ref_?.niveaux ?? const [],
              valeur: _niveau,
              onChanged: (v) => setState(() => _niveau = v),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton(
            key: const Key('bouton_institution_enregistrer'),
            onPressed: () async {
              final modification = <String, dynamic>{
                if (_institutionId != null)
                  'institutionId': _institutionId
                else if (_institutionNom.isNotEmpty)
                  'institutionNom': _institutionNom,
                'typeInstitution': ?_type,
                'niveau': ?_niveau,
              };
              final repondus = {
                if (modification.containsKey('institutionId') || modification.containsKey('institutionNom'))
                  ChampProfil.institution,
                ...modification.keys,
              };
              // Ce que la personne a laissé vide est passé : on ne le redemande pas.
              final passes = [
                for (final q in questions)
                  if (!repondus.contains(q)) q,
              ];
              if (modification.isNotEmpty && passes.isNotEmpty) modification['ignorer'] = passes;
              await _service(ref)
                  ?.modifier(modification, nomInstitution: _institutionId == null ? null : _institutionNom);
              if (!context.mounted) return;
              if (modification.isNotEmpty) _confirmer(context, ref);
              context.pop();
            },
            child: Text(t.enregistrer),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('bouton_institution_ecran_plus_tard'),
            onPressed: () async {
              await _service(ref)?.ignorer(questions);
              if (context.mounted) context.pop();
            },
            child: Text(t.institutionPlusTard),
          ),
        ],
      ),
    );
  }
}

/// Réglages › Mon profil : tous les champs, la complétude et l'accord WhatsApp.
class EcranMonProfil extends ConsumerStatefulWidget {
  const EcranMonProfil({super.key});

  @override
  ConsumerState<EcranMonProfil> createState() => _EcranMonProfilState();
}

class _EcranMonProfilState extends ConsumerState<EcranMonProfil> {
  final _valeurs = <String, String?>{};
  int? _institutionId;
  String? _institutionNom;
  late final _whatsapp = TextEditingController(text: _service(ref)?.actuel.profil?.whatsapp ?? '');
  bool _accord = false;
  String? _erreurWhatsapp;

  static final _formatWhatsapp = RegExp(r'^\+[1-9]\d{7,14}$');

  @override
  void dispose() {
    _whatsapp.dispose();
    super.dispose();
  }

  String? _valeur(String champ, String? initiale) => _valeurs.containsKey(champ) ? _valeurs[champ] : initiale;

  void _changer(String champ, String? v) => setState(() => _valeurs[champ] = v);

  Future<void> _enregistrer(ProfilApprenant profil) async {
    final t = AppLocalizations.of(context);
    final numero = _whatsapp.text.replaceAll(RegExp(r'[\s.\-()]'), '');
    if ((numero.isNotEmpty || _accord) && !_formatWhatsapp.hasMatch(numero)) {
      setState(() => _erreurWhatsapp = t.whatsappInvalide);
      return;
    }
    setState(() => _erreurWhatsapp = null);
    final modification = <String, dynamic>{
      for (final e in _valeurs.entries)
        if (e.value != null && e.value != _initiale(profil, e.key)) e.key: e.value,
      if (_institutionId != null)
        'institutionId': _institutionId
      else if (_institutionNom != null && _institutionNom!.isNotEmpty && _institutionNom != profil.institution?.nom)
        'institutionNom': _institutionNom,
      if (numero != (profil.whatsapp ?? '')) 'whatsapp': numero.isEmpty ? null : numero,
      if (_accord && !profil.whatsappAccord) ...{
        'whatsappAccord': true,
        'whatsappAccordVersion': profil.whatsappAccordVersion,
      },
    };
    if (modification.isEmpty) return;
    await _service(ref)?.modifier(modification, nomInstitution: _institutionId == null ? null : _institutionNom);
    if (!mounted) return;
    setState(() {
      _valeurs.clear();
      _institutionId = null;
      _accord = false;
    });
    _confirmer(context, ref);
  }

  static String? _initiale(ProfilApprenant p, String champ) => switch (champ) {
    ChampProfil.pays => p.pays,
    ChampProfil.metier => p.metier,
    ChampProfil.langue => p.langue,
    ChampProfil.typeInstitution => p.typeInstitution,
    ChampProfil.niveau => p.niveau,
    ChampProfil.sexe => p.sexe,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final instant = ref.watch(profilApprenantProvider).value;
    final profil = instant?.profil;
    final r = instant?.referentiels;
    final style = Theme.of(context).textTheme;
    if (profil == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.monProfilTitre)),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Encadre(texte: t.profilReseauNecessaire),
        ),
      );
    }
    Widget liste(String champ, String libelle, List<Choix>? choix) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListeChoix(
        key: Key('mon_profil_$champ'),
        libelle: libelle,
        choix: choix ?? const [],
        valeur: _valeur(champ, _initiale(profil, champ)),
        onChanged: (v) => _changer(champ, v),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(t.monProfilTitre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BarreCompletude(),
          ChoixPays(
            pays: r?.pays ?? const [],
            valeur: _valeur(ChampProfil.pays, profil.pays),
            onChanged: (v) => _changer(ChampProfil.pays, v),
          ),
          const SizedBox(height: 16),
          liste(ChampProfil.metier, t.profilMetier, r?.metiers),
          liste(ChampProfil.langue, t.profilLangue, (r?.langues.isNotEmpty ?? false) ? r!.langues : _languesParDefaut),
          ChampInstitution(
            initiale: profil.institution,
            onChanged: (id, nom) {
              _institutionId = id;
              _institutionNom = nom;
            },
          ),
          const SizedBox(height: 16),
          liste(ChampProfil.typeInstitution, t.institutionType, r?.typesInstitution),
          liste(ChampProfil.niveau, t.institutionNiveau, r?.niveaux),
          liste(ChampProfil.sexe, t.monProfilSexe, r?.sexes),
          const SizedBox(height: 4),
          Text(t.whatsappTitre, style: style.titleMedium),
          const SizedBox(height: 8),
          TextField(
            key: const Key('champ_whatsapp'),
            controller: _whatsapp,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: t.whatsappNumero,
              helperText: t.whatsappAide,
              errorText: _erreurWhatsapp,
              prefixIcon: const Icon(Icons.chat_outlined),
            ),
          ),
          const SizedBox(height: 8),
          if (profil.whatsappAccord) ...[
            Encadre(texte: t.whatsappAccordActif, icone: Icons.check_circle_outline_rounded),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: const Key('bouton_whatsapp_retirer'),
                onPressed: () async {
                  await _service(ref)?.modifier({'whatsappAccord': false});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.whatsappAccordRetire)));
                  }
                },
                icon: const Icon(Icons.block_rounded),
                label: Text(t.whatsappRetirer),
              ),
            ),
          ] else if (profil.whatsappAccordVersion != null && profil.whatsappTexte.isNotEmpty)
            CheckboxListTile(
              key: const Key('case_whatsapp_accord'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _accord,
              title: Text(profil.whatsappTexte, style: style.bodyMedium),
              onChanged: (v) => setState(() => _accord = v ?? false),
            ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('bouton_mon_profil_enregistrer'),
            onPressed: () => _enregistrer(profil),
            child: Text(t.enregistrer),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
