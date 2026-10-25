# Marque ARC — couleurs, police, fichiers

Source : logo officiel publié sur https://academy.africaresourcecentre.org (SVG du site) et palette du thème
du site ARC Academy (refonte de septembre 2026). **À faire valider par ARC** : si la charte graphique officielle
donne d'autres valeurs, elles remplacent celles-ci.

## Couleurs

| Rôle | Code | Usage conseillé dans l'appli |
|---|---|---|
| **Principale** — teal ARC | `#204040` | barre du haut, boutons principaux, fond de l'icône adaptative si fond sombre voulu |
| Principale foncée | `#152B2B` | état appuyé, en-têtes sombres |
| **Secondaire** — or ARC | `#D79C34` | éléments mis en avant, badges, progression. ⚠ Contraste faible sur blanc : pas pour du texte sur fond clair |
| **Accent** — cuivre (point du logo) | `#C89163` | petites touches, illustrations |
| Sable (point du logo) | `#F3D1AD` | fonds légers d'accent |
| Taupe (point du logo) | `#A49180` | éléments discrets |
| Encre (texte) | `#12100B` | texte principal |
| Noir du logo | `#05090B` | logo sur fond clair uniquement |
| Papier (fond) | `#F6F4EF` | fond des écrans, fond de l'icône |
| Blanc | `#FFFFFF` | cartes |

Contraste du texte : blanc sur `#204040` et `#12100B` sur `#F6F4EF` sont largement lisibles (AA). Éviter le texte
or `#D79C34` sur blanc ou papier.

## Police

Pas de police imposée connue à ce jour par la charte d'ARC. Le logo utilise une linéale géométrique fine ;
**Lexend** (déjà dans `assets/fonts/`) reste adaptée et très lisible pour un public non spécialiste. À confirmer par ARC.

## Fichiers de ce dossier

| Fichier | Contenu |
|---|---|
| `icone-1024.png` (+ `.svg`) | icône carrée 1024×1024, symbole ARC (hexagone) sur fond papier plein `#F6F4EF` — nom attendu par `flutter_launcher_icons.yaml` |
| `icone-premier-plan-1024.png` | symbole seul, transparent, dans la zone sûre (66 %) — pour `adaptive_icon_foreground` Android (fond conseillé : `#F6F4EF`) |
| `logo-symbole-transparent.png` (+ `.svg`) | symbole seul, sans fond |
| `logo-horizontal.svg` / `.png` | logo complet « ARC Africa Resource Centre », noir, sans fond |
| `logo-horizontal-clair.svg` | logo complet en clair, pour fond sombre (teal) |

Images de fiche Google Play (dans `store/android/fr-FR/images/`) : `icone-512.png`, `presentation-1024x500.png`.
