# Prompt — session Claude Cowork « publication sur les stores »

À coller tel quel dans une session Claude Cowork ouverte sur l'ordinateur de Babacar (navigateur connecté à
Google Play Console, App Store Connect, GitHub et Odoo ARC). La session « code » (Claude Code, dépôts
`arc-academy-mobile` et `arc-academy-odoo`) fait la partie programmation et répond aux questions de Cowork.

---

Tu vas préparer la publication de **ARC Academy Mobile** sur Google Play et l'App Store, pour un **pilote fermé**
(test interne Google Play + TestFlight), pas encore une publication publique. Je suis Babacar, je travaille en
français : explique simplement, sans jargon, une étape à la fois.

## Travailler avec la session code (Claude Code)
Une autre session Claude, **« ARC Academy Mobile application »** (identifiant `session_01GBCHhxTz2iQAaN4FgURAmS`),
a écrit l'appli et le serveur. Elle construit l'appli dans GitHub Actions et répond à tes questions techniques.

**Pour lui écrire :**
1. Si tu as l'outil `send_message` (serveur MCP `claude-code-remote` ; sinon cherche-le avec ToolSearch), envoie
   tes messages à `session_01GBCHhxTz2iQAaN4FgURAmS`. Commence chaque message par `[Cowork stores]` et indique
   **ton propre identifiant de session** pour qu'elle puisse te répondre directement.
2. Sinon (ou en plus, pour garder une trace) : ajoute ta question dans le fichier **`store/echanges.md`** du dépôt
   `arc-academy-mobile` (branche `claude/awesome-pasteur-onk06u`, GitHub › Add file / bouton crayon), sous un titre
   `## Question Cowork — <date et heure>`, puis dis-moi : « Préviens la session code de lire store/echanges.md ».

**Pour lire ses réponses :** elle te répond par `send_message` si tu lui as donné ton identifiant, et écrit
toujours aussi sa réponse dans `store/echanges.md` (`## Réponse session code — …`). Relis ce fichier sur GitHub
quand tu attends une réponse.

**Ce que tu lui envoies** : seulement des informations non secrètes (où tu en es, ce qui bloque, un message
d'erreur, un nom de secret créé, une URL, un identifiant d'app). **Jamais** un mot de passe, une clé, un fichier
JSON, une clé `.p8`, ni le code du compte de démonstration.

**Quand lui écrire** : quand un secret GitHub est créé (elle relance la construction signée) ; quand Play Console
ou App Store Connect demande une information technique (chiffrement, permissions, taille, version, captures) ;
quand une construction GitHub Actions est en rouge ; quand tout est fini (compte rendu, étape 6).

## Le projet en bref
- Appli Flutter de formation continue d'ARC Academy pour les acteurs de santé en zone rurale (Afrique de l'Ouest) :
  cours téléchargés et suivis **sans réseau**, progression envoyée au retour du réseau. Connexion par **code reçu
  par e-mail**. Aucune donnée de patient. Gratuit, sans publicité, sans achat.
- Dépôt de l'appli : `github.com/babacarlo-taagg/arc-academy-mobile`, branche `claude/awesome-pasteur-onk06u`.
  À lire : `docs/publication.md` (secrets, construction, envoi aux stores, pilote), `README.md`, captures dans
  `docs/captures/` (dont `09_suppression_compte.png`).
- Serveur : Odoo 20 sur **https://academy.africaresourcecentre.org** (module `arc_mobile_api` installé, e-mails
  envoyés par SMTP2GO depuis `noreply@academy.africaresourcecentre.org`).
- Identifiant d'appli (Android et iOS) : **`org.africaresourcecentre.academy`**. Nom : **ARC Academy**.
  Version : 0.1.0. Assistant IA à venir : AYSHA (pas dans cette version). Langue : français (wolof plus tard).
- Déjà dans l'appli : **suppression de compte** (Réglages › Supprimer mon compte) ; aucune permission sensible
  (pas de caméra, micro, localisation, contacts) ; données chiffrées sur le téléphone ; connexion HTTPS.
- **Compte de démonstration** pour les vérificateurs : `demo.store@academy.africaresourcecentre.org`. Je te donnerai
  le code moi-même (il ne doit aller que dans Play Console et App Store Connect).
- ARC porte la déclaration à la CDP (Commission de protection des données personnelles du Sénégal).
- J'ai : le compte Google Play Console d'ARC, le compte Apple Developer d'ARC, le logo et les couleurs d'ARC.

## Règles absolues
1. **Aucun secret dans une conversation, un message à la session code, un fichier du dépôt ou un document
   partagé** : mots de passe, clé de signature, fichier JSON de compte de service, clé `.p8` d'Apple, code du compte
   de démonstration. Ils vont seulement dans mon gestionnaire de mots de passe, dans les **secrets GitHub** (dépôt
   `arc-academy-mobile` › Settings › Secrets and variables › Actions) et dans les formulaires des stores. Je tape
   moi-même les mots de passe quand c'est demandé.
