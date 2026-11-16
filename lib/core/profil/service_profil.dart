import 'dart:async';
import 'dart:convert';

import '../api/api_client.dart';
import '../api/modeles.dart';
import '../db/base.dart';

/// Où en est le profil apprenant sur ce téléphone.
enum EtatProfil {
  /// Jamais lu, première lecture en cours.
  chargement,

  /// Jamais lu et pas de réseau : il en faut une fois.
  reseauNecessaire,

  /// Pays ou métier manquent : écran « Ton profil » obligatoire.
  aCompleter,

  /// L'appli peut continuer.
  pret,
}

/// Ce que les écrans voient du profil (une nouvelle valeur à chaque changement).
class InstantaneProfil {
  const InstantaneProfil({
    this.profil,
    this.etat = EtatProfil.chargement,
    this.referentiels,
    this.premierTelechargement = false,
    this.envoiEnAttente = false,
  });

  final ProfilApprenant? profil;
  final EtatProfil etat;

  /// Listes de choix dans la langue de l'appli (ou, à défaut, dans l'autre langue gardée).
  final Referentiels? referentiels;

  /// Un cours a déjà été téléchargé : on peut proposer « Ton institution ».
  final bool premierTelechargement;

  /// Des modifications attendent le réseau.
  final bool envoiEnAttente;

  /// Questions de « Ton institution » à proposer maintenant.
  List<String> get questionsInstitution =>
      premierTelechargement ? (profil?.questionsInstitution ?? const []) : const [];

  bool get demanderSexe => profil?.questionsAPoser.contains(ChampProfil.sexe) ?? false;
}

/// Profil apprenant d'un profil ouvert : gardé dans la base chiffrée, modifié même hors ligne.
///
/// Les modifications sont appliquées tout de suite sur le téléphone, puis envoyées (PATCH sans risque à rejouer).
/// Hors ligne, elles attendent le retour du réseau.
class ServiceProfil {
  ServiceProfil({required this.db, required this.api, required this.langueTelephone});

  final BaseProfil db;
  final ApiClient api;
  final String Function() langueTelephone;

  static const _cleProfil = 'profil';
  static const _cleEnAttente = 'profil:en_attente';
  static const _cleTelechargement = 'profil:premier_telechargement';
  static String _cleReferentiels(String langue) => 'referentiels:$langue';

  ProfilApprenant? _profil;
  Map<String, dynamic> _enAttente = {};
  final Map<String, Referentiels> _referentiels = {};
  bool _premierTelechargement = false;
  bool _lectureEchouee = false;
  bool _ferme = false;

  final _flux = StreamController<InstantaneProfil>.broadcast();
  late InstantaneProfil _actuel = _instantane();

  InstantaneProfil get actuel => _actuel;
  Stream<InstantaneProfil> get changements => _flux.stream;

  /// Langue de l'appli : celle du profil, sinon celle du téléphone.
  String get langue => _profil?.langue ?? langueTelephone();

  /// Lit ce qui est gardé sur le téléphone (avant d'afficher le premier écran).
  Future<void> charger() async {
    final brut = await db.lireMeta(_cleProfil);
    if (brut != null && brut.isNotEmpty) _profil = ProfilApprenant.fromJson(_objet(brut));
    final attente = await db.lireMeta(_cleEnAttente);
    _enAttente = attente == null || attente.isEmpty ? {} : _objet(attente);
    for (final l in ['fr', 'en']) {
      final r = await db.lireMeta(_cleReferentiels(l));
      if (r != null && r.isNotEmpty) _referentiels[l] = Referentiels.fromJson(_objet(r));
    }
    _premierTelechargement = await db.lireMeta(_cleTelechargement) == '1';
    _publier();
  }

  static Map<String, dynamic> _objet(String json) => (jsonDecode(json) as Map).cast<String, dynamic>();

