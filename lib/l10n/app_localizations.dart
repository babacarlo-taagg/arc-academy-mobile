import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @nomAppli.
  ///
  /// In fr, this message translates to:
  /// **'ARC Academy'**
  String get nomAppli;

  /// No description provided for @sousTitreAppli.
  ///
  /// In fr, this message translates to:
  /// **'Formation continue des acteurs de santé'**
  String get sousTitreAppli;

  /// No description provided for @connexionTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get connexionTitre;

  /// No description provided for @connexionEmailLibelle.
  ///
  /// In fr, this message translates to:
  /// **'Ton adresse e-mail'**
  String get connexionEmailLibelle;

  /// No description provided for @connexionEmailAide.
  ///
  /// In fr, this message translates to:
  /// **'Celle que tu as donnée à ARC'**
  String get connexionEmailAide;

  /// No description provided for @connexionEmailInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail n\'est pas complète.'**
  String get connexionEmailInvalide;

  /// No description provided for @connexionRecevoirCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir mon code'**
  String get connexionRecevoirCode;

  /// No description provided for @connexionPasEmail.
  ///
  /// In fr, this message translates to:
  /// **'Pas d\'e-mail ? Besoin d\'aide ?'**
  String get connexionPasEmail;

  /// No description provided for @codeTitre.
  ///
  /// In fr, this message translates to:
  /// **'Ton code'**
  String get codeTitre;

  /// No description provided for @codeEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Si cette adresse est connue d\'ARC, un code de 6 chiffres vient d\'y être envoyé ({email}).'**
  String codeEnvoye(String email);

  /// No description provided for @codeVerifierSpams.
  ///
  /// In fr, this message translates to:
  /// **'Rien reçu ? Regarde aussi dans les « indésirables ».'**
  String get codeVerifierSpams;

  /// No description provided for @codeLibelle.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get codeLibelle;

  /// No description provided for @codeValider.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get codeValider;

  /// No description provided for @codeRenvoyer.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get codeRenvoyer;

  /// No description provided for @codeRenvoyerDans.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {secondes} s'**
  String codeRenvoyerDans(int secondes);

  /// No description provided for @codeIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect. Encore {essais} essai(s).'**
  String codeIncorrect(int essais);

  /// No description provided for @codeExpire.
  ///
  /// In fr, this message translates to:
  /// **'Ce code n\'est plus valable. Demande un nouveau code.'**
  String get codeExpire;

  /// No description provided for @erreurReseau.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réseau pour le moment. Réessaie quand le réseau revient.'**
  String get erreurReseau;

  /// No description provided for @erreurTropDeDemandes.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Attends quelques minutes.'**
  String get erreurTropDeDemandes;

  /// No description provided for @erreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Un problème est survenu. Réessaie.'**
  String get erreurInconnue;

  /// No description provided for @aideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Besoin d\'aide'**
  String get aideTitre;

  /// No description provided for @aideSansEmail.
  ///
  /// In fr, this message translates to:
  /// **'Ton adresse e-mail n\'est pas encore enregistrée ? Demande à ton responsable de formation de l\'ajouter à ton compte ARC.'**
  String get aideSansEmail;

  /// No description provided for @aideContact.
  ///
  /// In fr, this message translates to:
  /// **'Écrire à {email}'**
  String aideContact(String email);

  /// No description provided for @fermer.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get fermer;

  /// No description provided for @annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// No description provided for @confirmer.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmer;

  /// No description provided for @reessayer.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get reessayer;

  /// No description provided for @profilsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Qui apprend ?'**
  String get profilsTitre;

  /// No description provided for @profilsAjouter.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une personne'**
  String get profilsAjouter;

  /// No description provided for @profilsAide.
  ///
  /// In fr, this message translates to:
  /// **'Ce téléphone peut servir à plusieurs collègues. Chacun a son code secret.'**
  String get profilsAide;

  /// No description provided for @pinCreerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton code secret'**
  String get pinCreerTitre;

  /// No description provided for @pinCreerAide.
  ///
  /// In fr, this message translates to:
  /// **'4 à 6 chiffres. Il protège tes formations sur ce téléphone.'**
  String get pinCreerAide;

  /// No description provided for @pinConfirmerTitre.
  ///
  /// In fr, this message translates to:
  /// **'Tape encore ton code secret'**
  String get pinConfirmerTitre;

  /// No description provided for @pinDifferent.
  ///
  /// In fr, this message translates to:
  /// **'Les deux codes sont différents. Recommence.'**
  String get pinDifferent;

  /// No description provided for @pinTitre.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {nom}'**
  String pinTitre(String nom);

  /// No description provided for @pinAide.
  ///
  /// In fr, this message translates to:
  /// **'Tape ton code secret'**
  String get pinAide;

  /// No description provided for @pinFaux.
  ///
  /// In fr, this message translates to:
  /// **'Code secret incorrect.'**
  String get pinFaux;

  /// No description provided for @pinFauxEssais.
  ///
  /// In fr, this message translates to:
  /// **'Code secret incorrect. Encore {essais} essai(s) avant une attente.'**
  String pinFauxEssais(int essais);

  /// No description provided for @pinAttente.
  ///
  /// In fr, this message translates to:
  /// **'Trop d\'erreurs. Attends {duree} avant de réessayer.'**
  String pinAttente(String duree);

  /// No description provided for @pinOublie.
  ///
  /// In fr, this message translates to:
  /// **'Code secret oublié ?'**
  String get pinOublie;

  /// No description provided for @pinOublieAide.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecte-toi avec ton adresse e-mail pour choisir un nouveau code secret. Tes formations restent sur le téléphone.'**
  String get pinOublieAide;

  /// No description provided for @pinValider.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get pinValider;

  /// No description provided for @pinEffacer.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get pinEffacer;

  /// No description provided for @autrePersonne.
  ///
  /// In fr, this message translates to:
  /// **'Changer de personne'**
  String get autrePersonne;

  /// No description provided for @formationsTitre.
  ///
  /// In fr, this message translates to:
  /// **'Mes formations'**
  String get formationsTitre;

  /// No description provided for @formationsVide.
  ///
  /// In fr, this message translates to:
  /// **'Aucune formation pour le moment. Si tu es inscrit à une cohorte, elle apparaîtra ici dès que le réseau passe.'**
  String get formationsVide;

  /// No description provided for @formationsLecons.
  ///
  /// In fr, this message translates to:
  /// **'{faites} / {total} leçons'**
  String formationsLecons(int faites, int total);

  /// No description provided for @progressionPourcent.
  ///
  /// In fr, this message translates to:
  /// **'{pourcent} %'**
  String progressionPourcent(int pourcent);

  /// No description provided for @etatHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Disponible sans réseau'**
  String get etatHorsLigne;

  /// No description provided for @etatPartiel.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement à terminer'**
  String get etatPartiel;

  /// No description provided for @etatMiseAJour.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour disponible'**
  String get etatMiseAJour;

  /// No description provided for @etatAucun.
  ///
  /// In fr, this message translates to:
  /// **'À télécharger'**
  String get etatAucun;

  /// No description provided for @synchroToutEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Tout est envoyé'**
  String get synchroToutEnvoye;

  /// No description provided for @synchroEnAttente.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =1{1 élément en attente} other{{n} éléments en attente}}'**
  String synchroEnAttente(int n);

  /// No description provided for @synchroEnvoiEnCours.
  ///
  /// In fr, this message translates to:
  /// **'Envoi en cours…'**
  String get synchroEnvoiEnCours;

  /// No description provided for @synchroHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Sans réseau'**
  String get synchroHorsLigne;

  /// No description provided for @coursTelecharger.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger pour hors ligne'**
  String get coursTelecharger;

  /// No description provided for @coursMettreAJour.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get coursMettreAJour;

  /// No description provided for @coursReprendre.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre le téléchargement'**
  String get coursReprendre;

  /// No description provided for @coursTaille.
  ///
  /// In fr, this message translates to:
  /// **'Taille : {taille}'**
  String coursTaille(String taille);

  /// No description provided for @coursPlaceLibre.
  ///
  /// In fr, this message translates to:
  /// **'Place libre sur le téléphone : {taille}'**
  String coursPlaceLibre(String taille);

  /// No description provided for @coursWifiSeulement.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi au Wi-Fi pour télécharger (ou autorise les données mobiles dans les réglages).'**
  String get coursWifiSeulement;

  /// No description provided for @coursPasDeReseau.
  ///
  /// In fr, this message translates to:
  /// **'Pas de réseau : le téléchargement reprendra plus tard, là où il s\'est arrêté.'**
  String get coursPasDeReseau;

  /// No description provided for @coursPlaceInsuffisante.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de place : il faut {besoin}, il reste {libre}. Libère de la place (photos, vidéos) puis réessaie.'**
  String coursPlaceInsuffisante(String besoin, String libre);

  /// No description provided for @coursTelechargement.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement : {recu} sur {total}'**
  String coursTelechargement(String recu, String total);

  /// No description provided for @coursTelechargementFini.
  ///
  /// In fr, this message translates to:
  /// **'Prêt : cette formation marche sans réseau.'**
  String get coursTelechargementFini;

  /// No description provided for @coursSupprimer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du téléphone'**
  String get coursSupprimer;

  /// No description provided for @coursSupprimerConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Retirer les fichiers de cette formation ? Ta progression est gardée.'**
  String get coursSupprimerConfirmer;

  /// No description provided for @coursRienATelecharger.
  ///
  /// In fr, this message translates to:
  /// **'Rien à télécharger pour cette formation.'**
  String get coursRienATelecharger;

  /// No description provided for @coursLeconsIndisponibles.
  ///
  /// In fr, this message translates to:
  /// **'Les leçons apparaîtront quand le réseau passe.'**
  String get coursLeconsIndisponibles;

  /// No description provided for @coursErreurFichier.
  ///
  /// In fr, this message translates to:
  /// **'Un fichier est arrivé abîmé. Réessaie le téléchargement.'**
  String get coursErreurFichier;

  /// No description provided for @leconTerminee.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get leconTerminee;

  /// No description provided for @leconHorsLigne.
  ///
  /// In fr, this message translates to:
  /// **'Sans réseau'**
  String get leconHorsLigne;

  /// No description provided for @leconEnLigne.
  ///
  /// In fr, this message translates to:
  /// **'En ligne seulement'**
  String get leconEnLigne;

  /// No description provided for @leconMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String leconMinutes(int minutes);

  /// No description provided for @typeArticle.
  ///
  /// In fr, this message translates to:
  /// **'Article'**
  String get typeArticle;

  /// No description provided for @typePdf.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get typePdf;

  /// No description provided for @typeVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get typeVideo;

  /// No description provided for @typeScorm.
  ///
  /// In fr, this message translates to:
  /// **'Module interactif'**
  String get typeScorm;

  /// No description provided for @typeQuiz.
  ///
  /// In fr, this message translates to:
  /// **'Quiz'**
  String get typeQuiz;

  /// No description provided for @typeCertification.
  ///
  /// In fr, this message translates to:
  /// **'Évaluation'**
  String get typeCertification;

  /// No description provided for @typeAutre.
  ///
  /// In fr, this message translates to:
  /// **'Contenu'**
  String get typeAutre;

  /// No description provided for @lecteurTerminer.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai terminé cette leçon'**
  String get lecteurTerminer;

  /// No description provided for @lecteurDejaTerminee.
  ///
  /// In fr, this message translates to:
  /// **'Leçon terminée'**
  String get lecteurDejaTerminee;

  /// No description provided for @lecteurLireVoixHaute.
  ///
  /// In fr, this message translates to:
  /// **'Lire à voix haute'**
  String get lecteurLireVoixHaute;

  /// No description provided for @lecteurArreterLecture.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la lecture'**
  String get lecteurArreterLecture;

  /// No description provided for @lecteurTailleTexte.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte'**
  String get lecteurTailleTexte;

  /// No description provided for @lecteurNonTelechargee.
  ///
  /// In fr, this message translates to:
  /// **'Cette leçon n\'est pas sur le téléphone.'**
  String get lecteurNonTelechargee;

  /// No description provided for @lecteurOuvrirEnLigne.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir en ligne'**
  String get lecteurOuvrirEnLigne;

  /// No description provided for @lecteurTelechargerAvant.
  ///
  /// In fr, this message translates to:
  /// **'Télécharge la formation pour la suivre sans réseau.'**
  String get lecteurTelechargerAvant;

  /// No description provided for @lecteurModuleEnregistre.
  ///
  /// In fr, this message translates to:
  /// **'Ta progression est enregistrée sur le téléphone.'**
  String get lecteurModuleEnregistre;

  /// No description provided for @reglagesTitre.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get reglagesTitre;

  /// No description provided for @reglagesDonnees.
  ///
  /// In fr, this message translates to:
  /// **'Données consommées ce mois-ci'**
  String get reglagesDonnees;

  /// No description provided for @reglagesDonneesAide.
  ///
  /// In fr, this message translates to:
  /// **'Échanges avec ARC (téléchargements et envois).'**
  String get reglagesDonneesAide;

  /// No description provided for @reglagesWifi.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger seulement en Wi-Fi'**
  String get reglagesWifi;

  /// No description provided for @reglagesWifiAide.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé : les données mobiles coûtent cher.'**
  String get reglagesWifiAide;

  /// No description provided for @reglagesTailleTexte.
  ///
  /// In fr, this message translates to:
  /// **'Taille du texte des leçons'**
  String get reglagesTailleTexte;

  /// No description provided for @reglagesEnAttente.
  ///
  /// In fr, this message translates to:
  /// **'Éléments en attente d\'envoi'**
  String get reglagesEnAttente;

  /// No description provided for @reglagesEnvoyer.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer maintenant'**
  String get reglagesEnvoyer;

  /// No description provided for @reglagesContenus.
  ///
  /// In fr, this message translates to:
  /// **'Place utilisée par les formations'**
  String get reglagesContenus;

  /// No description provided for @reglagesDeconnexion.
  ///
  /// In fr, this message translates to:
  /// **'Retirer mon profil de ce téléphone'**
  String get reglagesDeconnexion;

  /// No description provided for @reglagesDeconnexionConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Ton profil et ta progression non envoyée seront effacés de ce téléphone. Les formations téléchargées restent pour les autres.'**
  String get reglagesDeconnexionConfirmer;

  /// No description provided for @reglagesDeconnexionEnAttente.
  ///
  /// In fr, this message translates to:
  /// **'Attention : {n} élément(s) ne sont pas encore envoyés et seront perdus.'**
  String reglagesDeconnexionEnAttente(int n);

  /// No description provided for @reglagesVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String reglagesVersion(String version);

  /// No description provided for @sessionAReprendre.
  ///
  /// In fr, this message translates to:
  /// **'Reconnecte-toi avec ton e-mail pour envoyer ta progression. Tu peux continuer à apprendre en attendant.'**
  String get sessionAReprendre;

  /// No description provided for @profilEfface.
  ///
  /// In fr, this message translates to:
  /// **'Ce profil a été retiré de ce téléphone à la demande d\'ARC.'**
  String get profilEfface;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
