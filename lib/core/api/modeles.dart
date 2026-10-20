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
