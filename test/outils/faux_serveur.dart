import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Faux serveur ARC (routes du contrat), en mémoire, pour tester l'appli sans Odoo.
///
/// Il sait simuler les ennuis du terrain : réponse perdue après traitement, connexion coupée au milieu d'un
/// fichier, session expirée, profil à effacer.
class FauxServeur {
  late HttpServer _serveur;
  String get url => 'http://127.0.0.1:${_serveur.port}/api/v1';

  /// Événements reçus (identifiant → événement), comme le journal du serveur.
  final Map<String, Map<String, dynamic>> evenementsRecus = {};
  final List<int> taillesPaquets = [];
  int requetesGzip = 0;

  /// Leçons inconnues : les événements qui les visent sont refusés.
  final Set<int> leconsInconnues = {};

  /// Traite le prochain paquet puis coupe la connexion sans répondre (la réponse « se perd »).
  bool perdreProchaineReponse = false;

  /// Fichiers servis par empreinte.
  final Map<String, List<int>> fichiers = {};
  final List<String> fichiersDemandes = [];
  final List<String?> rangesRecus = [];

  /// Coupe la connexion après ce nombre d'octets au prochain fichier servi (une seule fois).
  int? couperFichierApres;

  /// Sert un contenu différent de son empreinte (fichier abîmé).
  bool servirFichierAbime = false;

  // Session
  final Set<String> jetonsValides = {'acces-1'};
  String jetonRafraichissement = 'rafraichir-1';
  int rafraichissements = 0;
  bool profilEfface = false;
  bool sessionRevoquee = false;
  int _numero = 1;

  /// Demandes de suppression de compte reçues (motif, ou null).
  final List<String?> suppressions = [];

  List<Map<String, dynamic>> formations = [];

  // ───────── Profil (0.3.0) ─────────

  /// Profil apprenant renvoyé par `/moi/profil` (complet par défaut : rien à demander).
  Map<String, dynamic> profil = profilComplet();

  static Map<String, dynamic> profilComplet() => {
    'pays': 'SN',
    'metier': 'infirmier',
    'langue': 'fr',
    'institution': {'id': 5, 'nom': 'Centre de santé de Kolda'},
    'typeInstitution': 'centre_sante',
    'niveau': 'district',
    'sexe': null,
    'whatsapp': null,
    'whatsappAccord': false,
    'whatsappAccordVersion': 'whatsapp-2026-11-v1',
    'whatsappTexte': "J'accepte qu'ARC Academy m'écrive sur WhatsApp à ce numéro.",
    'completude': 100,
    'questionsAPoser': <String>[],
    'obligatoires': <String>[],
  };

  /// Profil d'un nouvel apprenant : seulement le nom et l'e-mail.
  static Map<String, dynamic> profilVide() => {
    ...profilComplet(),
    'pays': null,
    'metier': null,
    'langue': null,
    'institution': null,
    'typeInstitution': null,
    'niveau': null,
    'completude': 0,
    'questionsAPoser': ['pays', 'metier', 'langue'],
    'obligatoires': ['pays', 'metier'],
  };

  /// Corps des PATCH /moi/profil reçus.
  final List<Map<String, dynamic>> modificationsProfil = [];

  /// Langues demandées (en-tête Accept-Language) à chaque appel de /referentiels.
  final List<String?> languesReferentiels = [];
  final List<String> recherchesOrganisations = [];
  String versionReferentiels = 'r1';
  int referentielsNonModifies = 0;

  final List<Map<String, dynamic>> organisations = [
    {'id': 5, 'nom': 'Centre de santé de Kolda', 'pays': 'SN'},
    {'id': 6, 'nom': 'Hôpital régional de Kolda', 'pays': 'SN'},
    {'id': 7, 'nom': 'District sanitaire de Parakou', 'pays': 'BJ'},
  ];

  // ───────── Notifications (0.4.0) ─────────

  /// Jetons reçus par PUT /appareil/push, et nombre de DELETE.
  final List<Map<String, dynamic>> jetonsPush = [];
  int retraitsJetonPush = 0;

  /// Messages de la boîte de réception (le serveur calcule `nonLues`).
  List<Map<String, dynamic>> messages = [];
  final List<List<int>> idsLus = [];

