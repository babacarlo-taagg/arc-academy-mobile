import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/api/modeles.dart';
import 'core/profil/service_profil.dart';
import 'core/providers.dart';
import 'core/push/service_push.dart';
import 'core/theme.dart';
import 'features/connexion/ecrans_connexion.dart';
import 'features/formations/ecrans_formations.dart';
import 'features/lecteur/ecran_lecteur.dart';
import 'features/notifications/ecrans_notifications.dart';
import 'features/profil/ecrans_profil.dart';
import 'features/profils/ecrans_profils.dart';
import 'features/reglages/ecran_reglages.dart';
import 'features/reglages/ecran_suppression.dart';
import 'l10n/app_localizations.dart';

/// Écrans qui demandent un profil déverrouillé.
const _routesProfil = ['/formations', '/cours', '/lecon', '/reglages', '/ton-profil', '/institution', '/notifications'];

/// Écran « Ton profil » (pays et métier), obligatoire tant qu'ils manquent.
const _routeProfilObligatoire = '/ton-profil';

final routeurProvider = Provider<GoRouter>((ref) {
  final rafraichir = ValueNotifier<int>(0);
  ref.listen(profilOuvertProvider, (_, _) => rafraichir.value++);
  ref.listen(profilApprenantProvider.select((p) => p.value?.etat), (_, _) => rafraichir.value++);
  ref.onDispose(rafraichir.dispose);
  late final GoRouter routeur;
  final push = ref.read(servicesProvider).push;
  final touchees = push.touchees.listen((m) => unawaited(_ouvrirNotification(ref, routeur, m)));
  ref.onDispose(touchees.cancel);
  unawaited(
    push.messageDeDepart().then((m) {
      if (m != null) unawaited(_ouvrirNotification(ref, routeur, m));
    }),
  );
  return routeur = GoRouter(
    initialLocation: '/',
    refreshListenable: rafraichir,
    redirect: (context, etat) async {
      final chemin = etat.matchedLocation;
      final ouvert = ref.read(profilOuvertProvider) != null;
      if (_routesProfil.any(chemin.startsWith) && !ouvert) return '/';
      if (ouvert && _routesProfil.any(chemin.startsWith)) {
        final etat = ref.read(profilOuvertProvider)!.profilApprenant.actuel.etat;
        if (etat != EtatProfil.pret && chemin != _routeProfilObligatoire) return _routeProfilObligatoire;
        if (etat == EtatProfil.pret && chemin == _routeProfilObligatoire) return '/formations';
      }
      // Après une notification touchée et le code secret : la boîte de réception du bon profil.
      final attendu = ref.read(ouvertureNotificationProvider);
      if (ouvert && attendu != null && chemin == '/formations') {
        ref.read(ouvertureNotificationProvider.notifier).attendre(null);
        if (ref.read(profilOuvertProvider)!.profil.apprenantId == attendu) return '/notifications';
      }
      if (chemin == '/') {
        if (ouvert) return '/formations';
        final profils = await ref.read(servicesProvider).profils.profils();
        return profils.isEmpty ? '/connexion' : '/profils';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
      GoRoute(path: '/profils', builder: (_, _) => const EcranProfils()),
      GoRoute(
        path: '/connexion',
        builder: (_, e) => EcranConnexion(emailInitial: e.extra as String?),
      ),
      GoRoute(
        path: '/connexion/code',
        builder: (_, e) {
          final (email, envoi) = e.extra! as (String, CodeEnvoye);
          return EcranCode(email: email, envoi: envoi);
        },
      ),
      GoRoute(
        path: '/pin/:id',
        builder: (_, e) => EcranPin(profilId: e.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pin/:id/creer',
        builder: (_, e) => EcranCreerPin(profilId: e.pathParameters['id']!),
      ),
      GoRoute(path: '/formations', builder: (_, _) => const EcranFormations()),
      GoRoute(path: _routeProfilObligatoire, builder: (_, _) => const EcranProfilObligatoire()),
      GoRoute(path: '/institution', builder: (_, _) => const EcranInstitution()),
      GoRoute(
        path: '/cours/:id',
        builder: (_, e) => EcranCours(coursId: int.parse(e.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/lecon/:cours/:lecon',
        builder: (_, e) => EcranLecteur(
          coursId: int.parse(e.pathParameters['cours']!),
          leconId: int.parse(e.pathParameters['lecon']!),
        ),
      ),
      GoRoute(path: '/reglages', builder: (_, _) => const EcranReglages()),
      GoRoute(path: '/reglages/suppression', builder: (_, _) => const EcranSuppression()),
      GoRoute(path: '/reglages/profil', builder: (_, _) => const EcranMonProfil()),
      GoRoute(path: '/reglages/notifications', builder: (_, _) => const EcranPreferencesNotifications()),
      GoRoute(path: '/notifications', builder: (_, _) => const EcranBoiteReception()),
    ],
  );
});

/// Notification touchée : le profil concerné, après son code secret, puis sa boîte de réception.
/// Sur un téléphone partagé, rien du message n'apparaît avant le code secret du bon profil.
Future<void> _ouvrirNotification(Ref ref, GoRouter routeur, MessagePush message) async {
  final apprenantId = message.apprenantId;
  final ouvert = ref.read(profilOuvertProvider);
  if (ouvert != null && (apprenantId == null || ouvert.profil.apprenantId == apprenantId)) {
    unawaited(ouvert.notifications.rafraichir());
    unawaited(routeur.push('/notifications'));
    return;
  }
  if (apprenantId == null) return;
  final profil = (await ref.read(servicesProvider).profils.profils())
      .where((p) => p.apprenantId == apprenantId)
      .firstOrNull;
  if (profil == null) return;
  if (ouvert != null) await ref.read(profilOuvertProvider.notifier).fermer();
  ref.read(ouvertureNotificationProvider.notifier).attendre(apprenantId);
  routeur.go('/pin/${profil.id}');
}

class AppliArc extends ConsumerWidget {
  const AppliArc({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).nomAppli,
      debugShowCheckedModeBanner: false,
      theme: construireTheme(),
      routerConfig: ref.watch(routeurProvider),
      // La langue du profil, sinon celle du téléphone (anglais ou, à défaut, français).
      locale: switch (ref.watch(langueAppliProvider)) {
        final String l => Locale(l),
        null => null,
      },
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, _) => Locale(locale?.languageCode == 'en' ? 'en' : 'fr'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
