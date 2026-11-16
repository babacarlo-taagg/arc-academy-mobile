/// Objets du contrat `api/openapi.yaml`, lus depuis le JSON du serveur.
library;

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;

class Apprenant {
  const Apprenant({required this.id, required this.nom, required this.email, required this.roles, this.langue = 'fr'});

  final int id;
  final String nom;
  final String email;
  final List<String> roles;
  final String langue;

  factory Apprenant.fromJson(Map<String, dynamic> j) => Apprenant(
    id: _int(j['id']),
    nom: j['nom'] as String? ?? '',
    email: j['email'] as String? ?? '',
    roles: [for (final r in (j['roles'] as List? ?? const [])) '$r'],
    langue: j['langue'] as String? ?? 'fr',
  );

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom, 'email': email, 'roles': roles, 'langue': langue};
}

class Session {
  const Session({
    required this.jetonAcces,
    required this.expireDans,
    required this.jetonRafraichissement,
    required this.apprenant,
  });

  final String jetonAcces;
  final int expireDans;
  final String jetonRafraichissement;
  final Apprenant apprenant;

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    jetonAcces: j['jetonAcces'] as String,
    expireDans: _int(j['expireDans']),
    jetonRafraichissement: j['jetonRafraichissement'] as String,
    apprenant: Apprenant.fromJson((j['apprenant'] as Map).cast<String, dynamic>()),
  );
}

class CodeEnvoye {
  const CodeEnvoye({required this.emailMasque, required this.expireDans, required this.renvoiPossibleDans});

  final String emailMasque;
  final int expireDans;
  final int renvoiPossibleDans;

  factory CodeEnvoye.fromJson(Map<String, dynamic> j) => CodeEnvoye(
    emailMasque: j['emailMasque'] as String? ?? '',
    expireDans: _int(j['expireDans']),
    renvoiPossibleDans: _int(j['renvoiPossibleDans']),
  );
}

class SuppressionEnregistree {
  const SuppressionEnregistree({required this.demandeLe, required this.message});

  final DateTime? demandeLe;
  final String message;

  factory SuppressionEnregistree.fromJson(Map<String, dynamic> j) => SuppressionEnregistree(
    demandeLe: DateTime.tryParse(j['demandeLe'] as String? ?? ''),
    message: j['message'] as String? ?? '',
  );
}

class Aide {
  const Aide({required this.emailSupport, this.messageSansEmail});

  final String emailSupport;
  final String? messageSansEmail;

  factory Aide.fromJson(Map<String, dynamic> j) =>
      Aide(emailSupport: j['emailSupport'] as String? ?? '', messageSansEmail: j['messageSansEmail'] as String?);
}

class Formation {
  const Formation({
    required this.id,
    required this.titre,
    this.resume = '',
    this.cohortes = const [],
    this.tuteurs = const [],
    required this.nbLecons,
    required this.nbLeconsTerminees,
    required this.progression,
    required this.version,
    required this.tailleTelechargement,
    this.derniereActivite,
  });

  final int id;
  final String titre;
  final String resume;
  final List<String> cohortes;
  final List<String> tuteurs;
  final int nbLecons;
  final int nbLeconsTerminees;
  final int progression;
  final String version;
  final int tailleTelechargement;
  final DateTime? derniereActivite;

  factory Formation.fromJson(Map<String, dynamic> j) => Formation(
    id: _int(j['id']),
    titre: j['titre'] as String? ?? '',
    resume: j['resume'] as String? ?? '',
    cohortes: [for (final c in (j['cohortes'] as List? ?? const [])) '${(c as Map)['nom']}'],
    tuteurs: [for (final t in (j['tuteurs'] as List? ?? const [])) '${(t as Map)['nom']}'],
    nbLecons: _int(j['nbLecons']),
    nbLeconsTerminees: _int(j['nbLeconsTerminees']),
    progression: _int(j['progression']).clamp(0, 100),
    version: j['version'] as String? ?? '',
    tailleTelechargement: _int(j['tailleTelechargement']),
    derniereActivite: DateTime.tryParse(j['derniereActivite'] as String? ?? ''),
  );
}