  /// Préférences : une ligne par canal et par sujet ; WhatsApp indisponible par défaut.
  bool whatsappDisponible = false;
  final Map<String, bool> preferences = {'email:cours': true};
  final List<List<Map<String, dynamic>>> modificationsPreferences = [];

  /// Simule une coupure pour les notifications.
  bool notificationsInjoignables = false;

  static Map<String, dynamic> message(int id, {bool lue = false, Map<String, dynamic>? cible}) => {
    'id': id,
    'titre': 'Ton cours t\'attend',
    'texte': 'Il te reste 2 leçons pour terminer « Pharmacovigilance ».',
    'sujet': 'cours',
    'envoyeeLe': '2026-11-20T09:00:00Z',
    'lue': lue,
    'cible': cible,
  };

  Map<String, dynamic> _preferences(String langue) {
    final en = langue == 'en';
    const canaux = ['email', 'push', 'whatsapp'];
    const sujets = ['cours', 'communaute', 'talent', 'nouveautes'];
    return {
      'canaux': [
        {'cle': 'email', 'libelle': en ? 'Email' : 'E-mail', 'disponible': true},
        {
          'cle': 'push',
          'libelle': en ? 'Notification on the phone' : 'Notification sur le téléphone',
          'disponible': true,
        },
        {'cle': 'whatsapp', 'libelle': 'WhatsApp', 'disponible': whatsappDisponible},
      ],
      'sujets': [
        {'cle': 'cours', 'libelle': en ? 'Reminders about my courses' : 'Rappels de mes cours'},
        {'cle': 'communaute', 'libelle': en ? 'Community and forums' : 'Communauté et forums'},
        {'cle': 'talent', 'libelle': en ? 'Talent Hub opportunities' : 'Opportunités du Talent Hub'},
        {'cle': 'nouveautes', 'libelle': en ? 'New courses and events' : 'Nouvelles formations et événements'},
      ],
      'preferences': [
        for (final c in canaux)
          for (final su in sujets) {'canal': c, 'sujet': su, 'actif': preferences['$c:$su'] ?? false},
      ],
    };
  }

  /// Simule une coupure : les requêtes vers le profil échouent sans réponse.
  bool profilInjoignable = false;
  final Map<int, Map<String, dynamic>> manifestes = {};
  final Map<String, int> appels = {};

  Future<void> demarrer() async {
    _serveur = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _serveur.listen(_traiter);
  }

  Future<void> arreter() => _serveur.close(force: true);

  void ajouterFichier(List<int> contenu) => fichiers[sha256.convert(contenu).toString()] = contenu;

  static String empreinte(List<int> contenu) => sha256.convert(contenu).toString();

  Future<void> _json(HttpResponse r, int statut, Object? corps) async {
    r.statusCode = statut;
    if (corps != null) {
      r.headers.contentType = statut >= 400
          ? ContentType('application', 'problem+json', charset: 'utf-8')
          : ContentType.json;
      r.write(jsonEncode(corps));
    }
    await r.close();
  }

  Future<void> _probleme(HttpResponse r, int statut, String code) =>
      _json(r, statut, {'type': 'about:blank', 'title': code, 'status': statut, 'code': code});

  bool _autorise(HttpRequest q) {
    final entete = q.headers.value('authorization') ?? '';
    return entete.startsWith('Bearer ') && jetonsValides.contains(entete.substring(7));
  }

