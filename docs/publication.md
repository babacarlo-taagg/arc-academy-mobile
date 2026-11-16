# Publier l'appli ARC Academy (pilote, Google Play, TestFlight)

Tout se fait sur GitHub, dans l'onglet **Actions** du dépôt `arc-academy-mobile`, workflow **Publication**.
L'appli construite là parle au vrai serveur : `https://academy.africaresourcecentre.org/api/v1`.

## 1. Les secrets (une seule fois)

GitHub › dépôt `arc-academy-mobile` › **Settings › Secrets and variables › Actions › New repository secret**.
Jamais dans le dépôt, jamais dans une conversation.

| Secret | Contenu | Sert à |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | le fichier `arc-academy-upload.jks`, encodé en base64 | signer l'appli Android |
| `ANDROID_KEYSTORE_PASSWORD` | mot de passe du fichier `.jks` | idem |
| `ANDROID_KEY_ALIAS` | `arc-academy` | idem |
| `ANDROID_KEY_PASSWORD` | mot de passe de la clé | idem |
| `PLAY_SERVICE_ACCOUNT_JSON` | contenu du fichier JSON du compte de service Google | envoi automatique à Google Play |
| `APP_STORE_CONNECT_KEY_ID` | identifiant de la clé d'API App Store Connect | envoi à TestFlight |
| `APP_STORE_CONNECT_ISSUER_ID` | identifiant de l'émetteur (Issuer ID) | idem |
| `APP_STORE_CONNECT_KEY_P8_BASE64` | le fichier `AuthKey_XXXX.p8`, encodé en base64 | idem |
| `APPLE_TEAM_ID` | identifiant d'équipe Apple (10 caractères) | idem |
| `FIREBASE_PROJECT_ID` | identifiant du projet Firebase (ex. `arc-academy-12345`) | notifications sur le téléphone |
| `FIREBASE_SENDER_ID` | numéro de l'expéditeur (« Project number », 12 chiffres) | idem |
| `FIREBASE_API_KEY_ANDROID` | clé de l'appli Android dans Firebase (commence par `AIza`) | idem |
| `FIREBASE_APP_ID_ANDROID` | identifiant de l'appli Android dans Firebase (`1:…:android:…`) | idem |
| `FIREBASE_API_KEY_IOS` | clé de l'appli iOS dans Firebase (commence par `AIza`) | idem |
| `FIREBASE_APP_ID_IOS` | identifiant de l'appli iOS dans Firebase (`1:…:ios:…`) | idem |

Sans ces secrets, la publication marche quand même : l'appli Android est signée avec la clé de développement (bonne
pour le pilote, refusée par Google Play) et l'iOS est seulement compilé. Le résumé de chaque exécution le signale.

### Les notifications (Firebase), une seule fois

Les notifications sur le téléphone passent par **Firebase Cloud Messaging** (Google, gratuit). Sans les secrets
`FIREBASE_*`, l'appli est construite sans elles : tout le reste marche, et les messages d'ARC arrivent quand même
dans « Mes messages » à chaque passage réseau.

1. <https://console.firebase.google.com> › **Ajouter un projet** : nom « ARC Academy », sans Google Analytics.
2. Dans le projet : **Ajouter une appli › Android**, nom du paquet `org.africaresourcecentre.academy`.
   Ne pas télécharger `google-services.json` (inutile : les réglages passent par les secrets). Terminer.
3. **Ajouter une appli › iOS**, identifiant du bundle `org.africaresourcecentre.academy`. Ne pas télécharger
   `GoogleService-Info.plist`. Terminer.
4. Roue dentée › **Paramètres du projet › Général** : on y lit l'**ID du projet** (`FIREBASE_PROJECT_ID`) et le
   **Numéro du projet** (`FIREBASE_SENDER_ID`) ; plus bas, pour chaque appli, l'**ID d'application**
   (`FIREBASE_APP_ID_ANDROID`, `FIREBASE_APP_ID_IOS`). La **clé API Web** ne sert pas : la clé de chaque appli est
   dans le fichier qu'on n'a pas téléchargé — cliquer sur l'appli › `google-services.json` (Android, valeur
   `current_key`) ou `GoogleService-Info.plist` (iOS, valeur `API_KEY`), recopier la clé, puis supprimer le fichier.
