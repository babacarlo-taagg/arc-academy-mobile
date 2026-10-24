import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/api/modeles.dart';
import 'core/providers.dart';
import 'core/theme.dart';
import 'features/connexion/ecrans_connexion.dart';
import 'features/formations/ecrans_formations.dart';
import 'features/lecteur/ecran_lecteur.dart';
import 'features/profils/ecrans_profils.dart';
import 'features/reglages/ecran_reglages.dart';
import 'features/reglages/ecran_suppression.dart';
import 'l10n/app_localizations.dart';

/// Écrans qui demandent un profil déverrouillé.
const _routesProfil = ['/formations', '/cours', '/lecon', '/reglages'];

final routeurProvider = Provider<GoRouter>((ref) {
  final rafraichir = ValueNotifier<int>(0);
  ref.listen(profilOuvertProvider, (_, _) => rafraichir.value++);
  ref.onDispose(rafraichir.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: rafraichir,
    redirect: (context, etat) async {
      final chemin = etat.matchedLocation;
      final ouvert = ref.read(profilOuvertProvider) != null;
      if (_routesProfil.any(chemin.startsWith) && !ouvert) return '/';
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
    ],
  );
});

class AppliArc extends ConsumerWidget {
  const AppliArc({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).nomAppli,
      debugShowCheckedModeBanner: false,
      theme: construireTheme(),
      routerConfig: ref.watch(routeurProvider),
      locale: const Locale('fr'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