  Future<void> _traiter(HttpRequest q) async {
    final r = q.response;
    final chemin = q.uri.path.replaceFirst('/api/v1', '');
    appels[chemin] = (appels[chemin] ?? 0) + 1;
    try {
      if (chemin == '/auth/rafraichir') return await _rafraichir(q);
      if (chemin == '/auth/code') {
        await utf8.decodeStream(q);
        return await _json(r, 202, {'emailMasque': 'a•••@example.org', 'expireDans': 600, 'renvoiPossibleDans': 45});
      }
      if (chemin == '/auth/verification') {
        final corps = jsonDecode(await utf8.decodeStream(q)) as Map;
        if (corps['code'] != '123456') {
          return await _json(r, 401, {
            'title': 'Code incorrect',
            'status': 401,
            'code': 'code_invalide',
            'essaisRestants': 4,
          });
        }
        return await _json(r, 200, _session());
      }
      if (profilEfface) return await _probleme(r, 401, 'profil_efface');
      if (!_autorise(q)) return await _probleme(r, 401, 'jeton_expire');
      if (chemin == '/formations') return await _json(r, 200, {'formations': formations});
      if (chemin == '/moi/profil' || chemin == '/referentiels' || chemin == '/organisations') {
        if (profilInjoignable) {
          final socket = await r.detachSocket(writeHeaders: false);
          socket.destroy();
          return;
        }
      }
      if (chemin == '/moi/profil' && q.method == 'GET') return await _json(r, 200, profil);
      if (chemin == '/moi/profil' && q.method == 'PATCH') {
        final corps = (jsonDecode(await utf8.decodeStream(q)) as Map).cast<String, dynamic>();
        modificationsProfil.add(corps);
        _modifierProfil(corps);
        return await _json(r, 200, profil);
      }
      if (chemin == '/referentiels') {
        final langue = q.headers.value('accept-language');
        languesReferentiels.add(langue);
        if (q.headers.value('if-none-match') == versionReferentiels) {
          referentielsNonModifies++;
          return await _json(r, 304, null);
        }
        r.headers.set('etag', versionReferentiels);
        return await _json(r, 200, referentiels(langue ?? 'fr', versionReferentiels));
      }
      if (chemin == '/organisations') {
        final recherche = q.uri.queryParameters['recherche'] ?? '';
        recherchesOrganisations.add(recherche);
        if (recherche.length < 3) return await _probleme(r, 400, 'invalide');
        return await _json(r, 200, {
          'organisations': [
            for (final o in organisations)
              if ((o['nom'] as String).toLowerCase().contains(recherche.toLowerCase())) o,
          ],
        });
      }
      if (const [
        '/appareil/push',
        '/notifications',
        '/notifications/lues',
        '/moi/preferences-notifications',
      ].contains(chemin)) {
        if (notificationsInjoignables) {
          final socket = await r.detachSocket(writeHeaders: false);
          socket.destroy();
          return;
        }
        final brut = await utf8.decodeStream(q);
        final corps = brut.isEmpty ? const <String, dynamic>{} : (jsonDecode(brut) as Map).cast<String, dynamic>();
        final langue = q.headers.value('accept-language') ?? 'fr';
        if (chemin == '/appareil/push' && q.method == 'PUT') {
          jetonsPush.add(corps);
          return await _json(r, 204, null);
        }
        if (chemin == '/appareil/push' && q.method == 'DELETE') {
          retraitsJetonPush++;
          return await _json(r, 204, null);
        }
        if (chemin == '/notifications') {
          return await _json(r, 200, {
            'notifications': messages,
            'nonLues': messages.where((m) => m['lue'] != true).length,
          });
        }
        if (chemin == '/notifications/lues') {
          final ids = [for (final i in corps['ids'] as List) (i as num).toInt()];
          idsLus.add(ids);
          for (final m in messages) {
            if (ids.contains(m['id'])) m['lue'] = true;
          }
          return await _json(r, 204, null);
        }
        if (q.method == 'PUT') {
          final lignes = [for (final l in corps['preferences'] as List) (l as Map).cast<String, dynamic>()];
          if (lignes.any((l) => l['canal'] == 'whatsapp' && l['actif'] == true && !whatsappDisponible)) {
            return await _json(r, 400, {
              'title': 'Données invalides',
              'status': 400,
              'code': 'champ_invalide',
              'champs': {'whatsapp': 'indisponible'},
            });
          }
          modificationsPreferences.add(lignes);
          for (final l in lignes) {
            preferences['${l['canal']}:${l['sujet']}'] = l['actif'] == true;
          }
        }
        return await _json(r, 200, _preferences(langue));
      }
      if (chemin == '/moi/suppression') {
        final brut = await utf8.decodeStream(q);
        final corps = brut.isEmpty ? const {} : jsonDecode(brut) as Map;
        suppressions.add(corps['motif'] as String?);
        return await _json(r, 202, {
          'demandeLe': _maintenant(),
          'message': 'Ta demande est enregistrée. ARC supprimera ton compte et tes données sous 30 jours.',
        });
      }
      if (chemin == '/sync/etat') return await _json(r, 200, {'genereLe': _maintenant(), 'formations': []});
      if (chemin == '/sync/evenements') return await _evenements(q);
      final manifest = RegExp(r'^/formations/(\d+)/manifest$').firstMatch(chemin);
      if (manifest != null) {
        final m = manifestes[int.parse(manifest.group(1)!)];
        if (m == null) return await _probleme(r, 404, 'introuvable');
        if (q.headers.value('if-none-match') == m['version']) return await _json(r, 304, null);
        return await _json(r, 200, m);
      }
      final fichier = RegExp(r'^/fichiers/([0-9a-f]{64})$').firstMatch(chemin);
      if (fichier != null) return await _fichier(q, fichier.group(1)!);
      return await _probleme(r, 404, 'introuvable');
    } catch (_) {
      // connexion déjà coupée volontairement
    }
  }