class Fichier {
  const Fichier({required this.chemin, required this.empreinte, required this.taille, required this.typeMime});

  final String chemin;
  final String empreinte;
  final int taille;
  final String typeMime;

  factory Fichier.fromJson(Map<String, dynamic> j) => Fichier(
    chemin: j['chemin'] as String,
    empreinte: (j['empreinte'] as String).toLowerCase(),
    taille: _int(j['taille']),
    typeMime: j['typeMime'] as String? ?? 'application/octet-stream',
  );

  Map<String, dynamic> toJson() => {'chemin': chemin, 'empreinte': empreinte, 'taille': taille, 'typeMime': typeMime};
}

/// Types de leçons du contrat.
enum TypeLecon {
  article,
  pdf,
  video,
  scorm,
  quiz,
  certification,
  autre;

  static TypeLecon depuis(String? v) => TypeLecon.values.firstWhere((t) => t.name == v, orElse: () => autre);
}

class Lecon {
  const Lecon({
    required this.id,
    required this.titre,
    required this.type,
    this.section,
    required this.ordre,
    this.dureeMinutes = 0,
    required this.horsLigne,
    required this.terminee,
    required this.fichiers,
    this.entree,
    this.scormVersion,
    this.urlEnLigne,
  });

  final int id;
  final String titre;
  final TypeLecon type;
  final String? section;
  final int ordre;
  final int dureeMinutes;
  final bool horsLigne;
  final bool terminee;
  final List<Fichier> fichiers;
  final String? entree;
  final String? scormVersion;
  final String? urlEnLigne;

  factory Lecon.fromJson(Map<String, dynamic> j) => Lecon(
    id: _int(j['id']),
    titre: j['titre'] as String? ?? '',
    type: TypeLecon.depuis(j['type'] as String?),
    section: j['section'] as String?,
    ordre: _int(j['ordre']),
    dureeMinutes: _int(j['dureeMinutes']),
    horsLigne: j['horsLigne'] == true,
    terminee: j['terminee'] == true,
    fichiers: [
      for (final f in (j['fichiers'] as List? ?? const [])) Fichier.fromJson((f as Map).cast<String, dynamic>()),
    ],
    entree: j['entree'] as String?,
    scormVersion: j['scormVersion'] as String?,
    urlEnLigne: j['urlEnLigne'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'type': type.name,
    'section': section,
    'ordre': ordre,
    'dureeMinutes': dureeMinutes,
    'horsLigne': horsLigne,
    'terminee': terminee,
    'fichiers': [for (final f in fichiers) f.toJson()],
    'entree': entree,
    'scormVersion': scormVersion,
    'urlEnLigne': urlEnLigne,
  };
}

class Manifest {
  const Manifest({
    required this.coursId,
    required this.version,
    required this.titre,
    required this.tailleTotale,
    required this.lecons,
  });

  final int coursId;
  final String version;
  final String titre;
  final int tailleTotale;
  final List<Lecon> lecons;

  factory Manifest.fromJson(Map<String, dynamic> j) => Manifest(
    coursId: _int(j['coursId']),
    version: j['version'] as String? ?? '',
    titre: j['titre'] as String? ?? '',
    tailleTotale: _int(j['tailleTotale']),
    lecons: [for (final l in (j['lecons'] as List? ?? const [])) Lecon.fromJson((l as Map).cast<String, dynamic>())],
  );

  Map<String, dynamic> toJson() => {
    'coursId': coursId,
    'version': version,
    'titre': titre,
    'tailleTotale': tailleTotale,
    'lecons': [for (final l in lecons) l.toJson()],
  };

