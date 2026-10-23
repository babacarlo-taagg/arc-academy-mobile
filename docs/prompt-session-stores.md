# Prompt — session Claude Cowork « publication sur les stores »

À coller tel quel dans une session Claude Cowork ouverte sur l'ordinateur de Babacar (navigateur connecté à
Google Play Console, App Store Connect, GitHub et Odoo ARC). La session « code » (Claude Code, dépôts
`arc-academy-mobile` et `arc-academy-odoo`) fait en parallèle la partie programmation.

---

Tu vas préparer la publication de **ARC Academy Mobile** sur Google Play et l'App Store, pour un **pilote fermé**
(test interne Google Play + TestFlight), pas encore une publication publique. Je suis Babacar, je travaille en
français : explique simplement, sans jargon, une étape à la fois.

## Le projet en bref
- Appli Flutter de formation continue d'ARC Academy pour les acteurs de santé en zone rurale (Afrique de l'Ouest) :
  cours téléchargés et suivis **sans réseau**, progression envoyée au retour du réseau. Connexion par **code reçu
  par e-mail**. Aucune donnée de patient. Gratuit, sans publicité, sans achat.
- Dépôt de l'appli : `github.com/babacarlo-taagg/arc-academy-mobile`, branche de travail `claude/awesome-pasteur-onk06u`
  (lis `README.md`, `CLAUDE.md`, `docs/architecture-hors-ligne.md` ; captures dans `docs/captures/`).
- Serveur : Odoo 20 sur **https://academy.africaresourcecentre.org** (module `arc_mobile_api`).
- Identifiant d'appli (Android et iOS) : **`org.africaresourcecentre.academy`**. Nom : **ARC Academy**.
  Version : 0.1.0. Assistant IA à venir : AYSHA (pas dans cette version). Langue : français (wolof plus tard).
- ARC porte la déclaration à la CDP (Commission de protection des données personnelles du Sénégal).
- J'ai : le compte Google Play Console d'ARC, le compte Apple Developer d'ARC, le logo et les couleurs d'ARC.

## Règles absolues
1. **Aucun secret dans une conversation, un fichier du dépôt ou un document partagé** : mots de passe, clé de
   signature, fichier JSON de compte de service, clé `.p8` d'Apple. Ils vont seulement dans mon gestionnaire de mots
   de passe et dans les **secrets GitHub** (dépôt `arc-academy-mobile` › Settings › Secrets and variables › Actions).
   Je tape moi-même les mots de passe quand c'est demandé.
2. **Demande-moi avant** tout paiement, toute acceptation de contrat ou de conditions, tout envoi en vérification
   (« Submit for review »), toute invitation de testeurs.
3. Pas de publication publique (piste « Production » de Google, version publique de l'App Store) : seulement
   **test interne** Google Play et **TestFlight**.
4. Ne modifie pas le code de l'appli : c'est la session code. Tu peux seulement déposer des fichiers dans
   `assets/marque/` et `store/` du dépôt (voir plus bas).

## Ce que tu fais, dans l'ordre

### 1. Marque (pour l'icône et les couleurs de l'appli)
- Dépose dans le dépôt, branche `claude/awesome-pasteur-onk06u`, dossier `assets/marque/` (GitHub › Add file ›
  Upload files) : le logo en **PNG carré 1024×1024 sur fond plein** (pour l'icône), une version **sans fond**
  (PNG transparent), et le logo horizontal s'il existe.
- Crée `assets/marque/couleurs.md` : couleurs d'ARC en code hexadécimal (#RRGGBB) avec leur usage (principale,
  secondaire, accent), police si la charte en impose une.

### 2. Clé de signature Android (une seule fois, à ne jamais perdre)
- Sur mon ordinateur, crée la **clé d'envoi** (« upload key ») avec `keytool` (installe un JDK 17 si besoin) :
  fichier `arc-academy-upload.jks`, alias `arc-academy`, validité 10 000 jours, RSA 2048. Je tape le mot de passe.
- Range le fichier `.jks` et son mot de passe dans mon gestionnaire de mots de passe, plus une copie hors ligne
  (clé USB). **Jamais dans le dépôt.**
- Crée ces secrets GitHub (dépôt `arc-academy-mobile`) :
  - `ANDROID_KEYSTORE_BASE64` : le fichier `.jks` encodé en base64 (sous Windows :
    `[Convert]::ToBase64String([IO.File]::ReadAllBytes("arc-academy-upload.jks"))`, copié directement dans GitHub)
  - `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` (= `arc-academy`), `ANDROID_KEY_PASSWORD`
- Dans Play Console, garde **la signature d'application par Google Play** activée (Google garde la clé finale ;
  si la clé d'envoi est perdue, on peut la faire remplacer).

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
  les exercer ; référence de la déclaration CDP d'ARC (laisser un emplacement si le numéro n'est pas encore connu) ;
  date de mise à jour. Ajoute une phrase : l'assistant IA AYSHA, quand il arrivera, ne sera utilisé qu'avec un
  consentement explicite.
- **Suppression de compte** : `https://academy.africaresourcecentre.org/suppression-compte`. Explique comment
  demander la suppression de son compte et de ses données (e-mail au support d'ARC avec l'adresse du compte), ce
  qui est supprimé, ce qui peut être gardé et combien de temps (par exemple attestations délivrées). Google et
  Apple exigent cette page.
- Une page **Aide / support** si elle n'existe pas (adresse e-mail de contact).

