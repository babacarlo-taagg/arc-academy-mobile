# Architecture hors ligne et synchronisation

```
 TÉLÉPHONE                                                        SERVEUR ARC (Odoo, arc_mobile_api)
┌───────────────────────────────────────────────────┐
│ Profil Awa (code secret)   Profil Moussa (code)   │
│ ┌─────────────────────┐  ┌─────────────────────┐  │
│ │ base chiffrée        │  │ base chiffrée        │  │   POST /sync/evenements (gzip, ≤ 100)
│ │ formations, leçons,  │  │ …                    │  │ ─────────────────────────────────────►
│ │ état SCORM (cmi),    │  │                      │  │ ◄───────────────────────────────────── résultat par
│ │ FILE D'ÉVÉNEMENTS    │  │                      │  │   accepte / deja_recu / refuse  + état
│ └─────────┬───────────┘  └─────────────────────┘  │
│           │ moteur de synchro (au démarrage, au retour du réseau, après chaque action,
│           │ toutes les 15 min en tâche de fond)                                  │
│ ┌─────────┴───────────────────────────────────┐   │   GET /formations/{id}/manifest (ETag)
│ │ CONTENUS communs à tous les profils          │◄──┼── GET /fichiers/{empreinte} (Range : reprise)
│ │ objets/ab/<sha256>  (jamais en double)       │   │
│ │ manifestes/<cours>.json, scorm/<sha256>/     │   │
│ └─────────┬───────────────────────────────────┘   │
│ serveur local http://127.0.0.1:<port>/<jeton>/…    │
│   → WebView : articles, modules SCORM (scorm-again) │
│   → POST …/commit : état SCORM écrit dans la base  │
└───────────────────────────────────────────────────┘
```

## Règles

1. **Une action = une transaction** : l'état local (leçon terminée, état SCORM, temps passé) et l'événement à envoyer
   sont écrits ensemble. Appli tuée ou batterie vide : soit tout est écrit, soit rien. Base en mode WAL,
   écriture complète sur le disque (`synchronous = FULL`).
2. **Identifiant unique** créé sur le téléphone pour chaque événement ; le serveur le garde pour toujours :
   un événement renvoyé après une coupure reçoit `deja_recu` et n'est compté qu'une fois.
3. **Suppression seulement après réponse** du serveur. Sans réponse (coupure), on garde tout et on réessaie
   avec une attente croissante (5 s, 10 s, 20 s… au plus 15 min). Paquets de 10, puis 20, 40, 80, 100.
4. **Refus** (`refuse`) : retiré de la file, gardé dans `evenements_refuses` pour comprendre.
5. **Conflits** (mêmes règles que le serveur) : terminé ne recule jamais ; « réussi » ne redevient pas « échoué » ;
   le meilleur score gagne ; l'état SCORM gardé pour la reprise est le plus avancé ; le temps ne recule pas.
6. **Téléchargement** : Wi-Fi seulement par défaut ; place vérifiée avant ; chaque fichier arrive dans
   `temporaires/<empreinte>.part`, reprend par `Range` après une coupure, est vérifié (taille + SHA-256) avant
   d'être rangé. Mise à jour : seules les empreintes absentes sont téléchargées ; les fichiers qui ne servent plus
   sont supprimés.
7. **Profils** : la clé de chaque base est tirée au hasard et rangée dans le coffre-fort du système (Keystore /
   trousseau). Le code secret (4 à 6 chiffres) protège l'accès dans l'appli : empreinte PBKDF2, attente croissante
   après 5 erreurs. Un code de 6 chiffres se devine hors ligne en quelques minutes : on ne s'en sert donc pas comme
   clé de chiffrement ; c'est le coffre-fort du système qui empêche de lire la base hors du téléphone, et la
   synchronisation de fond peut envoyer la file sans le code.
8. **Effacement à distance** : `401 profil_efface` → base, jetons, clé et code du profil effacés. Les contenus
   communs restent (aucune donnée personnelle).
9. **Session** : jeton d'accès d'une heure renouvelé automatiquement (rotation du jeton de rafraîchissement,
   90 jours). Hors ligne, l'appli marche sans jeton. Session refusée par le serveur : les données restent, un
   message demande de se reconnecter par e-mail pour envoyer la progression.
10. **Données consommées** : chaque octet échangé avec ARC est compté par mois (Réglages).
