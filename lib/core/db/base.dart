import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'base.g.dart';

/// Cours de l'apprenant (copie de `/formations`), pour l'affichage hors ligne.
@DataClassName('FormationLocale')
class Formations extends Table {
  IntColumn get id => integer()();
  TextColumn get titre => text()();
  TextColumn get resume => text().withDefault(const Constant(''))();
  TextColumn get cohortes => text().withDefault(const Constant('[]'))();
  TextColumn get tuteurs => text().withDefault(const Constant('[]'))();
  IntColumn get nbLecons => integer().withDefault(const Constant(0))();
  IntColumn get nbLeconsTerminees => integer().withDefault(const Constant(0))();
  IntColumn get progression => integer().withDefault(const Constant(0))();
  TextColumn get versionServeur => text().withDefault(const Constant(''))();
  IntColumn get tailleTelechargement => integer().withDefault(const Constant(0))();
  DateTimeColumn get derniereActivite => dateTime().nullable()();
  IntColumn get ordre => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Avancement de l'apprenant dans une leçon.
@DataClassName('EtatLeconLocal')
class EtatsLecons extends Table {
  IntColumn get leconId => integer()();
  IntColumn get coursId => integer()();
  BoolColumn get terminee => boolean().withDefault(const Constant(false))();
  BoolColumn get ouverte => boolean().withDefault(const Constant(false))();
  IntColumn get tempsSecondes => integer().withDefault(const Constant(0))();
  DateTimeColumn get majLe => dateTime()();

  @override
  Set<Column> get primaryKey => {leconId};
}

/// État d'un module SCORM sur le téléphone (cmi complet pour la reprise).
@DataClassName('EtatScormLigne')
class EtatsScorm extends Table {
  IntColumn get leconId => integer()();
  IntColumn get coursId => integer()();
  TextColumn get completionStatus => text().withDefault(const Constant('unknown'))();
  TextColumn get successStatus => text().withDefault(const Constant('unknown'))();
  RealColumn get scorePourcent => real().nullable()();
  IntColumn get totalTimeSeconds => integer().withDefault(const Constant(0))();
  TextColumn get cmi => text().nullable()();
  DateTimeColumn get majLe => dateTime()();

  @override
  Set<Column> get primaryKey => {leconId};
}

/// File d'attente des événements à envoyer au serveur. Une ligne n'est supprimée qu'après la réponse du serveur.
@DataClassName('EvenementLocal')
class Evenements extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get coursId => integer()();
  IntColumn get leconId => integer()();
  DateTimeColumn get survenuLe => dateTime()();
  TextColumn get donnees => text().withDefault(const Constant('{}'))();
  IntColumn get rang => integer().autoIncrement()();
  IntColumn get essais => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {id},
  ];
}

/// Événements refusés définitivement par le serveur : gardés pour comprendre, jamais renvoyés.
@DataClassName('EvenementRefuse')
class EvenementsRefuses extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get raison => text().withDefault(const Constant(''))();
  TextColumn get donnees => text().withDefault(const Constant('{}'))();
  DateTimeColumn get refuseLe => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MetaLigne')
class Meta extends Table {
  TextColumn get cle => text()();
  TextColumn get valeur => text()();

  @override
  Set<Column> get primaryKey => {cle};
}

@DriftDatabase(tables: [Formations, EtatsLecons, EtatsScorm, Evenements, EvenementsRefuses, Meta])
class BaseProfil extends _$BaseProfil {
  BaseProfil(super.e);

  /// Ouvre (ou crée) la base chiffrée d'un profil. `cleHex` : 64 caractères hexadécimaux.
  ///
  /// Le chiffrement vient de SQLite3MultipleCiphers (voir `hooks` dans pubspec.yaml).
  factory BaseProfil.ouvrir(File fichier, String cleHex, {bool enArrierePlan = true}) {
    void preparer(dynamic db) {
      db.execute("PRAGMA hexkey = '$cleHex';");
      // Échoue tout de suite si la clé est mauvaise (« file is not a database »).
      db.execute('SELECT count(*) FROM sqlite_master;');
      // Écritures sûres même si la batterie lâche : journal WAL et écriture complète sur le disque.
      db.execute('PRAGMA journal_mode = WAL;');
      db.execute('PRAGMA synchronous = FULL;');
    }

    final executor = enArrierePlan
        ? NativeDatabase.createInBackground(fichier, setup: preparer)
        : NativeDatabase(fichier, setup: preparer);
    return BaseProfil(executor);
  }

  @override
  int get schemaVersion => 1;

  Future<String?> lireMeta(String cle) async =>
      (await (select(meta)..where((m) => m.cle.equals(cle))).getSingleOrNull())?.valeur;

  Future<void> ecrireMeta(String cle, String valeur) =>
      into(meta).insertOnConflictUpdate(MetaCompanion.insert(cle: cle, valeur: valeur));

  /// Nombre d'événements en attente d'envoi (pour l'indicateur « 3 éléments en attente »).
  Stream<int> surveillerEnAttente() {
    final n = evenements.id.count();
    return (selectOnly(evenements)..addColumns([n])).map((r) => r.read(n) ?? 0).watchSingle();
  }

  Future<int> compterEnAttente() async {
    final n = evenements.id.count();
    return (await (selectOnly(evenements)..addColumns([n])).getSingle()).read(n) ?? 0;
  }
}