  /// Fichiers distincts (par empreinte) nécessaires au hors-ligne.
  Map<String, Fichier> get fichiersDistincts => {
    for (final l in lecons)
      for (final f in l.fichiers) f.empreinte: f,
  };
}

class EtatScormServeur {
  const EtatScormServeur({
    this.completionStatus = 'unknown',
    this.successStatus = 'unknown',
    this.scorePourcent,
    this.totalTimeSeconds = 0,
    this.runtimeData,
  });

  final String completionStatus;
  final String successStatus;
  final double? scorePourcent;
  final int totalTimeSeconds;
  final Map<String, dynamic>? runtimeData;

  factory EtatScormServeur.fromJson(Map<String, dynamic> j) => EtatScormServeur(
    completionStatus: j['completionStatus'] as String? ?? 'unknown',
    successStatus: j['successStatus'] as String? ?? 'unknown',
    scorePourcent: (j['scorePourcent'] as num?)?.toDouble(),
    totalTimeSeconds: _int(j['totalTimeSeconds']),
    runtimeData: (j['runtimeData'] as Map?)?.cast<String, dynamic>(),
  );
}

class EtatLecon {
  const EtatLecon({required this.leconId, required this.terminee, this.scorm});

  final int leconId;
  final bool terminee;
  final EtatScormServeur? scorm;

  factory EtatLecon.fromJson(Map<String, dynamic> j) => EtatLecon(
    leconId: _int(j['leconId']),
    terminee: j['terminee'] == true,
    scorm: j['scorm'] is Map ? EtatScormServeur.fromJson((j['scorm'] as Map).cast<String, dynamic>()) : null,
  );
}

class EtatFormation {
  const EtatFormation({required this.coursId, required this.progression, required this.lecons});

  final int coursId;
  final int progression;
  final List<EtatLecon> lecons;

  factory EtatFormation.fromJson(Map<String, dynamic> j) => EtatFormation(
    coursId: _int(j['coursId']),
    progression: _int(j['progression']).clamp(0, 100),
    lecons: [
      for (final l in (j['lecons'] as List? ?? const [])) EtatLecon.fromJson((l as Map).cast<String, dynamic>()),
    ],
  );
}

class EtatSynchro {
  const EtatSynchro({required this.formations});

  final List<EtatFormation> formations;

  factory EtatSynchro.fromJson(Map<String, dynamic> j) => EtatSynchro(
    formations: [
      for (final f in (j['formations'] as List? ?? const []))
        EtatFormation.fromJson((f as Map).cast<String, dynamic>()),
    ],
  );
}

class ResultatEvenement {
  const ResultatEvenement({required this.id, required this.statut, this.raison});

  final String id;
  final String statut;
  final String? raison;

  bool get estRecu => statut == 'accepte' || statut == 'deja_recu';

  factory ResultatEvenement.fromJson(Map<String, dynamic> j) =>
      ResultatEvenement(id: j['id'] as String, statut: j['statut'] as String? ?? '', raison: j['raison'] as String?);
}

class ResultatSynchro {
  const ResultatSynchro({required this.resultats, required this.etat});

  final List<ResultatEvenement> resultats;
  final EtatSynchro etat;

  factory ResultatSynchro.fromJson(Map<String, dynamic> j) => ResultatSynchro(
    resultats: [
      for (final r in (j['resultats'] as List? ?? const []))
        ResultatEvenement.fromJson((r as Map).cast<String, dynamic>()),
    ],
    etat: EtatSynchro.fromJson((j['etat'] as Map? ?? const {}).cast<String, dynamic>()),
  );
}

// ───────── Profil apprenant (contrat 0.3.0) ─────────

/// Questions du profil, dans l'ordre où on les pose.
abstract final class ChampProfil {
  static const pays = 'pays';
  static const metier = 'metier';
  static const langue = 'langue';
  static const institution = 'institution';
  static const typeInstitution = 'typeInstitution';
  static const niveau = 'niveau';
  static const sexe = 'sexe';

  /// Questions de l'écran « Ton institution » (après la première inscription à un cours).
  static const groupeInstitution = {institution, typeInstitution, niveau};
}

class InstitutionProfil {
  const InstitutionProfil({this.id, required this.nom});
  final int? id;
  final String nom;

