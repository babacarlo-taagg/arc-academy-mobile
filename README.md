# ARC Academy Mobile

Appli de formation continue d'ARC Academy pour les acteurs de santé en zone rurale : les formations se suivent
**sans réseau**, et la progression remonte toute seule dès que le réseau passe.

| Dossier | Contenu |
|---|---|
| `api/` | Contrat d'API (`openapi.yaml`) partagé avec le module Odoo `arc_mobile_api`, serveur bouchon |
| `lib/` | L'appli (Flutter) |
| `test/` | Tests automatiques (dont coupures de réseau) et captures d'écran |
| `integration_test/` | Parcours complet sur téléphone ou émulateur |
| `docs/` | Architecture hors ligne, captures |

## Essayer sans Odoo (serveur bouchon)

```bash
cd api && npm install && npm run bouchon      # répond sur le port 4010
flutter run                                   # l'émulateur Android voit l'ordinateur en 10.0.2.2
```
Avec le bouchon, n'importe quel code à 6 chiffres est accepté.

## Essayer avec la base ARC

```bash
flutter run --dart-define=API_BASE_URL=https://academy.africaresourcecentre.org/api/v1
```
Le module `arc_mobile_api` doit être installé sur le serveur.

## Publier (pilote, Google Play, TestFlight)

Tout se fait dans GitHub Actions (workflow « Publication ») : mode d'emploi dans `docs/publication.md`.

**Icône** : quand le logo d'ARC est déposé dans `assets/marque/icone-1024.png` (carré, 1024×1024, fond plein) :
```bash
dart run flutter_launcher_icons
```
puis committer les icônes générées (`android/app/src/main/res/mipmap-*`, `ios/Runner/Assets.xcassets/AppIcon.appiconset`).
Réglages dans `flutter_launcher_icons.yaml`.

## Tests

```bash
flutter test                                   # tous les tests
flutter test --tags captures --update-goldens  # refaire les captures de docs/captures
```

**Essai de bout en bout avec le vrai Odoo** (base de démonstration de `arc-academy-odoo`,
`scripts/preparer_base_demo_mobile.py`, code de test 123456) :
```bash
ARC_E2E_URL=http://127.0.0.1:8069/api/v1 flutter test test/e2e
```
Connexion par code, téléchargement du cours coupé au milieu puis repris, article et PDF lus sans le serveur, module
SCORM joué deux fois dans Chromium (reprise à la bonne page), envoi de la progression dont la réponse se perd,
puis vérification côté Odoo : tout est compté une fois, score 80, reprise disponible pour un autre téléphone.
À lancer sur une base fraîche (l'apprenante `awa.demo` ne doit pas avoir déjà avancé).
À chaque envoi sur GitHub, l'intégration continue lance aussi : la construction des APK (avec leur taille), le parcours
sur un émulateur Android 9 bas de gamme au réseau lent (avec captures), et la compilation iOS.