2. **Demande-moi avant** tout paiement, toute acceptation de contrat ou de conditions, tout envoi en vérification
   (« Submit for review »), toute invitation de testeurs.
3. Pas de publication publique (piste « Production » de Google, version publique de l'App Store) : seulement
   **test interne** Google Play et **TestFlight**.
4. Ne modifie pas le code de l'appli : c'est la session code. Tu peux seulement déposer des fichiers dans
   `assets/marque/` et `store/` du dépôt.

## Ce que tu fais, dans l'ordre

### 1. Marque (pour l'icône et les couleurs de l'appli)
- Dépose dans le dépôt, branche `claude/awesome-pasteur-onk06u`, dossier `assets/marque/` (GitHub › Add file ›
  Upload files) : **`icone-1024.png`** (logo carré 1024×1024 sur fond plein, nom exact attendu par l'appli), une
  version **sans fond** (PNG transparent), et le logo horizontal s'il existe.
- Crée `assets/marque/couleurs.md` : couleurs d'ARC en code hexadécimal (#RRGGBB) avec leur usage (principale,
  secondaire, accent), police si la charte en impose une.
- Préviens la session code : elle génère l'icône et applique les couleurs.

### 2. Clé de signature Android (une seule fois, à ne jamais perdre)
- Sur mon ordinateur, crée la **clé d'envoi** (« upload key ») avec `keytool` (installe un JDK 17 si besoin) :
  fichier `arc-academy-upload.jks`, alias `arc-academy`, validité 10 000 jours, RSA 2048. Je tape le mot de passe.
- Range le fichier `.jks` et son mot de passe dans mon gestionnaire de mots de passe, plus une copie hors ligne
  (clé USB). **Jamais dans le dépôt.**
- Crée les secrets GitHub `ANDROID_KEYSTORE_BASE64` (le `.jks` en base64 ; sous Windows :
  `[Convert]::ToBase64String([IO.File]::ReadAllBytes("arc-academy-upload.jks"))`, copié directement dans GitHub),
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (= `arc-academy`), `ANDROID_KEY_PASSWORD`.
- Préviens la session code (« secrets Android créés ») : elle vérifie que la construction signée passe.
- Dans Play Console, garde **la signature d'application par Google Play** activée.

### 3. Pages web obligatoires (dans Odoo, Site web › Pages)
- **Politique de confidentialité** : `https://academy.africaresourcecentre.org/confidentialite`. Rédige-la en
  français simple (et une version anglaise sur la même page) et **fais-la valider par ARC avant publication**.
  Contenu : responsable du traitement (ARC, coordonnées, contact pour les données) ; données traitées (nom, adresse
  e-mail, cohorte, progression et résultats des cours, temps passé, identifiant technique et modèle du téléphone ;
  **aucune donnée de patient**) ; finalités (formation, suivi par le tuteur et le responsable de cohorte,
  attestation) ; base légale ; durée de conservation (à fixer avec ARC) ; destinataires (ARC, tuteurs et référents
  de la cohorte ; prestataires : hébergement Hetzner en Allemagne, envoi des e-mails SMTP2GO) et **transfert hors du
  Sénégal** (à couvrir dans la déclaration CDP d'ARC) ; sécurité (connexion chiffrée, données chiffrées sur le
  téléphone, effacement à distance d'un profil) ; droits (accès, rectification, suppression, opposition) et comment
  les exercer, y compris depuis l'appli (Réglages › Supprimer mon compte) ; référence de la déclaration CDP d'ARC
  (emplacement si le numéro n'est pas encore connu) ; date de mise à jour. Ajoute : l'assistant IA AYSHA, quand il
  arrivera, ne sera utilisé qu'avec un consentement explicite.
- **Suppression de compte** : `https://academy.africaresourcecentre.org/suppression-compte`. Explique les deux
  façons de demander la suppression : dans l'appli (Réglages › Supprimer mon compte) ou par e-mail au support d'ARC
  avec l'adresse du compte ; ce qui est supprimé ; ce qui peut être gardé et combien de temps (par exemple
  attestations délivrées) ; délai de traitement : 30 jours.
- Une page **Aide / support** si elle n'existe pas (adresse e-mail de contact).

### 4. Google Play Console
- Crée l'appli : nom « ARC Academy », langue par défaut **français (fr-FR)**, application (pas jeu), **gratuite**.
- Remplis « Contenu de l'application » :
  - Politique de confidentialité : URL ci-dessus.
  - Accès à l'appli : identifiants requis → adresse `demo.store@academy.africaresourcecentre.org` et le code que je
    te donne, avec cette consigne : « Saisir l'adresse, toucher Recevoir un code, puis saisir ce code (aucun e-mail
    n'est envoyé pour ce compte de démonstration). »
  - Publicités : aucune. Classification du contenu : questionnaire (appli éducative, aucun contenu sensible).
  - Public cible : **18 ans et plus** (professionnels de santé).
  - Sécurité des données : données collectées = nom, adresse e-mail, activité dans l'appli (progression), identifiant
    de l'appareil ; toutes **chiffrées en transit** ; aucune vendue ni partagée à des tiers à des fins
    publicitaires ; suppression possible dans l'appli et par l'URL de suppression de compte.
  - Déclarations « applis de santé » si demandé : appli de **formation** pour professionnels, pas un dispositif
    médical, aucune donnée de santé de patients.
- Fiche du store (brouillon, en français) : description courte (80 caractères max) et longue (claire, sans
  promesse médicale), catégorie **Éducation**, e-mail de contact, site `https://academy.africaresourcecentre.org`,
  icône 512×512 (à partir du logo), image de présentation 1024×500, au moins 4 captures téléphone
  (`docs/captures/` en attendant des captures aux couleurs d'ARC, que la session code produira après l'étape 1).
  Dépose aussi les textes dans `store/android/fr-FR/` (titre, description courte, description longue).
- **Compte de service** : dans Google Cloud (projet lié à Play Console), crée un compte de service et une clé JSON ;
  dans Play Console › Utilisateurs et autorisations, donne-lui le droit de publier sur les pistes de test de cette
  appli. Mets le contenu du JSON dans le secret GitHub **`PLAY_SERVICE_ACCOUNT_JSON`**, puis supprime le fichier
  JSON de mon ordinateur.
- Piste **Test interne** : liste de testeurs « Pilote ARC » (je te donnerai les adresses ; comptes Google, Gmail par
  exemple). **Premier envoi à la main** : suis `docs/publication.md` § 4 (artefact `android-aab-…` de la dernière
  exécution verte de GitHub › Actions › Publication, une fois les secrets Android créés). Les suivants partent
  depuis GitHub (case « Envoyer l'AAB au test interne Google Play »).
- Si Play Console impose 12 testeurs pendant 14 jours (compte personnel récent), dis-le-moi tout de suite.

### 5. Apple (App Store Connect et Developer)
- Developer › Identifiers : enregistre l'identifiant **`org.africaresourcecentre.academy`**.
- App Store Connect : nouvelle app, plateforme iOS, nom « ARC Academy » (si le nom est pris, propose-moi des
  variantes, par exemple « ARC Academy Santé »), langue principale **français**, SKU `arc-academy-mobile`.
- Remplis : confidentialité de l'app (mêmes données que pour Google, aucune utilisée pour le suivi publicitaire),
  URL de confidentialité, URL d'assistance, catégorie **Éducation**, classification par âge (questionnaire), prix
  gratuit, informations pour la vérification (compte de démonstration ci-dessus, même consigne). Question sur le
  **chiffrement** : demande à la session code avant de répondre. Textes dans `store/ios/fr-FR/`.
- **Clé d'API App Store Connect** (Utilisateurs et accès › Intégrations › Clés, rôle « App Manager ») : secrets
  GitHub `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_P8_BASE64` (le `.p8` en
  base64 ; supprime-le ensuite de mon ordinateur) et `APPLE_TEAM_ID` (10 caractères). Préviens la session code.
- TestFlight : groupe de testeurs internes « Pilote ARC » (je te donnerai les adresses). Premier envoi : GitHub ›
  Actions › Publication › Run workflow, case « Envoyer la version iOS à TestFlight » (`docs/publication.md` § 5).

### 6. Compte rendu
Quand c'est fini (ou bloqué), crée `store/etat-publication.md` (branche `claude/awesome-pasteur-onk06u`) avec
**uniquement des informations non secrètes** :
- secrets GitHub créés (les **noms**, jamais les valeurs) ;
- URL des pages confidentialité, suppression de compte, aide ;
- état Google Play (appli créée, sections remplies, testeurs, premier AAB envoyé ou non, contrainte 12 testeurs) ;
- état Apple (identifiant enregistré, app créée, nom retenu, Team ID, TestFlight) ;
- fichiers de marque déposés ;
- ce qui bloque, et ce que tu attends de moi ou de la session code.
Envoie le même résumé à la session code (message ou `store/echanges.md`), puis donne-moi un résumé simple en
10 lignes maximum.

## Ce que fait la session code (pour information, ne le fais pas)
Icône et couleurs d'ARC dans l'appli à partir de `assets/marque/`, nouvelles captures pour les fiches, vérification
de la construction signée dès que les secrets existent, corrections si une exécution GitHub Actions est en rouge,
réponses aux questions techniques (chiffrement, permissions, sécurité des données), mise à jour du serveur.
