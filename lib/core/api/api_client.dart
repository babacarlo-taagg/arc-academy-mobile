import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'modeles.dart';

/// Erreur rendue par l'API au format `application/problem+json`, ou erreur réseau.
class ApiException implements Exception {
  ApiException({required this.code, this.status, this.title, this.extra = const {}});

  /// Code stable du contrat (`code_invalide`, `profil_efface`…) ou `reseau` / `inconnu`.
  final String code;
  final int? status;
  final String? title;
  final Map<String, dynamic> extra;

  bool get estReseau => code == 'reseau';

  factory ApiException.fromDio(DioException e) {
    var data = e.response?.data;
    if (data is String && data.startsWith('{')) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        // corps illisible : on garde le statut seul
      }
    }
    if (data is Map && data['code'] is String) {
      return ApiException(
        code: data['code'] as String,
        status: e.response?.statusCode,
        title: data['title'] as String?,
        extra: data.cast<String, dynamic>(),
      );
    }
    final reseau =
        e.response == null &&
        switch (e.type) {
          DioExceptionType.connectionError ||
          DioExceptionType.connectionTimeout ||
          DioExceptionType.receiveTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.unknown => true,
          _ => false,
        };
    return ApiException(code: reseau ? 'reseau' : 'inconnu', status: e.response?.statusCode);
  }

  @override
  String toString() => 'ApiException($code, $status)';
}

/// Jetons de la session d'un profil (rangés dans le coffre-fort par `ProfilStore`).
abstract class JetonsSession {
  Future<String?> jetonAcces();
  Future<String?> jetonRafraichissement();
  Future<String> appareilId();
  Future<void> enregistrer({required String acces, required String rafraichissement});
  Future<void> oublier();
}

/// Compte les octets échangés avec le serveur (affichés à l'apprenant : « données consommées »).
typedef CompteurOctets = void Function(int octets);

/// Adaptateur HTTP qui compte les octets envoyés et reçus.
class AdaptateurCompteur implements HttpClientAdapter {
  AdaptateurCompteur(this._interne, this._compter);

  final HttpClientAdapter _interne;
  final CompteurOctets _compter;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final envoye = requestStream?.map((morceau) {
      _compter(morceau.length);
      return morceau;
    });
    final reponse = await _interne.fetch(options, envoye, cancelFuture);
    // En-têtes et ligne d'état : environ 300 octets par échange.
    _compter(300);
    reponse.stream = reponse.stream.map((morceau) {
      _compter(morceau.length);
      return morceau;
    });
    return reponse;
  }

  @override
  void close({bool force = false}) => _interne.close(force: force);
}

/// Client HTTP d'un profil : jeton, renouvellement automatique de la session, effacement à distance.
class ApiClient {
  ApiClient({
    required String baseUrl,
    this.jetons,
    HttpClientAdapter? adaptateur,
    CompteurOctets? compteur,
    this.onProfilEfface,
    this.onSessionFermee,
    this.gzip = true,
    Duration delai = const Duration(seconds: 15),
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: delai,
           receiveTimeout: delai,
           sendTimeout: delai,
           contentType: 'application/json',
           headers: {'Accept-Language': 'fr'},
         ),
       ) {
    var interne = adaptateur ?? IOHttpClientAdapter();
    if (compteur != null) interne = AdaptateurCompteur(interne, compteur);
    dio.httpClientAdapter = interne;
    // Client nu, sans intercepteur, pour renouveler la session et rejouer la requête.
    _dioNu = Dio(dio.options.copyWith())..httpClientAdapter = interne;
    dio.interceptors.add(QueuedInterceptorsWrapper(onRequest: _ajouterJeton, onError: _renouvelerSiExpire));
  }

  final Dio dio;
  late final Dio _dioNu;
  final JetonsSession? jetons;

  /// `401 profil_efface` : ARC a demandé l'effacement de ce profil sur ce téléphone.
  final Future<void> Function()? onProfilEfface;

  /// Session refusée par le serveur (révoquée, expirée) : l'apprenant devra redonner un code e-mail.
  /// Les données locales restent : l'appli continue de marcher hors ligne.
  final Future<void> Function()? onSessionFermee;

  /// Corps des envois de synchronisation compressés (désactivé pour le bouchon Prism).
  final bool gzip;

  static const _routesSansJeton = ['/auth/code', '/auth/verification', '/auth/rafraichir', '/aide'];

  Future<void> _ajouterJeton(RequestOptions o, RequestInterceptorHandler h) async {
    if (!_routesSansJeton.contains(o.path) && jetons != null) {
      final jeton = await jetons!.jetonAcces();
      if (jeton != null) o.headers['Authorization'] = 'Bearer $jeton';
    }
    h.next(o);
  }

  static String? _codeErreur(Response<dynamic>? r) {
    var data = r?.data;
    if (data is String && data.startsWith('{')) {
      try {
        data = jsonDecode(data);
      } on FormatException {
        return null;
      }
    }
    return data is Map ? data['code'] as String? : null;
  }

