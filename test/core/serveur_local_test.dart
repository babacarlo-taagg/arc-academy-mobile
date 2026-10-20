import 'dart:convert';
import 'dart:io';

import 'package:arc_academy/core/api/modeles.dart';
import 'package:arc_academy/core/contenus/depot_contenus.dart';
import 'package:arc_academy/core/serveur_local/serveur_local.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory dossier;
  late DepotContenus depot;
  late ServeurLocal serveur;
  final client = HttpClient();
  final commits = <Map<String, dynamic>>[];

  final html = utf8.encode('<html><body>Article</body></html>');
  final empreinteHtml = sha256.convert(html).toString();
  const empreinteZip = 'aa11223344556677889900aabbccddeeff00112233445566778899aabbccddee';

  setUp(() async {
    dossier = Directory.systemTemp.createTempSync('arc_local_');
    depot = DepotContenus(Directory('${dossier.path}/contenus'));
    await depot.preparer();
    final f = depot.fichierObjet(empreinteHtml);
    await f.parent.create(recursive: true);
    await f.writeAsBytes(html);
    final scorm = depot.dossierScorm(empreinteZip);
    await Directory('${scorm.path}/res').create(recursive: true);
    await File('${scorm.path}/story.html').writeAsString('<p>module</p>');
    await File('${dossier.path}/secret.txt').writeAsString('secret');
    final lecons = {
      1: Lecon(
        id: 1,
        titre: 'A',
        type: TypeLecon.article,
        ordre: 1,
        horsLigne: true,
        terminee: false,
        entree: 'index.html',
        fichiers: [Fichier(chemin: 'index.html', empreinte: empreinteHtml, taille: html.length, typeMime: 'text/html')],
      ),
      2: const Lecon(
        id: 2,
        titre: 'S',
        type: TypeLecon.scorm,
        ordre: 2,
        horsLigne: true,
        terminee: false,
        entree: 'story.html',
        scormVersion: '1.2',
        fichiers: [Fichier(chemin: 'paquet.zip', empreinte: empreinteZip, taille: 1, typeMime: 'application/zip')],
      ),
    };
    serveur =
        ServeurLocal(
            depot: depot,
            lecon: (c, l) => c == 12 ? lecons[l] : null,
            scormAgain: () async => utf8.encode('/*sa*/'),
            jeton: 'jeton123',
          )
          ..surCommit = (c, l, commit) async {
            commits.add({'c': c, 'l': l, ...commit});
          }
          ..configScorm = (c, l) async => {
            'learnerId': '42',
            'saved': {
              'cmi': {'suspend_data': 'x'},
            },
          };
    await serveur.demarrer();
    commits.clear();
  });

  tearDown(() async {
    await serveur.arreter();
    dossier.deleteSync(recursive: true);
  });

  Future<(int, String)> obtenir(String url) async {
    final r = await (await client.getUrl(Uri.parse(url))).close();
    return (r.statusCode, await utf8.decodeStream(r));
  }

  test('sert un article téléchargé', () async {
    final (statut, corps) = await obtenir(serveur.urlLecon(12, 1, 'index.html'));
    expect(statut, 200);
    expect(corps, contains('Article'));
  });

  test('refuse sans le bon jeton, ou hors du dossier', () async {
    expect((await obtenir('http://127.0.0.1:${serveur.port}/autre/lecon/12/1/index.html')).$1, 404);
    expect((await obtenir('${serveur.base}/scorm/12/2/contenu/..%2F..%2F..%2Fsecret.txt')).$1, 404);
    expect((await obtenir('${serveur.base}/lecon/12/9/index.html')).$1, 404);
  });

  test('lanceur SCORM : configuration, reprise, et module servi', () async {
    final (statut, page) = await obtenir(serveur.urlScorm(12, 2));
    expect(statut, 200);
    expect(page, contains('"suspend_data":"x"'));
    expect(page, contains('/scorm/12/2/commit'));
    expect(page, contains('/outils/scorm-again.min.js'));
    expect((await obtenir('${serveur.base}/scorm/12/2/contenu/story.html')).$2, '<p>module</p>');
    expect((await obtenir('${serveur.base}/outils/scorm-again.min.js')).$2, '/*sa*/');
  });

  test('enregistrement du module transmis au profil', () async {
    final q = await client.postUrl(Uri.parse('${serveur.base}/scorm/12/2/commit'));
    q.headers.contentType = ContentType.json;
    q.write(
      jsonEncode({
        'completionStatus': 'completed',
        'score': {'raw': 90},
      }),
    );
    final r = await q.close();
    expect(jsonDecode(await utf8.decodeStream(r)), {'result': true, 'errorCode': 0});
    expect(commits.single['completionStatus'], 'completed');
    expect(commits.single['l'], 2);
  });
}
