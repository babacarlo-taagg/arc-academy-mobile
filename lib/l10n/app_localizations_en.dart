// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nomAppli => 'ARC Academy';

  @override
  String get sousTitreAppli => 'Continuing education for health workers';

  @override
  String get connexionTitre => 'Sign in';

  @override
  String get connexionEmailLibelle => 'Your email address';

  @override
  String get connexionEmailAide => 'The one you gave ARC';

  @override
  String get connexionEmailInvalide => 'This email address is not complete.';

  @override
  String get connexionRecevoirCode => 'Get my code';

  @override
  String get connexionPasEmail => 'No email? Need help?';

  @override
  String get codeTitre => 'Your code';

  @override
  String codeEnvoye(String email) {
    return 'If ARC knows this address, a 6-digit code has just been sent to it ($email).';
  }

  @override
  String get codeVerifierSpams => 'Nothing received? Also check your spam folder.';

  @override
  String get codeLibelle => '6-digit code';

  @override
  String get codeValider => 'Confirm';

  @override
  String get codeRenvoyer => 'Send the code again';

  @override
  String codeRenvoyerDans(int secondes) {
    return 'Send again in $secondes s';
  }

  @override
  String codeIncorrect(int essais) {
    return 'Wrong code. $essais attempt(s) left.';
  }

  @override
  String get codeExpire => 'This code is no longer valid. Ask for a new code.';

  @override
  String get erreurReseau => 'No network right now. Try again when the network is back.';

  @override
  String get erreurTropDeDemandes => 'Too many requests. Wait a few minutes.';

  @override
  String get erreurInconnue => 'Something went wrong. Try again.';

  @override
  String get aideTitre => 'Need help';

  @override
  String get aideSansEmail =>
      'Your email address is not registered yet? Ask your training manager to add it to your ARC account.';

  @override
  String aideContact(String email) {
    return 'Write to $email';
  }

  @override
  String get fermer => 'Close';

  @override
  String get annuler => 'Cancel';

  @override
  String get confirmer => 'Confirm';

  @override
  String get reessayer => 'Try again';

  @override
  String get profilsTitre => 'Who is learning?';

  @override
  String get profilsAjouter => 'Add a person';

  @override
  String get profilsAide => 'Several colleagues can use this phone. Each one has a secret code.';

  @override
  String get pinCreerTitre => 'Choose your secret code';

  @override
  String get pinCreerAide => '4 to 6 digits. It protects your courses on this phone.';

  @override
  String get pinConfirmerTitre => 'Type your secret code again';

  @override
  String get pinDifferent => 'The two codes are different. Start again.';

  @override
  String pinTitre(String nom) {
    return 'Hello $nom';
  }

  @override
  String get pinAide => 'Type your secret code';

  @override
  String get pinFaux => 'Wrong secret code.';

  @override
  String pinFauxEssais(int essais) {
    return 'Wrong secret code. $essais attempt(s) left before a wait.';
  }

  @override
  String pinAttente(String duree) {
    return 'Too many mistakes. Wait $duree before trying again.';
  }

  @override
  String get pinOublie => 'Forgot your secret code?';

  @override
  String get pinOublieAide =>
      'Sign in again with your email address to choose a new secret code. Your courses stay on the phone.';

  @override
  String get pinValider => 'OK';

  @override
  String get pinEffacer => 'Delete';

  @override
  String get autrePersonne => 'Switch person';

  @override
  String get formationsTitre => 'My courses';

  @override
  String get formationsVide =>
      'No courses yet. If you are enrolled in a cohort, it will appear here as soon as there is network.';

  @override
  String formationsLecons(int faites, int total) {
    return '$faites / $total lessons';
  }

  @override
  String progressionPourcent(int pourcent) {
    return '$pourcent %';
  }

  @override
  String get etatHorsLigne => 'Available offline';

  @override
  String get etatPartiel => 'Download to finish';

  @override
  String get etatMiseAJour => 'Update available';

  @override
  String get etatAucun => 'To download';

  @override
  String get synchroToutEnvoye => 'Everything is sent';

  @override
  String synchroEnAttente(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n items waiting', one: '1 item waiting');
    return '$_temp0';
  }

  @override
  String get synchroEnvoiEnCours => 'Sending…';

  @override
  String get synchroHorsLigne => 'No network';

  @override
  String get coursTelecharger => 'Download for offline use';

  @override
  String get coursMettreAJour => 'Update';

  @override
  String get coursReprendre => 'Resume download';

  @override
  String coursTaille(String taille) {
    return 'Size: $taille';
  }

  @override
  String coursPlaceLibre(String taille) {
    return 'Free space on the phone: $taille';
  }

  @override
  String get coursWifiSeulement => 'Connect to Wi-Fi to download (or allow mobile data in the settings).';

  @override
  String get coursPasDeReseau => 'No network: the download will resume later, where it stopped.';

  @override
  String coursPlaceInsuffisante(String besoin, String libre) {
    return 'Not enough space: $besoin needed, $libre left. Free up space (photos, videos) then try again.';
  }

  @override
  String coursTelechargement(String recu, String total) {
    return 'Downloading: $recu of $total';
  }

  @override
  String get coursTelechargementFini => 'Ready: this course works without network.';

  @override
  String get coursSupprimer => 'Remove from the phone';

  @override
  String get coursSupprimerConfirmer => 'Remove the files of this course? Your progress is kept.';

  @override
  String get coursRienATelecharger => 'Nothing to download for this course.';

  @override
  String get coursLeconsIndisponibles => 'The lessons will appear when there is network.';

  @override
  String get coursErreurFichier => 'A file arrived damaged. Try the download again.';

  @override
  String get leconTerminee => 'Done';

  @override
  String get leconHorsLigne => 'Offline';

  @override
  String get leconEnLigne => 'Online only';

  @override
  String leconMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get typeArticle => 'Article';

  @override
  String get typePdf => 'Document';

  @override
  String get typeVideo => 'Video';

  @override
  String get typeScorm => 'Interactive module';

  @override
  String get typeQuiz => 'Quiz';

  @override
  String get typeCertification => 'Assessment';

  @override
  String get typeAutre => 'Content';

  @override
  String get lecteurTerminer => 'I have finished this lesson';

  @override
  String get lecteurDejaTerminee => 'Lesson done';

  @override
  String get lecteurLireVoixHaute => 'Read aloud';

  @override
  String get lecteurArreterLecture => 'Stop reading';

  @override
  String get lecteurTailleTexte => 'Text size';

  @override
  String get lecteurNonTelechargee => 'This lesson is not on the phone.';

  @override
  String get lecteurOuvrirEnLigne => 'Open online';

  @override
  String get lecteurTelechargerAvant => 'Download the course to follow it without network.';

  @override
  String get lecteurModuleEnregistre => 'Your progress is saved on the phone.';

  @override
  String get reglagesTitre => 'Settings';

  @override
  String get reglagesDonnees => 'Data used this month';

  @override
  String get reglagesDonneesAide => 'Exchanges with ARC (downloads and uploads).';

  @override
  String get reglagesWifi => 'Download on Wi-Fi only';

  @override
  String get reglagesWifiAide => 'Recommended: mobile data is expensive.';

  @override
  String get reglagesTailleTexte => 'Lesson text size';

  @override
  String get reglagesEnAttente => 'Items waiting to be sent';

  @override
  String get reglagesEnvoyer => 'Send now';

  @override
  String get reglagesContenus => 'Space used by courses';

  @override
  String get reglagesDeconnexion => 'Remove my profile from this phone';

  @override
  String get reglagesDeconnexionConfirmer =>
      'Your profile and unsent progress will be deleted from this phone. Downloaded courses stay for the others.';

  @override
  String reglagesDeconnexionEnAttente(int n) {
    return 'Warning: $n item(s) are not sent yet and will be lost.';
  }

  @override
  String reglagesVersion(String version) {
    return 'Version $version';
  }

  @override
  String get sessionAReprendre =>
      'Sign in again with your email to send your progress. You can keep learning in the meantime.';

  @override
  String get profilEfface => 'This profile was removed from this phone at ARC\'s request.';

  @override
  String get reglagesSupprimer => 'Delete my account';

  @override
  String get suppressionTitre => 'Delete my account';

  @override
  String get suppressionExplication => 'You are asking ARC to delete your account and your data. What will be deleted:';

  @override
  String get suppressionPoint1 => 'your ARC account (you will no longer be able to sign in);';

  @override
  String get suppressionPoint2 => 'your progress and results in the courses;';

  @override
  String get suppressionPoint3 => 'this profile, on this phone and on your other phones.';

  @override
  String get suppressionAttestations => 'ARC may keep certificates already issued, as its privacy policy provides.';

  @override
  String get suppressionMotif => 'Why? (optional)';

  @override
  String get suppressionConfirmer => 'To confirm, type DELETE';

  @override
  String get suppressionMotCle => 'DELETE';

  @override
  String get suppressionBouton => 'Delete my account';

  @override
  String get suppressionHorsLigne =>
      'You need network to send your request to ARC. Try again when you have a connection, or make the request on the website:';

  @override
  String get suppressionLienWeb => 'https://academy.africaresourcecentre.org/suppression-compte';

  @override
  String get suppressionSession => 'Your session has expired. Sign in again with your email, then try again.';

  @override
  String get suppressionErreur => 'The request could not be sent. Try again later.';

  @override
  String get suppressionFaite => 'Request sent';

  @override
  String get suppressionOk => 'I understand';

  @override
  String get profilTitre => 'Your profile';

  @override
  String get profilIntro => 'Two questions so that your courses match your country and your job.';

  @override
  String get profilPays => 'Country where you work';

  @override
  String get profilPaysChoisir => 'Choose your country';

  @override
  String get profilPaysRecherche => 'Search for a country';

  @override
  String get profilMetier => 'Your job';

  @override
  String get profilLangue => 'App language';

  @override
  String get profilContinuer => 'Continue';

  @override
  String get profilManque => 'Choose your country and your job to continue.';

  @override
  String get profilChargement => 'Preparing your profile…';

  @override
  String get profilReseauNecessaire =>
      'You need network once to prepare your profile. After that, the app works without network.';

  @override
  String get profilAucunResultat => 'No results.';

  @override
  String get profilNonRenseigne => 'Not filled in';

  @override
  String get profilEnregistre => 'Saved.';

  @override
  String get profilEnregistreHorsLigne => 'Saved on the phone. Sent to ARC as soon as the network is back.';

  @override
  String profilCompletude(int pourcent) {
    return 'Profile $pourcent % complete';
  }

  @override
  String get profilCompleter => 'Complete my profile';

  @override
  String get enregistrer => 'Save';

  @override
  String get institutionTitre => 'Your institution';

  @override
  String get institutionIntro => 'Where do you work? ARC can better follow and support your team.';

  @override
  String get institutionRepondre => 'Answer';

  @override
  String get institutionPlusTard => 'Later';

  @override
  String get institutionNom => 'Name of your institution';

  @override
  String get institutionRechercheAide => 'Type at least 3 letters to search.';

  @override
  String get institutionHorsLigne => 'No network: type the name, it will be sent later.';

  @override
  String institutionUtiliserNom(String nom) {
    return 'Not in the list: keep “$nom”';
  }

  @override
  String get institutionType => 'Type of institution';

  @override
  String get institutionNiveau => 'Level';

  @override
  String get sexeTitre => 'You are…';

  @override
  String get sexeAide => 'Optional. Only used for anonymous statistics.';

  @override
  String get sexePasser => 'Skip';

  @override
  String get monProfilTitre => 'My profile';

  @override
  String get monProfilSexe => 'Sex';

  @override
  String get whatsappTitre => 'WhatsApp';

  @override
  String get whatsappNumero => 'WhatsApp number';

  @override
  String get whatsappAide => 'With the country code, for example +221771234567';

  @override
  String get whatsappInvalide => 'Incomplete number: start with + and the country code.';

  @override
  String get whatsappAccordActif => 'You agreed that ARC may write to you on WhatsApp.';

  @override
  String get whatsappRetirer => 'Withdraw my consent';

  @override
  String get whatsappAccordRetire => 'Consent withdrawn: ARC will no longer write to you on WhatsApp.';
}