  factory InstitutionProfil.fromJson(Map<String, dynamic> j) =>
      InstitutionProfil(id: j['id'] == null ? null : _int(j['id']), nom: j['nom'] as String? ?? '');

  Map<String, dynamic> toJson() => {'id': id, 'nom': nom};
}

class ProfilApprenant {
  const ProfilApprenant({
    this.pays,
    this.metier,
    this.langue,
    this.institution,
    this.typeInstitution,
    this.niveau,
    this.sexe,
    this.whatsapp,
    this.whatsappAccord = false,
    this.whatsappAccordVersion,
    this.whatsappTexte = '',
    this.completude = 0,
    this.questionsAPoser = const [],
    this.obligatoires = const [],
  });

  final String? pays;
  final String? metier;
  final String? langue;
  final InstitutionProfil? institution;
  final String? typeInstitution;
  final String? niveau;
  final String? sexe;
  final String? whatsapp;
  final bool whatsappAccord;
  final String? whatsappAccordVersion;
  final String whatsappTexte;
  final int completude;
  final List<String> questionsAPoser;
  final List<String> obligatoires;

  /// L'appli ne peut pas continuer tant que ces questions n'ont pas de réponse (pays, métier).
  bool get bloquant => obligatoires.isNotEmpty;

  /// Questions de l'écran « Ton institution » encore à poser.
  List<String> get questionsInstitution => [
    for (final q in questionsAPoser)
      if (ChampProfil.groupeInstitution.contains(q)) q,
  ];

  static String? _texte(Object? v) => v is String && v.isNotEmpty ? v : null;

  factory ProfilApprenant.fromJson(Map<String, dynamic> j) => ProfilApprenant(
    pays: _texte(j['pays']),
    metier: _texte(j['metier']),
    langue: _texte(j['langue']),
    institution: j['institution'] is Map
        ? InstitutionProfil.fromJson((j['institution'] as Map).cast<String, dynamic>())
        : null,
    typeInstitution: _texte(j['typeInstitution']),
    niveau: _texte(j['niveau']),
    sexe: _texte(j['sexe']),
    whatsapp: _texte(j['whatsapp']),
    whatsappAccord: j['whatsappAccord'] == true,
    whatsappAccordVersion: _texte(j['whatsappAccordVersion']),
    whatsappTexte: j['whatsappTexte'] as String? ?? '',
    completude: _int(j['completude']).clamp(0, 100),
    questionsAPoser: [for (final q in (j['questionsAPoser'] as List? ?? const [])) '$q'].take(3).toList(),
    obligatoires: [for (final q in (j['obligatoires'] as List? ?? const [])) '$q'],
  );

  Map<String, dynamic> toJson() => {
    'pays': pays,
    'metier': metier,
    'langue': langue,
    'institution': institution?.toJson(),
    'typeInstitution': typeInstitution,
    'niveau': niveau,
    'sexe': sexe,
    'whatsapp': whatsapp,
    'whatsappAccord': whatsappAccord,
    'whatsappAccordVersion': whatsappAccordVersion,
    'whatsappTexte': whatsappTexte,
    'completude': completude,
    'questionsAPoser': questionsAPoser,
    'obligatoires': obligatoires,
  };
}

class Choix {
  const Choix(this.cle, this.libelle);
  final String cle;
  final String libelle;

  factory Choix.fromJson(Map<String, dynamic> j) => Choix('${j['cle']}', j['libelle'] as String? ?? '${j['cle']}');
  Map<String, dynamic> toJson() => {'cle': cle, 'libelle': libelle};
}

/// Listes de choix du profil, gardées sur le téléphone.
class Referentiels {
  const Referentiels({
    required this.version,
    this.pays = const [],
    this.metiers = const [],
    this.typesInstitution = const [],
    this.niveaux = const [],
    this.sexes = const [],
    this.langues = const [],
  });