5. Pour l'iPhone : developer.apple.com › Certificates, IDs & Profiles › **Keys › +** : nom « ARC Academy
   notifications », cocher **Apple Push Notifications service (APNs)**, télécharger le fichier `.p8` (une seule fois)
   et noter son **Key ID**. Dans Firebase › Paramètres du projet › **Cloud Messaging** › appli iOS › **Clé
   d'authentification APNs › Importer** : le fichier `.p8`, le Key ID et le Team ID. Supprimer ensuite le `.p8` de
   l'ordinateur.
6. Dans developer.apple.com › **Identifiers** › `org.africaresourcecentre.academy` : cocher **Push Notifications**
   et enregistrer (l'appli le demande désormais).
7. Côté serveur (Odoo), le **compte de service** Firebase (Paramètres du projet › Comptes de service › Générer une
   nouvelle clé privée) se saisit dans Odoo, jamais dans GitHub ni dans une conversation : voir la documentation du
   module `arc_notifications` dans le dépôt `arc-academy-odoo`.

Ces valeurs (sauf la clé privée du compte de service) ne sont pas vraiment secrètes — elles finissent dans l'appli —
mais on les garde dans les secrets pour qu'elles ne soient pas dans le dépôt.

## 2. Lancer une publication

À chaque envoi de code sur `main` (ou sur la branche de travail), une version est construite automatiquement, sans
rien envoyer aux stores. Pour envoyer :

1. GitHub › **Actions** › **Publication** › bouton **Run workflow**.
2. Cocher **Envoyer l'AAB à Google Play** (piste **production** par défaut, ou `internal`) et/ou **Envoyer la
   version iOS à App Store Connect**.
3. **Run workflow**. Compter 15 à 30 minutes. Le résumé de l'exécution dit ce qui a été construit, sa taille, et ce
   qui a été envoyé.

Chaque exécution a son propre numéro de version (numéro d'exécution GitHub) : les stores acceptent ainsi chaque envoi.

## 3. Pilote sans store : installer l'APK sur un téléphone

1. Ouvrir la dernière exécution réussie de **Publication** › en bas, **Artifacts** › `android-apk-pilote-…`
   (un fichier zip).
2. Dans le zip, prendre **`app-arm64-v8a-release.apk`** (presque tous les téléphones récents). Pour un téléphone très
   ancien, `app-armeabi-v7a-release.apk`.
3. L'envoyer sur le téléphone (WhatsApp, câble, clé USB, Bluetooth).
4. Sur le téléphone, toucher le fichier. Android demande d'**autoriser l'installation d'applications inconnues**
   pour l'appli qui ouvre le fichier (WhatsApp, Fichiers…) : accepter, puis **Installer**.
5. Ouvrir ARC Academy, taper son adresse e-mail, puis le code reçu par e-mail.

Une version de l'APK signée avec la clé de développement ne pourra pas être mise à jour par la version Google Play :
au passage au store, désinstaller l'APK du pilote d'abord (la progression déjà envoyée est sur le serveur).

## 4. Google Play : le premier envoi se fait à la main

Google exige que le tout premier fichier soit déposé dans Play Console :
1. Lancer **Publication** une fois les secrets `ANDROID_KEYSTORE_*` créés (pas besoin de cocher l'envoi).
2. Télécharger l'artefact `android-aab-…` (zip contenant `app-release.aab`).
3. Play Console › ARC Academy › **Tester › Test interne › Créer une version** › déposer `app-release.aab` ›
   Enregistrer › Examiner › Déployer.

Ensuite (décision du 1er novembre 2026 : publication publique directe, sans phase de test), cocher **Envoyer l'AAB
à Google Play** avec la piste **production** : la version arrive en **brouillon** ; dans Play Console, Publier ›
Production › Modifier la version › Envoyer en examen.

## 5. App Store Connect (TestFlight et App Store)

Avec les 4 secrets Apple et la case **Envoyer la version iOS à App Store Connect** cochée, la version part directement
vers App Store Connect (signature « cloud » par la clé d'API : la clé doit avoir le rôle **Admin**, sinon Apple
refuse de créer le certificat de distribution). Dans App Store Connect, rattacher le build à la version **1.0.0**
puis l'envoyer en vérification. Apple la traite en 10 à 30 minutes, puis elle apparaît dans **TestFlight** : l'ajouter au groupe
« Pilote ARC ». La première fois, App Store Connect pose une question sur le **chiffrement** : l'appli utilise
seulement des méthodes standard (connexion HTTPS, base de données chiffrée sur le téléphone).

## En cas d'erreur

Ouvrir l'exécution en rouge, puis l'étape en rouge : le message d'erreur est en bas. Le copier (sans jamais copier
un secret) pour la session Claude Code.