  InstantaneProfil _instantane() {
    final p = _profil;
    final etat = p == null
        ? (_lectureEchouee ? EtatProfil.reseauNecessaire : EtatProfil.chargement)
        : (p.bloquant ? EtatProfil.aCompleter : EtatProfil.pret);
    return InstantaneProfil(
      profil: p,
      etat: etat,
      referentiels: _referentiels[langue] ?? _referentiels.values.firstOrNull,
      premierTelechargement: _premierTelechargement,
      envoiEnAttente: _enAttente.isNotEmpty,
    );
  }

  void _publier() {
    if (_ferme) return;
    _actuel = _instantane();
    _flux.add(_actuel);
  }

  Future<void> _file = Future.value();

  /// Une opération réseau à la fois (envoi puis lecture, jamais l'inverse).
  Future<T> _tour<T>(Future<T> Function() f) {
    final suite = _file.then((_) => f());
    _file = suite.then((_) {}, onError: (_) {});
    return suite;
  }

  /// Envoie les modifications en attente, relit le profil et les listes de choix. Silencieux hors ligne.
  Future<void> rafraichir() => _tour(() async {
    if (_ferme) return;
    if (!await _envoyer()) {
      if (_profil == null) {
        _lectureEchouee = true;
        _publier();
      }
      return;
    }
    try {
      await _enregistrer(_avecEnAttente(await api.lireProfil(langue: langue)));
    } on ApiException {
      if (_profil == null) {
        _lectureEchouee = true;
        _publier();
      }
      return;
    }
    await _rafraichirReferentiels();
  });

  /// Réessaie la première lecture (bouton « Réessayer »).
  Future<void> reessayer() {
    _lectureEchouee = false;
    _publier();
    return rafraichir();
  }

  Future<void> _rafraichirReferentiels() async {
    final l = langue;
    try {
      final r = await api.referentiels(langue: l, versionLocale: _referentiels[l]?.version);
      if (r == null || _ferme) return;
      _referentiels[l] = r;
      await db.ecrireMeta(_cleReferentiels(l), jsonEncode(r.toJson()));
      _publier();
    } on ApiException {
      // on garde les listes du téléphone
    }
  }

  Future<void> _enregistrer(ProfilApprenant p) async {
    if (_ferme) return;
    final avant = langue;
    _profil = p;
    _lectureEchouee = false;
    await db.ecrireMeta(_cleProfil, jsonEncode(p.toJson()));
    _publier();
    if (langue != avant) unawaited(_tour(_rafraichirReferentiels));
  }

  /// Réponse du serveur, plus ce qui a été modifié depuis et n'est pas encore parti.
  ProfilApprenant _avecEnAttente(ProfilApprenant p) =>
      _enAttente.isEmpty ? p : _appliquer(p, _enAttente, _nomInstitution);

  /// Nom de l'institution choisie dans la liste (le serveur ne reçoit que son identifiant).
  String? _nomInstitution;

  /// Vrai si plus rien n'attend (ou si la modification a été refusée : on ne la rejoue pas).
  Future<bool> _envoyer() async {
    if (_enAttente.isEmpty) return true;
    final envoi = Map<String, dynamic>.of(_enAttente);
    try {
      final p = await api.modifierProfil(envoi, langue: langue);
      await _retirerEnvoyes(envoi);
      await _enregistrer(_avecEnAttente(p));
      return true;
    } on ApiException catch (e) {
      if (e.estReseau || e.status == null || e.status! >= 500 || e.status == 401) return false;
      // Refusée par le serveur (donnée invalide) : la rejouer ne servirait à rien.
      await _retirerEnvoyes(envoi);
      return true;
    }
  }

  Future<void> _retirerEnvoyes(Map<String, dynamic> envoi) async {
    for (final e in envoi.entries) {
      final actuel = _enAttente[e.key];
      if (jsonEncode(actuel) == jsonEncode(e.value)) _enAttente.remove(e.key);
    }
    await db.ecrireMeta(_cleEnAttente, _enAttente.isEmpty ? '' : jsonEncode(_enAttente));
    _publier();
  }