  final String version;
  final List<Choix> pays;
  final List<Choix> metiers;
  final List<Choix> typesInstitution;
  final List<Choix> niveaux;
  final List<Choix> sexes;
  final List<Choix> langues;

  static List<Choix> _liste(Object? v) => [
    for (final c in (v as List? ?? const [])) Choix.fromJson((c as Map).cast<String, dynamic>()),
  ];

  factory Referentiels.fromJson(Map<String, dynamic> j) => Referentiels(
    version: j['version'] as String? ?? '',
    pays: _liste(j['pays']),
    metiers: _liste(j['metiers']),
    typesInstitution: _liste(j['typesInstitution']),
    niveaux: _liste(j['niveaux']),
    sexes: _liste(j['sexes']),
    langues: _liste(j['langues']),
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    for (final (cle, liste) in [
      ('pays', pays),
      ('metiers', metiers),
      ('typesInstitution', typesInstitution),
      ('niveaux', niveaux),
      ('sexes', sexes),
      ('langues', langues),
    ])
      cle: [for (final c in liste) c.toJson()],
  };

  /// Libellé d'une clé (la clé elle-même si la liste ne la connaît pas).
  static String libelle(List<Choix> liste, String? cle) =>
      cle == null ? '' : (liste.where((c) => c.cle == cle).firstOrNull?.libelle ?? cle);
}

class Organisation {
  const Organisation({required this.id, required this.nom, this.pays});
  final int id;
  final String nom;
  final String? pays;

  factory Organisation.fromJson(Map<String, dynamic> j) =>
      Organisation(id: _int(j['id']), nom: j['nom'] as String? ?? '', pays: j['pays'] as String?);
}

// ───────── Notifications (contrat 0.4.0) ─────────

/// Canaux et sujets des notifications (clés du contrat).
abstract final class CanalNotification {
  static const email = 'email';
  static const push = 'push';
  static const whatsapp = 'whatsapp';
}

abstract final class SujetNotification {
  static const cours = 'cours';
  static const communaute = 'communaute';
  static const talent = 'talent';
  static const nouveautes = 'nouveautes';
}

class CanalDisponible {
  const CanalDisponible({required this.cle, required this.libelle, this.disponible = true});
  final String cle;
  final String libelle;
  final bool disponible;

  factory CanalDisponible.fromJson(Map<String, dynamic> j) => CanalDisponible(
    cle: '${j['cle']}',
    libelle: j['libelle'] as String? ?? '${j['cle']}',
    disponible: j['disponible'] != false,
  );
  Map<String, dynamic> toJson() => {'cle': cle, 'libelle': libelle, 'disponible': disponible};
}

class PreferenceNotification {
  const PreferenceNotification({required this.canal, required this.sujet, required this.actif});
  final String canal;
  final String sujet;
  final bool actif;

  factory PreferenceNotification.fromJson(Map<String, dynamic> j) =>
      PreferenceNotification(canal: '${j['canal']}', sujet: '${j['sujet']}', actif: j['actif'] == true);
  Map<String, dynamic> toJson() => {'canal': canal, 'sujet': sujet, 'actif': actif};
}

/// Ce que l'apprenant veut recevoir, par canal et par sujet.
class PreferencesNotifications {
  const PreferencesNotifications({this.canaux = const [], this.sujets = const [], this.preferences = const []});

  final List<CanalDisponible> canaux;
  final List<Choix> sujets;
  final List<PreferenceNotification> preferences;

  bool actif(String canal, String sujet) =>
      preferences.where((p) => p.canal == canal && p.sujet == sujet).firstOrNull?.actif ?? false;

  /// Les mêmes préférences, avec ces lignes changées (ou ajoutées).
  PreferencesNotifications avec(List<PreferenceNotification> changements) {
    final lignes = [...preferences];
    for (final c in changements) {
      final i = lignes.indexWhere((p) => p.canal == c.canal && p.sujet == c.sujet);
      if (i >= 0) {
        lignes[i] = c;
      } else {
        lignes.add(c);
      }
    }
    return PreferencesNotifications(canaux: canaux, sujets: sujets, preferences: lignes);
  }