  /// Listes de choix (un échantillon).
  static Map<String, dynamic> referentiels(String langue, String version) {
    final en = langue == 'en';
    List<Map<String, String>> l(List<(String, String, String)> c) => [
      for (final (cle, fr, anglais) in c) {'cle': cle, 'libelle': en ? anglais : fr},
    ];
    return {
      'version': version,
      'pays': l([
        ('BJ', 'Bénin', 'Benin'),
        ('BF', 'Burkina Faso', 'Burkina Faso'),
        ('CI', "Côte d'Ivoire", "Côte d'Ivoire"),
        ('GN', 'Guinée', 'Guinea'),
        ('ML', 'Mali', 'Mali'),
        ('NE', 'Niger', 'Niger'),
        ('SN', 'Sénégal', 'Senegal'),
        ('TG', 'Togo', 'Togo'),
      ]),
      'metiers': l([
        ('infirmier', 'Infirmier(ère)', 'Nurse'),
        ('sage_femme', 'Sage-femme', 'Midwife'),
        ('pharmacien', 'Pharmacien(ne)', 'Pharmacist'),
        ('agent_communautaire', 'Agent de santé communautaire', 'Community health worker'),
      ]),
      'typesInstitution': l([
        ('centre_sante', 'Centre de santé', 'Health centre'),
        ('hopital', 'Hôpital', 'Hospital'),
        ('ministere', 'Ministère', 'Ministry'),
      ]),
      'niveaux': l([
        ('communautaire', 'Communautaire', 'Community'),
        ('district', 'District', 'District'),
        ('regional', 'Régional', 'Regional'),
        ('national', 'National', 'National'),
      ]),
      'sexes': l([
        ('femme', 'Femme', 'Woman'),
        ('homme', 'Homme', 'Man'),
        ('ne_repond_pas', 'Préfère ne pas répondre', 'Prefer not to say'),
      ]),
      'langues': l([('fr', 'Français', 'French'), ('en', 'English', 'English')]),
    };
  }

  /// Applique un PATCH comme le serveur : champs envoyés, questions répondues ou passées retirées.
  void _modifierProfil(Map<String, dynamic> m) {
    final repondus = <String>{...((m['ignorer'] as List?) ?? const []).cast<String>()};
    for (final cle in ['pays', 'metier', 'langue', 'typeInstitution', 'niveau', 'sexe', 'whatsapp']) {
      if (m.containsKey(cle)) {
        profil[cle] = m[cle];
        repondus.add(cle);
      }
    }
    if (m.containsKey('institutionId') && m['institutionId'] != null) {
      final o = organisations.firstWhere((o) => o['id'] == m['institutionId']);
      profil['institution'] = {'id': o['id'], 'nom': o['nom']};
      repondus.add('institution');
    } else if (m['institutionNom'] is String) {
      profil['institution'] = {'id': null, 'nom': m['institutionNom']};
      repondus.add('institution');
    }
    if (m.containsKey('whatsappAccord')) {
      profil['whatsappAccord'] = m['whatsappAccord'] == true;
    }
    profil['questionsAPoser'] = [
      for (final q in profil['questionsAPoser'] as List)
        if (!repondus.contains(q)) q,
    ];
    profil['obligatoires'] = [
      for (final q in profil['obligatoires'] as List)
        if (!repondus.contains(q)) q,
    ];
    final remplis = [
      'pays',
      'metier',
      'langue',
      'institution',
      'typeInstitution',
      'niveau',
    ].where((c) => profil[c] != null).length;
    profil['completude'] = (remplis * 100 / 6).round();
  }