  /// Enregistre une modification : visible tout de suite, envoyée dès que possible.
  /// `nomInstitution` : nom de l'institution choisie par son identifiant, pour l'afficher en attendant le serveur.
  Future<void> modifier(Map<String, dynamic> modification, {String? nomInstitution}) async {
    if (modification.isEmpty || _ferme) return;
    if (nomInstitution != null) _nomInstitution = nomInstitution;
    for (final e in modification.entries) {
      if (e.key == 'ignorer') {
        _enAttente['ignorer'] = {...?(_enAttente['ignorer'] as List?)?.cast<String>(), ...e.value as List}.toList();
      } else {
        _enAttente[e.key] = e.value;
      }
    }
    // Choisir une institution de la liste ou en taper une remplace l'autre.
    if (modification.containsKey('institutionId')) _enAttente.remove('institutionNom');
    if (modification.containsKey('institutionNom')) _enAttente.remove('institutionId');
    await db.ecrireMeta(_cleEnAttente, jsonEncode(_enAttente));
    final p = _profil;
    if (p != null) await _enregistrer(_appliquer(p, modification, _nomInstitution));
    unawaited(_tour(_envoyer));
  }

  /// Passe des questions facultatives (« Plus tard », « Passer »).
  Future<void> ignorer(List<String> champs) => modifier({'ignorer': champs});

  /// Le premier téléchargement d'un cours vient de commencer.
  Future<void> marquerTelechargement() async {
    if (_premierTelechargement || _ferme) return;
    _premierTelechargement = true;
    await db.ecrireMeta(_cleTelechargement, '1');
    _publier();
  }

  /// Le profil tel qu'il sera après la modification (en attendant la réponse du serveur).
  static ProfilApprenant _appliquer(ProfilApprenant p, Map<String, dynamic> m, String? nomChoisi) {
    String? texte(String cle, String? avant) => m.containsKey(cle) ? m[cle] as String? : avant;
    final repondus = <String>{
      for (final cle in m.keys)
        switch (cle) {
          'institutionId' || 'institutionNom' => ChampProfil.institution,
          _ => cle,
        },
      ...?(m['ignorer'] as List?)?.cast<String>(),
    };
    InstitutionProfil? institution = p.institution;
    if (m.containsKey('institutionId') || m.containsKey('institutionNom')) {
      final nom = m['institutionNom'] as String? ?? (m['institutionId'] == null ? null : nomChoisi);
      institution = nom == null || nom.isEmpty ? null : InstitutionProfil(id: m['institutionId'] as int?, nom: nom);
    }
    final accord = m.containsKey('whatsappAccord') ? m['whatsappAccord'] == true : p.whatsappAccord;
    final nouveau = ProfilApprenant(
      pays: texte('pays', p.pays),
      metier: texte('metier', p.metier),
      langue: texte('langue', p.langue),
      institution: institution,
      typeInstitution: texte('typeInstitution', p.typeInstitution),
      niveau: texte('niveau', p.niveau),
      sexe: texte('sexe', p.sexe),
      whatsapp: texte('whatsapp', p.whatsapp),
      whatsappAccord: accord,
      whatsappAccordVersion: p.whatsappAccordVersion,
      whatsappTexte: p.whatsappTexte,
      questionsAPoser: [
        for (final q in p.questionsAPoser)
          if (!repondus.contains(q)) q,
      ],
      obligatoires: [
        for (final q in p.obligatoires)
          if (!repondus.contains(q)) q,
      ],
    );
    final remplis = [
      nouveau.pays,
      nouveau.metier,
      nouveau.langue,
      nouveau.institution?.nom,
      nouveau.typeInstitution,
      nouveau.niveau,
    ].where((v) => v != null && v.isNotEmpty).length;
    return ProfilApprenant.fromJson({...nouveau.toJson(), 'completude': (remplis * 100 / 6).round()});
  }

  Future<void> fermer() async {
    _ferme = true;
    await _flux.close();
  }
}
