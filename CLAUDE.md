# Appli mobile ARC Academy — repères pour Claude

- Babacar (fondateur) développe seul avec Claude ; il travaille en français. Explications simples, sans jargon.
- Projet **ARC Academy, séparé de TAAGG** : ne rien mélanger avec `taagg-mobile` / `taagg-odoo` (on peut s'en inspirer).
- Public : acteurs de santé en zone rurale (infirmiers, sages-femmes, agents communautaires, pharmaciens…).
  Téléphones Android d'entrée de gamme (2–3 Go, Android 9+), souvent partagés ; réseau rare et cher.
  **Tout doit marcher sans réseau** ; rien ne doit se perdre (file d'événements, voir `docs/architecture-hors-ligne.md`).
- Flutter stable, Riverpod 3, go_router, dio, drift (SQLite3MultipleCiphers, base chiffrée par profil), flutter_secure_storage.
- `api/openapi.yaml` est la source de vérité. Toute évolution : contrat → `lib/core/api/` → module Odoo `arc_mobile_api`
  (dépôt `arc-academy-odoo`).
- Connexion : code reçu **par e-mail uniquement** (ni WhatsApp ni SMS, décision du 20 octobre 2026).
- Données de santé minimales : aucune donnée de patient dans l'appli. Aucun secret dans le dépôt.
- Textes dans `lib/l10n/app_fr.arb` uniquement (le wolof viendra dans `app_wo.arb`). Phrases courtes, tutoiement.
- Couleurs dans `lib/core/theme.dart` (`ArcCouleurs`), provisoires tant qu'ARC n'a pas fourni sa charte.
- Avant de committer : `dart format -l 120 lib test integration_test test_driver`, `flutter analyze` sans remarque,
  `flutter test` vert. Captures d'écran : `flutter test --tags captures --update-goldens` (fichiers dans `docs/captures/`).
- Les tests d'écrans parlent à un faux serveur (`test/outils/faux_serveur.dart`) : appeler `preparerReseauReel()` dans
  `setUp`, ne pas attendre une écriture de la base dans `tester.runAsync` pendant qu'une synchro tourne (blocage).
- Le SDK Android ne s'installe pas dans les sessions cloud : APK, émulateur et iOS sont construits par GitHub Actions
  (`.github/workflows/appli.yml`).