  Map<String, dynamic> _session() {
    _numero++;
    final acces = 'acces-$_numero';
    jetonsValides.add(acces);
    jetonRafraichissement = 'rafraichir-$_numero';
    return {
      'jetonAcces': acces,
      'expireDans': 3600,
      'jetonRafraichissement': jetonRafraichissement,
      'apprenant': {
        'id': 42,
        'nom': 'Awa Diop',
        'email': 'awa@example.org',
        'roles': ['apprenant'],
        'langue': 'fr',
      },
    };
  }

  /// Fait expirer tous les jetons d'accès (le jeton de rafraîchissement reste bon).
  void expirerJetons() => jetonsValides.clear();

  Future<void> _rafraichir(HttpRequest q) async {
    final corps = jsonDecode(await utf8.decodeStream(q)) as Map;
    rafraichissements++;
    if (profilEfface) return _probleme(q.response, 401, 'profil_efface');
    if (sessionRevoquee || corps['jetonRafraichissement'] != jetonRafraichissement) {
      return _probleme(q.response, 401, 'session_revoquee');
    }
    await _json(q.response, 200, _session());
  }

  String _maintenant() => DateTime.now().toUtc().toIso8601String();

  Future<void> _evenements(HttpRequest q) async {
    var octets = <int>[];
    await for (final m in q) {
      octets.addAll(m);
    }
    if (q.headers.value('content-encoding') == 'gzip') {
      requetesGzip++;
      octets = gzip.decode(octets);
    }
    final paquet = jsonDecode(utf8.decode(octets)) as Map<String, dynamic>;
    final evenements = (paquet['evenements'] as List).cast<Map<String, dynamic>>();
    taillesPaquets.add(evenements.length);
    final resultats = <Map<String, dynamic>>[];
    for (final e in evenements) {
      final id = e['id'] as String;
      if (leconsInconnues.contains(e['leconId'])) {
        resultats.add({'id': id, 'statut': 'refuse', 'raison': 'lecon_inconnue'});
      } else if (evenementsRecus.containsKey(id)) {
        resultats.add({'id': id, 'statut': 'deja_recu'});
      } else {
        evenementsRecus[id] = e;
        resultats.add({'id': id, 'statut': 'accepte'});
      }
    }
    if (perdreProchaineReponse) {
      perdreProchaineReponse = false;
      final socket = await q.response.detachSocket(writeHeaders: false);
      socket.destroy();
      return;
    }
    await _json(q.response, 200, {
      'resultats': resultats,
      'etat': {'genereLe': _maintenant(), 'formations': []},
    });
  }

  Future<void> _fichier(HttpRequest q, String empreinte) async {
    fichiersDemandes.add(empreinte);
    final range = q.headers.value('range');
    rangesRecus.add(range);
    var contenu = fichiers[empreinte];
    if (contenu == null) return _probleme(q.response, 404, 'introuvable');
    if (servirFichierAbime) contenu = [...contenu]..[0] ^= 0xff;
    var debut = 0;
    final r = q.response;
    final m = RegExp(r'bytes=(\d+)-').firstMatch(range ?? '');
    if (m != null) {
      debut = int.parse(m.group(1)!);
      if (debut >= contenu.length) {
        r.statusCode = 416;
        return r.close();
      }
      r.statusCode = 206;
      r.headers.set('content-range', 'bytes $debut-${contenu.length - 1}/${contenu.length}');
    }
    r.headers.contentType = ContentType.binary;
    r.headers.contentLength = contenu.length - debut;
    final morceau = contenu.sublist(debut);
    final coupure = couperFichierApres;
    if (coupure != null && coupure < morceau.length) {
      couperFichierApres = null;
      // On annonce tout le fichier mais on n'en envoie qu'une partie : la connexion se ferme en cours de route.
      r.add(morceau.sublist(0, coupure));
      try {
        await r.close();
      } catch (_) {}
      return;
    }
    r.add(morceau);
    await r.close();
  }
}