  Future<void> _renouvelerSiExpire(DioException e, ErrorInterceptorHandler h) async {
    final requete = e.requestOptions;
    if (e.response?.statusCode != 401 || _routesSansJeton.contains(requete.path) || jetons == null) {
      return h.next(e);
    }
    if (_codeErreur(e.response) == 'profil_efface') {
      await onProfilEfface?.call();
      return h.next(e);
    }
    if (requete.extra['dejaRejouee'] == true) return h.next(e);

    // Une autre requête a déjà renouvelé la session pendant que celle-ci attendait : on la rejoue.
    final actuel = await jetons!.jetonAcces();
    final String? nouveau;
    if (actuel != null && requete.headers['Authorization'] != 'Bearer $actuel') {
      nouveau = actuel;
    } else {
      nouveau = await (_renouvellement ??= _renouveler().whenComplete(() => _renouvellement = null));
    }
    if (nouveau == null) return h.next(e);

    requete.extra['dejaRejouee'] = true;
    requete.headers['Authorization'] = 'Bearer $nouveau';
    try {
      h.resolve(await _dioNu.fetch<dynamic>(requete));
    } on DioException catch (erreurRejeu) {
      h.next(erreurRejeu);
    }
  }

  Future<String?>? _renouvellement;

  /// Renouvelle la session. Rend le nouveau jeton, ou null (session refusée, ou réseau coupé).
  Future<String?> _renouveler() async {
    final rafraichissement = await jetons!.jetonRafraichissement();
    if (rafraichissement == null) return null;
    try {
      final r = await _dioNu.post<Map<String, dynamic>>(
        '/auth/rafraichir',
        data: {'jetonRafraichissement': rafraichissement, 'appareilId': await jetons!.appareilId()},
      );
      final session = Session.fromJson(r.data!);
      await jetons!.enregistrer(acces: session.jetonAcces, rafraichissement: session.jetonRafraichissement);
      return session.jetonAcces;
    } on DioException catch (erreur) {
      if (erreur.response?.statusCode == 401) {
        if (_codeErreur(erreur.response) == 'profil_efface') {
          await onProfilEfface?.call();
        } else {
          await jetons!.oublier();
          await onSessionFermee?.call();
        }
      }
      // Simple coupure réseau : on garde la session.
      return null;
    }
  }

  Future<T> _appel<T>(Future<Response<T>> Function() appel) async {
    try {
      return (await appel()).data as T;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ───────── Routes du contrat ─────────

  Future<CodeEnvoye> demanderCode(String email) async {
    final j = await _appel(() => dio.post<Map<String, dynamic>>('/auth/code', data: {'email': email}));
    return CodeEnvoye.fromJson(j);
  }

  Future<Session> verifierCode({
    required String email,
    required String code,
    required Map<String, dynamic> appareil,
  }) async {
    final j = await _appel(
      () => dio.post<Map<String, dynamic>>(
        '/auth/verification',
        data: {'email': email, 'code': code, 'appareil': appareil},
      ),
    );
    return Session.fromJson(j);
  }

  Future<void> seDeconnecter() => _appel(() => dio.post<dynamic>('/auth/deconnexion'));

  Future<Aide> aide() async => Aide.fromJson(await _appel(() => dio.get<Map<String, dynamic>>('/aide')));

  Future<Apprenant> moi() async => Apprenant.fromJson(await _appel(() => dio.get<Map<String, dynamic>>('/moi')));

  /// Demande de suppression du compte (jamais mise en file : elle doit être confirmée par le serveur).
  Future<SuppressionEnregistree> demanderSuppression({String? motif}) async {
    final m = motif?.trim() ?? '';
    final j = await _appel(
      () => dio.post<Map<String, dynamic>>(
        '/moi/suppression',
        data: {if (m.isNotEmpty) 'motif': m.length > 500 ? m.substring(0, 500) : m},
      ),
    );
    return SuppressionEnregistree.fromJson(j);
  }

  Future<List<Formation>> formations() async {
    final j = await _appel(() => dio.get<Map<String, dynamic>>('/formations'));
    return [
      for (final f in (j['formations'] as List? ?? const [])) Formation.fromJson((f as Map).cast<String, dynamic>()),
    ];
  }

  /// Manifest du cours, ou `null` si la version locale est à jour (304).
  Future<Manifest?> manifest(int coursId, {String? versionLocale}) async {
    try {
      final r = await dio.get<Map<String, dynamic>>(
        '/formations/$coursId/manifest',
        options: Options(
          headers: {if (versionLocale != null && versionLocale.isNotEmpty) 'If-None-Match': versionLocale},
          validateStatus: (s) => s != null && (s < 300 || s == 304),
        ),
      );
      if (r.statusCode == 304 || r.data == null) return null;
      return Manifest.fromJson(r.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ResultatSynchro> envoyerEvenements(String appareilId, List<Map<String, dynamic>> evenements) async {
    final paquet = {'appareilId': appareilId, 'evenements': evenements};
    final Object donnees;
    final Map<String, dynamic> entetes;
    if (gzip) {
      final compresse = Uint8List.fromList(GZipCodec(level: 6).encode(utf8.encode(jsonEncode(paquet))));
      donnees = Stream.value(compresse);
      entetes = {'Content-Encoding': 'gzip', Headers.contentLengthHeader: compresse.length};
    } else {
      donnees = paquet;
      entetes = const {};
    }
    final j = await _appel(
      () => dio.post<Map<String, dynamic>>(
        '/sync/evenements',
        data: donnees,
        options: Options(headers: entetes),
      ),
    );
    return ResultatSynchro.fromJson(j);
  }

  Future<EtatSynchro> etat({int? coursId}) async {
    final j = await _appel(() => dio.get<Map<String, dynamic>>('/sync/etat', queryParameters: {'coursId': ?coursId}));
    return EtatSynchro.fromJson(j);
  }
}
