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
flutter run --dart-define=API_BASE_URL=https://2-28-114-138.sslip.io/api/v1
```
Le module `arc_mobile_api` doit être installé sur le serveur.

## Tests

```bash
flutter test                                   # tous les tests
flutter test --tags captures --update-goldens  # refaire les captures de docs/captures
```
À chaque envoi sur GitHub, l'intégration continue lance aussi : la construction des APK (avec leur taille), le parcours
sur un émulateur Android 9 bas de gamme au réseau lent (avec captures), et la compilation iOS.