### 4. Google Play Console
- Crée l'appli : nom « ARC Academy », langue par défaut **français (fr-FR)**, application (pas jeu), **gratuite**.
- Remplis « Contenu de l'application » :
  - Politique de confidentialité : URL ci-dessus.
  - Accès à l'appli : « Toutes les fonctionnalités ne sont pas accessibles sans identifiants » → **laisse en
    attente** : la session code va créer un compte de démonstration réservé aux vérificateurs (adresse + code fixe)
    et te les donnera.
  - Publicités : aucune. Classification du contenu : questionnaire (appli éducative, aucun contenu sensible).
  - Public cible : **18 ans et plus** (professionnels de santé).
  - Sécurité des données : données collectées = nom, adresse e-mail, activité dans l'appli (progression), identifiant
    de l'appareil ; toutes **chiffrées en transit** ; aucune vendue ni partagée à des tiers à des fins
    publicitaires ; suppression possible (URL de suppression de compte).
  - Déclarations « applis de santé » si demandé : appli de **formation** pour professionnels, pas un dispositif
    médical, aucune donnée de santé de patients.
- Fiche du store (brouillon, en français) : description courte (80 caractères max) et longue (claire, sans
  promesse médicale), catégorie **Éducation**, e-mail de contact, site `https://academy.africaresourcecentre.org`,
  icône 512×512 (à partir du logo), image de présentation 1024×500, au moins 4 captures téléphone (prends
  `docs/captures/` du dépôt en attendant de vraies captures avec les couleurs ARC). Dépose aussi les textes dans
  le dépôt : `store/android/fr-FR/` (titre, description courte, description longue).
- **Compte de service pour l'envoi automatique** : dans Google Cloud (projet lié à Play Console), crée un compte de
  service, une clé JSON, et donne-lui dans Play Console › Utilisateurs et autorisations le droit de publier sur les
  pistes de test de cette appli. Mets le contenu du JSON dans le secret GitHub **`PLAY_SERVICE_ACCOUNT_JSON`**, puis
  supprime le fichier JSON de mon ordinateur.
- Piste **Test interne** : crée la liste de testeurs « Pilote ARC » (je te donnerai les adresses ; elles doivent être
  des comptes Google, Gmail par exemple). Le **premier** fichier `.aab` doit être envoyé à la main : quand la session
  code t'aura dit qu'il est prêt, télécharge-le depuis GitHub › Actions (artefact de la dernière exécution réussie)
  et envoie-le dans la piste de test interne. Les suivants partiront automatiquement.
- Si Play Console impose 12 testeurs pendant 14 jours (compte personnel récent), dis-le-moi tout de suite.

### 5. Apple (App Store Connect et Developer)
- Developer › Identifiers : enregistre l'identifiant **`org.africaresourcecentre.academy`** (capacités : aucune de
  plus pour l'instant ; « Background Modes » est géré dans le projet).
- App Store Connect : nouvelle app, plateforme iOS, nom « ARC Academy » (si le nom est pris, propose-moi des
  variantes, par exemple « ARC Academy Santé »), langue principale **français**, SKU `arc-academy-mobile`.
- Remplis : confidentialité de l'app (mêmes données que pour Google, aucune utilisée pour le suivi publicitaire),
  URL de confidentialité, URL d'assistance, catégorie **Éducation**, classification par âge (questionnaire), prix
  gratuit. Informations pour la vérification : **laisse le compte de démonstration en attente** (la session code le
  fournira). Textes dans le dépôt : `store/ios/fr-FR/`.
- **Clé d'API App Store Connect** (Utilisateurs et accès › Intégrations › Clés, rôle « App Manager ») pour l'envoi
  automatique vers TestFlight. Crée les secrets GitHub : `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`,
  `APP_STORE_CONNECT_KEY_P8_BASE64` (le fichier `.p8` encodé en base64 ; supprime-le ensuite de mon ordinateur) et
  `APPLE_TEAM_ID` (identifiant d'équipe à 10 caractères).
- TestFlight : groupe de testeurs internes « Pilote ARC » (je te donnerai les adresses).

### 6. Compte rendu pour la session code
Quand c'est fini (ou bloqué), crée dans le dépôt `store/etat-publication.md` (branche `claude/awesome-pasteur-onk06u`)
avec **uniquement des informations non secrètes** :
- secrets GitHub créés (les **noms**, jamais les valeurs) ;
- URL des pages confidentialité, suppression de compte, aide ;
- état Google Play (appli créée, sections remplies, ce qui attend le compte de démonstration, testeurs, contrainte
  12 testeurs ou non) ;
- état Apple (identifiant enregistré, app créée, nom retenu, Team ID, ce qui attend) ;
- couleurs et fichiers de marque déposés ;
- tout ce qui bloque, et ce que tu attends de moi ou de la session code.
Puis donne-moi un résumé simple en 10 lignes maximum.

## Ce que fait la session code (pour information, ne le fais pas)
Icône et couleurs d'ARC dans l'appli à partir de `assets/marque/`, version de production pointée sur
`https://academy.africaresourcecentre.org/api/v1`, signature et construction de l'`.aab` et de l'archive iOS dans
GitHub Actions avec les secrets ci-dessus, envoi automatique vers le test interne et TestFlight, demande de
suppression de compte dans l'appli, compte de démonstration pour les vérificateurs, installation du module
`arc_mobile_api` sur le serveur.
