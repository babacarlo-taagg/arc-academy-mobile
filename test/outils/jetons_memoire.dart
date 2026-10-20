import 'package:arc_academy/core/api/api_client.dart';

class JetonsMemoire implements JetonsSession {
  JetonsMemoire({this.acces = 'acces-1', this.rafraichissement = 'rafraichir-1'});

  String? acces;
  String? rafraichissement;
  bool oublie = false;

  @override
  Future<String?> jetonAcces() async => acces;
  @override
  Future<String?> jetonRafraichissement() async => rafraichissement;
  @override
  Future<String> appareilId() async => '7c9e6679-7425-40de-944b-e07fc1f90ae7';
  @override
  Future<void> enregistrer({required String acces, required String rafraichissement}) async {
    this.acces = acces;
    this.rafraichissement = rafraichissement;
  }

  @override
  Future<void> oublier() async {
    acces = null;
    rafraichissement = null;
    oublie = true;
  }
}