  factory PreferencesNotifications.fromJson(Map<String, dynamic> j) => PreferencesNotifications(
    canaux: [
      for (final c in (j['canaux'] as List? ?? const [])) CanalDisponible.fromJson((c as Map).cast<String, dynamic>()),
    ],
    sujets: [for (final s in (j['sujets'] as List? ?? const [])) Choix.fromJson((s as Map).cast<String, dynamic>())],
    preferences: [
      for (final p in (j['preferences'] as List? ?? const []))
        PreferenceNotification.fromJson((p as Map).cast<String, dynamic>()),
    ],
  );

  Map<String, dynamic> toJson() => {
    'canaux': [for (final c in canaux) c.toJson()],
    'sujets': [for (final s in sujets) s.toJson()],
    'preferences': [for (final p in preferences) p.toJson()],
  };
}

/// Écran à ouvrir depuis un message : `cours` et `lecon` dans l'appli, le reste dans le navigateur (`url`).
class CibleNotification {
  const CibleNotification({required this.type, this.id, this.coursId, this.url});
  final String type;
  final int? id;
  final int? coursId;
  final String? url;

  /// Chemin de l'écran de l'appli, ou null s'il faut ouvrir `url`.
  String? get route => switch (type) {
    'cours' when id != null => '/cours/$id',
    'lecon' when id != null && coursId != null => '/lecon/$coursId/$id',
    _ => null,
  };

  factory CibleNotification.fromJson(Map<String, dynamic> j) => CibleNotification(
    type: '${j['type']}',
    id: j['id'] == null ? null : _int(j['id']),
    coursId: j['coursId'] == null ? null : _int(j['coursId']),
    url: j['url'] as String?,
  );
  Map<String, dynamic> toJson() => {'type': type, 'id': id, 'coursId': coursId, 'url': url};
}

class NotificationArc {
  const NotificationArc({
    required this.id,
    required this.titre,
    required this.texte,
    required this.sujet,
    required this.envoyeeLe,
    this.lue = false,
    this.cible,
  });

  final int id;
  final String titre;
  final String texte;
  final String sujet;
  final DateTime envoyeeLe;
  final bool lue;
  final CibleNotification? cible;

  NotificationArc commeLue() =>
      NotificationArc(id: id, titre: titre, texte: texte, sujet: sujet, envoyeeLe: envoyeeLe, lue: true, cible: cible);

  factory NotificationArc.fromJson(Map<String, dynamic> j) => NotificationArc(
    id: _int(j['id']),
    titre: j['titre'] as String? ?? '',
    texte: j['texte'] as String? ?? '',
    sujet: j['sujet'] as String? ?? '',
    envoyeeLe: DateTime.tryParse('${j['envoyeeLe']}')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    lue: j['lue'] == true,
    cible: j['cible'] is Map ? CibleNotification.fromJson((j['cible'] as Map).cast<String, dynamic>()) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'texte': texte,
    'sujet': sujet,
    'envoyeeLe': envoyeeLe.toUtc().toIso8601String(),
    'lue': lue,
    'cible': cible?.toJson(),
  };
}

class BoiteDeReception {
  const BoiteDeReception({this.notifications = const [], this.nonLues = 0});
  final List<NotificationArc> notifications;
  final int nonLues;

  factory BoiteDeReception.fromJson(Map<String, dynamic> j) => BoiteDeReception(
    notifications: [
      for (final n in (j['notifications'] as List? ?? const []))
        NotificationArc.fromJson((n as Map).cast<String, dynamic>()),
    ],
    nonLues: _int(j['nonLues']),
  );

  Map<String, dynamic> toJson() => {
    'notifications': [for (final n in notifications) n.toJson()],
    'nonLues': nonLues,
  };
}
