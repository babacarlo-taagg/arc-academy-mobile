// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get nomAppli => 'ARC Academy';

  @override
  String get sousTitreAppli => 'Formation continue des acteurs de santé';

  @override
  String get connexionTitre => 'Connexion';

  @override
  String get connexionEmailLibelle => 'Ton adresse e-mail';

  @override
  String get connexionEmailAide => 'Celle que tu as donnée à ARC';

  @override
  String get connexionEmailInvalide => 'Cette adresse e-mail n\'est pas complète.';

  @override
  String get connexionRecevoirCode => 'Recevoir mon code';

  @override
  String get connexionPasEmail => 'Pas d\'e-mail ? Besoin d\'aide ?';

  @override
  String get codeTitre => 'Ton code';

  @override
  String codeEnvoye(String email) {
    return 'Si cette adresse est connue d\'ARC, un code de 6 chiffres vient d\'y être envoyé ($email).';
  }

  @override
  String get codeVerifierSpams => 'Rien reçu ? Regarde aussi dans les « indésirables ».';

  @override
  String get codeLibelle => 'Code à 6 chiffres';

  @override
  String get codeValider => 'Valider';

  @override
  String get codeRenvoyer => 'Renvoyer le code';

  @override
  String codeRenvoyerDans(int secondes) {
    return 'Renvoyer dans $secondes s';
  }

  @override
  String codeIncorrect(int essais) {
    return 'Code incorrect. Encore $essais essai(s).';
  }

  @override
  String get codeExpire => 'Ce code n\'est plus valable. Demande un nouveau code.';

  @override
  String get erreurReseau => 'Pas de réseau pour le moment. Réessaie quand le réseau revient.';

  @override
  String get erreurTropDeDemandes => 'Trop de demandes. Attends quelques minutes.';

  @override
  String get erreurInconnue => 'Un problème est survenu. Réessaie.';

  @override
  String get aideTitre => 'Besoin d\'aide';

  @override
  String get aideSansEmail =>
      'Ton adresse e-mail n\'est pas encore enregistrée ? Demande à ton responsable de formation de l\'ajouter à ton compte ARC.';

  @override
  String aideContact(String email) {
    return 'Écrire à $email';
  }

  @override
  String get fermer => 'Fermer';

  @override
  String get annuler => 'Annuler';

  @override
  String get confirmer => 'Confirmer';

  @override
  String get reessayer => 'Réessayer';

  @override
  String get profilsTitre => 'Qui apprend ?';

  @override
  String get profilsAjouter => 'Ajouter une personne';

  @override
  String get profilsAide => 'Ce téléphone peut servir à plusieurs collègues. Chacun a son code secret.';

  @override
  String get pinCreerTitre => 'Choisis ton code secret';

  @override
  String get pinCreerAide => '4 à 6 chiffres. Il protège tes formations sur ce téléphone.';

  @override
  String get pinConfirmerTitre => 'Tape encore ton code secret';

  @override
  String get pinDifferent => 'Les deux codes sont différents. Recommence.';

  @override
  String pinTitre(String nom) {
    return 'Bonjour $nom';
  }

  @override
  String get pinAide => 'Tape ton code secret';

  @override
  String get pinFaux => 'Code secret incorrect.';

  @override
  String pinFauxEssais(int essais) {
    return 'Code secret incorrect. Encore $essais essai(s) avant une attente.';
  }

  @override
  String pinAttente(String duree) {
    return 'Trop d\'erreurs. Attends $duree avant de réessayer.';
  }

  @override
  String get pinOublie => 'Code secret oublié ?';

  @override
  String get pinOublieAide =>
      'Reconnecte-toi avec ton adresse e-mail pour choisir un nouveau code secret. Tes formations restent sur le téléphone.';

  @override
  String get pinValider => 'OK';

  @override
  String get pinEffacer => 'Effacer';

  @override
  String get autrePersonne => 'Changer de personne';

  @override
  String get formationsTitre => 'Mes formations';

  @override
  String get formationsVide =>
      'Aucune formation pour le moment. Si tu es inscrit à une cohorte, elle apparaîtra ici dès que le réseau passe.';

  @override
  String formationsLecons(int faites, int total) {
    return '$faites / $total leçons';
  }

  @override
  String progressionPourcent(int pourcent) {
    return '$pourcent %';
  }

  @override
  String get etatHorsLigne => 'Disponible sans réseau';

  @override
  String get etatPartiel => 'Téléchargement à terminer';

  @override
  String get etatMiseAJour => 'Mise à jour disponible';

  @override
  String get etatAucun => 'À télécharger';

  @override
  String get synchroToutEnvoye => 'Tout est envoyé';

  @override
  String synchroEnAttente(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n éléments en attente',
      one: '1 élément en attente',
    );
    return '$_temp0';
  }

  @override
  String get synchroEnvoiEnCours => 'Envoi en cours…';

  @override
  String get synchroHorsLigne => 'Sans réseau';

  @override
  String get coursTelecharger => 'Télécharger pour hors ligne';

  @override
  String get coursMettreAJour => 'Mettre à jour';

  @override
  String get coursReprendre => 'Reprendre le téléchargement';

  @override
  String coursTaille(String taille) {
    return 'Taille : $taille';
  }

  @override
  String coursPlaceLibre(String taille) {
    return 'Place libre sur le téléphone : $taille';
  }

  @override
  String get coursWifiSeulement =>
      'Connecte-toi au Wi-Fi pour télécharger (ou autorise les données mobiles dans les réglages).';

  @override
  String get coursPasDeReseau => 'Pas de réseau : le téléchargement reprendra plus tard, là où il s\'est arrêté.';

  @override
  String coursPlaceInsuffisante(String besoin, String libre) {
    return 'Pas assez de place : il faut $besoin, il reste $libre. Libère de la place (photos, vidéos) puis réessaie.';
  }

  @override
  String coursTelechargement(String recu, String total) {
    return 'Téléchargement : $recu sur $total';
  }

  @override
  String get coursTelechargementFini => 'Prêt : cette formation marche sans réseau.';

  @override
  String get coursSupprimer => 'Retirer du téléphone';

  @override
  String get coursSupprimerConfirmer => 'Retirer les fichiers de cette formation ? Ta progression est gardée.';

  @override
  String get coursRienATelecharger => 'Rien à télécharger pour cette formation.';

  @override
  String get coursLeconsIndisponibles => 'Les leçons apparaîtront quand le réseau passe.';

  @override
  String get coursErreurFichier => 'Un fichier est arrivé abîmé. Réessaie le téléchargement.';

  @override
  String get leconTerminee => 'Terminée';

  @override
  String get leconHorsLigne => 'Sans réseau';

  @override
  String get leconEnLigne => 'En ligne seulement';

  @override
  String leconMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get typeArticle => 'Article';

  @override
  String get typePdf => 'Document';

  @override
  String get typeVideo => 'Vidéo';

  @override
  String get typeScorm => 'Module interactif';

  @override
  String get typeQuiz => 'Quiz';

  @override
  String get typeCertification => 'Évaluation';

  @override
  String get typeAutre => 'Contenu';

  @override
  String get lecteurTerminer => 'J\'ai terminé cette leçon';

  @override
  String get lecteurDejaTerminee => 'Leçon terminée';

  @override
  String get lecteurLireVoixHaute => 'Lire à voix haute';

  @override
  String get lecteurArreterLecture => 'Arrêter la lecture';

  @override
  String get lecteurTailleTexte => 'Taille du texte';

  @override
  String get lecteurNonTelechargee => 'Cette leçon n\'est pas sur le téléphone.';

  @override
  String get lecteurOuvrirEnLigne => 'Ouvrir en ligne';

  @override
  String get lecteurTelechargerAvant => 'Télécharge la formation pour la suivre sans réseau.';

  @override
  String get lecteurModuleEnregistre => 'Ta progression est enregistrée sur le téléphone.';

  @override
  String get reglagesTitre => 'Réglages';

  @override
  String get reglagesDonnees => 'Données consommées ce mois-ci';

  @override
  String get reglagesDonneesAide => 'Échanges avec ARC (téléchargements et envois).';

  @override
  String get reglagesWifi => 'Télécharger seulement en Wi-Fi';

  @override
  String get reglagesWifiAide => 'Recommandé : les données mobiles coûtent cher.';

  @override
  String get reglagesTailleTexte => 'Taille du texte des leçons';

  @override
  String get reglagesEnAttente => 'Éléments en attente d\'envoi';

  @override
  String get reglagesEnvoyer => 'Envoyer maintenant';

  @override
  String get reglagesContenus => 'Place utilisée par les formations';

  @override
  String get reglagesDeconnexion => 'Retirer mon profil de ce téléphone';

  @override
  String get reglagesDeconnexionConfirmer =>
      'Ton profil et ta progression non envoyée seront effacés de ce téléphone. Les formations téléchargées restent pour les autres.';

  @override
  String reglagesDeconnexionEnAttente(int n) {
    return 'Attention : $n élément(s) ne sont pas encore envoyés et seront perdus.';
  }

  @override
  String reglagesVersion(String version) {
    return 'Version $version';
  }

  @override
  String get sessionAReprendre =>
      'Reconnecte-toi avec ton e-mail pour envoyer ta progression. Tu peux continuer à apprendre en attendant.';

  @override
  String get profilEfface => 'Ce profil a été retiré de ce téléphone à la demande d\'ARC.';

  @override
  String get reglagesSupprimer => 'Supprimer mon compte';

  @override
  String get suppressionTitre => 'Supprimer mon compte';

  @override
  String get suppressionExplication =>
      'Tu demandes à ARC de supprimer ton compte et tes données. Ce qui sera supprimé :';

  @override
  String get suppressionPoint1 => 'ton compte ARC (tu ne pourras plus te connecter) ;';

  @override
  String get suppressionPoint2 => 'ta progression et tes résultats dans les formations ;';

  @override
  String get suppressionPoint3 => 'ce profil, sur ce téléphone et sur tes autres téléphones.';

  @override
  String get suppressionAttestations =>
      'ARC peut garder les attestations déjà délivrées, comme le prévoit sa politique de confidentialité.';

  @override
  String get suppressionMotif => 'Pourquoi ? (facultatif)';

  @override
  String get suppressionConfirmer => 'Pour confirmer, tape SUPPRIMER';

  @override
  String get suppressionMotCle => 'SUPPRIMER';

  @override
  String get suppressionBouton => 'Supprimer mon compte';

  @override
  String get suppressionHorsLigne =>
      'Il faut du réseau pour envoyer ta demande à ARC. Réessaie quand tu as une connexion, ou fais la demande sur le site :';

  @override
  String get suppressionLienWeb => 'https://academy.africaresourcecentre.org/suppression-compte';

  @override
  String get suppressionSession => 'Ta session a expiré. Reconnecte-toi avec ton e-mail, puis réessaie.';

  @override
  String get suppressionErreur => 'La demande n\'a pas pu être envoyée. Réessaie plus tard.';

  @override
  String get suppressionFaite => 'Demande envoyée';

  @override
  String get suppressionOk => 'J\'ai compris';
}
