import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/modeles.dart';
import '../../core/contenus/depot_contenus.dart';
import '../../core/db/base.dart';
import '../../core/providers.dart';
import '../../core/services.dart';
import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/communs.dart';
import '../../widgets/indicateur_synchro.dart';

/// « Mes formations ».
class EcranFormations extends ConsumerWidget {
  const EcranFormations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final formations = ref.watch(formationsProvider).value ?? const <FormationLocale>[];
    final message = ref.watch(messageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.formationsTitre),
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
          IconButton(
            key: const Key('bouton_reglages'),
            tooltip: t.reglagesTitre,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/reglages'),
          ),
        ],
      ),
      body: Column(
        children: [
          const IndicateurSynchro(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.read(profilOuvertProvider)?.rafraichir(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (message == 'session_a_reprendre') ...[
                    Encadre(texte: t.sessionAReprendre, attention: true),
                    const SizedBox(height: 12),
                  ],
                  if (formations.isEmpty) Encadre(texte: t.formationsVide),
                  for (final f in formations) ...[CarteFormation(formation: f), const SizedBox(height: 14)],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CarteFormation extends ConsumerWidget {
  const CarteFormation({super.key, required this.formation});

  final FormationLocale formation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final etat = ref.watch(etatHorsLigneProvider((formation.id, formation.versionServeur)));
    final telechargement = ref.watch(telechargementsProvider.select((m) => m[formation.id]));
    final cohortes = [for (final c in jsonDecode(formation.cohortes) as List) '$c'];
    final (icone, texteEtat, couleur) = switch (etat) {
      EtatHorsLigne.complet => (Icons.offline_pin_rounded, t.etatHorsLigne, ArcCouleurs.primaire),
      EtatHorsLigne.partiel => (Icons.downloading_rounded, t.etatPartiel, ArcCouleurs.attention),
      EtatHorsLigne.miseAJour => (Icons.update_rounded, t.etatMiseAJour, ArcCouleurs.attention),
      EtatHorsLigne.aucun => (Icons.cloud_download_outlined, t.etatAucun, ArcCouleurs.texteDiscret),
    };
    return Card(
      child: InkWell(
        key: Key('formation_${formation.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/cours/${formation.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formation.titre, style: Theme.of(context).textTheme.titleLarge),
              if (cohortes.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(cohortes.join(' · '), style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 12),
              BarreProgression(pourcent: formation.progression),
              const SizedBox(height: 6),
              Text(
                t.formationsLecons(formation.nbLeconsTerminees, formation.nbLecons),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(icone, color: couleur),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      telechargement?.enCours ?? false
                          ? t.coursTelechargement(
                              tailleLisible(telechargement!.progres?.recus ?? 0),
                              tailleLisible(telechargement.progres?.total ?? formation.tailleTelechargement),
                            )
                          : texteEtat,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: couleur, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (etat != EtatHorsLigne.complet && formation.tailleTelechargement > 0)
                    Text(tailleLisible(formation.tailleTelechargement), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un cours : téléchargement pour le hors-ligne et liste des leçons.
class EcranCours extends ConsumerWidget {
  const EcranCours({super.key, required this.coursId});

  final int coursId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final formation = ref.watch(formationProvider(coursId)).value;
    final manifest = ref.watch(manifestProvider(coursId));
    final etats = ref.watch(etatsLeconsProvider(coursId)).value ?? const {};
    return Scaffold(
      appBar: AppBar(title: Text(formation?.titre ?? manifest.value?.titre ?? '')),
      body: Column(
        children: [
          const IndicateurSynchro(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (formation != null) ...[
                  BarreProgression(pourcent: formation.progression),
                  const SizedBox(height: 16),
                ],
                PanneauTelechargement(coursId: coursId, formation: formation, manifest: manifest.value),
                const SizedBox(height: 20),
                if (manifest.isLoading && manifest.value == null)
                  const Center(child: CircularProgressIndicator())
                else if (manifest.value == null)
                  Encadre(texte: t.coursLeconsIndisponibles)
                else
                  ..._lecons(context, ref, manifest.value!, etats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _lecons(BuildContext context, WidgetRef ref, Manifest m, Map<int, EtatLeconLocal> etats) {
    final t = AppLocalizations.of(context);
    final depot = ref.watch(servicesProvider).depot;
    ref.watch(telechargementsProvider.select((x) => x[coursId]));
    final widgets = <Widget>[];
    String? section;
    for (final l in m.lecons) {
      if (l.section != null && l.section != section) {
        section = l.section;
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              section!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ArcCouleurs.primaireFonce),
            ),
          ),
        );
      }
      final terminee = l.terminee || (etats[l.id]?.terminee ?? false);
      final disponible = depot.leconDisponible(l);
      widgets.add(
        Card(
          child: ListTile(
            key: Key('lecon_${l.id}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Icon(iconeLecon(l.type), size: 30, color: ArcCouleurs.primaire),
            title: Text(l.titre, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text(
              [
                libelleType(t, l.type),
                if (l.dureeMinutes > 0) t.leconMinutes(l.dureeMinutes),
                disponible ? t.leconHorsLigne : (l.horsLigne ? null : t.leconEnLigne),
              ].whereType<String>().join(' · '),
            ),
            trailing: terminee
                ? Semantics(
                    label: t.leconTerminee,
                    child: const Icon(Icons.check_circle_rounded, color: ArcCouleurs.progression, size: 30),
                  )
                : Icon(disponible ? Icons.offline_pin_outlined : Icons.cloud_outlined, color: ArcCouleurs.texteDiscret),
            onTap: () => context.push('/lecon/$coursId/${l.id}'),
          ),
        ),
      );
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }
}

class PanneauTelechargement extends ConsumerWidget {
  const PanneauTelechargement({super.key, required this.coursId, this.formation, this.manifest});

  final int coursId;
  final FormationLocale? formation;
  final Manifest? manifest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final services = ref.watch(servicesProvider);
    final etat = ref.watch(etatHorsLigneProvider((coursId, formation?.versionServeur ?? '')));
    final tele = ref.watch(telechargementsProvider.select((m) => m[coursId])) ?? const EtatTelechargement();
    final libre = ref.watch(placeLibreProvider).value;
    final reseau = ref.watch(reseauProvider).value;
    final notifier = ref.read(telechargementsProvider.notifier);
    final restant = manifest != null
        ? services.depot.octetsManquants(manifest!)
        : (formation?.tailleTelechargement ?? 0);
    final rien = manifest != null && manifest!.fichiersDistincts.isEmpty;

    final enfants = <Widget>[];
    if (rien) {
      enfants.add(Encadre(texte: t.coursRienATelecharger));
    } else if (tele.enCours) {
      final p = tele.progres;
      enfants.addAll([
        Text(
          t.coursTelechargement(tailleLisible(p?.recus ?? 0), tailleLisible(p?.total ?? restant)),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: p?.fraction, minHeight: 12),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: () => notifier.annuler(coursId), child: Text(t.annuler)),
      ]);
    } else {
      if (etat == EtatHorsLigne.complet) {
        enfants.add(Encadre(texte: t.coursTelechargementFini, icone: Icons.offline_pin_rounded));
      } else {
        enfants.add(Text(t.coursTaille(tailleLisible(restant)), style: Theme.of(context).textTheme.titleMedium));
        if (libre != null) {
          enfants.add(Text(t.coursPlaceLibre(tailleLisible(libre)), style: Theme.of(context).textTheme.bodyMedium));
        }
        final erreur = tele.erreur;
        if (erreur != null) {
          enfants.addAll([const SizedBox(height: 10), Encadre(texte: _texteErreur(t, erreur), attention: true)]);
        } else if (reseau == TypeReseau.mobile && services.reglages.wifiSeulement) {
          enfants.addAll([const SizedBox(height: 10), Encadre(texte: t.coursWifiSeulement, icone: Icons.wifi_rounded)]);
        }
        enfants.addAll([
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('bouton_telecharger'),
            onPressed: () => notifier.telecharger(coursId),
            icon: const Icon(Icons.download_rounded),
            label: Text(switch (etat) {
              EtatHorsLigne.miseAJour => t.coursMettreAJour,
              EtatHorsLigne.partiel => t.coursReprendre,
              _ => t.coursTelecharger,
            }),
          ),
        ]);
      }
      if (etat != EtatHorsLigne.aucun) {
        enfants.add(
          TextButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  content: Text(t.coursSupprimerConfirmer, style: Theme.of(c).textTheme.bodyLarge),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(t.annuler)),
                    FilledButton(onPressed: () => Navigator.of(c).pop(true), child: Text(t.coursSupprimer)),
                  ],
                ),
              );
              if (ok ?? false) await notifier.supprimer(coursId);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(t.coursSupprimer),
          ),
        );
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: enfants),
      ),
    );
  }

  static String _texteErreur(AppLocalizations t, String erreur) {
    if (erreur == 'wifi') return t.coursWifiSeulement;
    if (erreur == 'reseau') return t.coursPasDeReseau;
    if (erreur == 'fichier') return t.coursErreurFichier;
    if (erreur.startsWith('place:')) {
      final morceaux = erreur.split(':');
      return t.coursPlaceInsuffisante(tailleLisible(int.parse(morceaux[1])), tailleLisible(int.parse(morceaux[2])));
    }
    return t.erreurInconnue;
  }
}
