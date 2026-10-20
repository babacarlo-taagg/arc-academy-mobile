// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// ignore_for_file: type=lint
class $FormationsTable extends Formations with TableInfo<$FormationsTable, FormationLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titreMeta = const VerificationMeta('titre');
  @override
  late final GeneratedColumn<String> titre = GeneratedColumn<String>(
    'titre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resumeMeta = const VerificationMeta('resume');
  @override
  late final GeneratedColumn<String> resume = GeneratedColumn<String>(
    'resume',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _cohortesMeta = const VerificationMeta('cohortes');
  @override
  late final GeneratedColumn<String> cohortes = GeneratedColumn<String>(
    'cohortes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _tuteursMeta = const VerificationMeta('tuteurs');
  @override
  late final GeneratedColumn<String> tuteurs = GeneratedColumn<String>(
    'tuteurs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _nbLeconsMeta = const VerificationMeta('nbLecons');
  @override
  late final GeneratedColumn<int> nbLecons = GeneratedColumn<int>(
    'nb_lecons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nbLeconsTermineesMeta = const VerificationMeta('nbLeconsTerminees');
  @override
  late final GeneratedColumn<int> nbLeconsTerminees = GeneratedColumn<int>(
    'nb_lecons_terminees',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressionMeta = const VerificationMeta('progression');
  @override
  late final GeneratedColumn<int> progression = GeneratedColumn<int>(
    'progression',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _versionServeurMeta = const VerificationMeta('versionServeur');
  @override
  late final GeneratedColumn<String> versionServeur = GeneratedColumn<String>(
    'version_serveur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tailleTelechargementMeta = const VerificationMeta('tailleTelechargement');
  @override
  late final GeneratedColumn<int> tailleTelechargement = GeneratedColumn<int>(
    'taille_telechargement',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _derniereActiviteMeta = const VerificationMeta('derniereActivite');
  @override
  late final GeneratedColumn<DateTime> derniereActivite = GeneratedColumn<DateTime>(
    'derniere_activite',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titre,
    resume,
    cohortes,
    tuteurs,
    nbLecons,
    nbLeconsTerminees,
    progression,
    versionServeur,
    tailleTelechargement,
    derniereActivite,
    ordre,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'formations';
  @override
  VerificationContext validateIntegrity(Insertable<FormationLocale> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titre')) {
      context.handle(_titreMeta, titre.isAcceptableOrUnknown(data['titre']!, _titreMeta));
    } else if (isInserting) {
      context.missing(_titreMeta);
    }
    if (data.containsKey('resume')) {
      context.handle(_resumeMeta, resume.isAcceptableOrUnknown(data['resume']!, _resumeMeta));
    }
    if (data.containsKey('cohortes')) {
      context.handle(_cohortesMeta, cohortes.isAcceptableOrUnknown(data['cohortes']!, _cohortesMeta));
    }
    if (data.containsKey('tuteurs')) {
      context.handle(_tuteursMeta, tuteurs.isAcceptableOrUnknown(data['tuteurs']!, _tuteursMeta));
    }
    if (data.containsKey('nb_lecons')) {
      context.handle(_nbLeconsMeta, nbLecons.isAcceptableOrUnknown(data['nb_lecons']!, _nbLeconsMeta));
    }
    if (data.containsKey('nb_lecons_terminees')) {
      context.handle(
        _nbLeconsTermineesMeta,
        nbLeconsTerminees.isAcceptableOrUnknown(data['nb_lecons_terminees']!, _nbLeconsTermineesMeta),
      );
    }
    if (data.containsKey('progression')) {
      context.handle(_progressionMeta, progression.isAcceptableOrUnknown(data['progression']!, _progressionMeta));
    }
    if (data.containsKey('version_serveur')) {
      context.handle(
        _versionServeurMeta,
        versionServeur.isAcceptableOrUnknown(data['version_serveur']!, _versionServeurMeta),
      );
    }
    if (data.containsKey('taille_telechargement')) {
      context.handle(
        _tailleTelechargementMeta,
        tailleTelechargement.isAcceptableOrUnknown(data['taille_telechargement']!, _tailleTelechargementMeta),
      );
    }
    if (data.containsKey('derniere_activite')) {
      context.handle(
        _derniereActiviteMeta,
        derniereActivite.isAcceptableOrUnknown(data['derniere_activite']!, _derniereActiviteMeta),
      );
    }
    if (data.containsKey('ordre')) {
      context.handle(_ordreMeta, ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FormationLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormationLocale(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      titre: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}titre'])!,
      resume: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}resume'])!,
      cohortes: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cohortes'])!,
      tuteurs: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}tuteurs'])!,
      nbLecons: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}nb_lecons'])!,
      nbLeconsTerminees: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nb_lecons_terminees'],
      )!,
      progression: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}progression'])!,
      versionServeur: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_serveur'],
      )!,
      tailleTelechargement: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}taille_telechargement'],
      )!,
      derniereActivite: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}derniere_activite'],
      ),
      ordre: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}ordre'])!,
    );
  }

  @override
  $FormationsTable createAlias(String alias) {
    return $FormationsTable(attachedDatabase, alias);
  }
}

class FormationLocale extends DataClass implements Insertable<FormationLocale> {
  final int id;
  final String titre;
  final String resume;
  final String cohortes;
  final String tuteurs;
  final int nbLecons;
  final int nbLeconsTerminees;
  final int progression;
  final String versionServeur;
  final int tailleTelechargement;
  final DateTime? derniereActivite;
  final int ordre;
  const FormationLocale({
    required this.id,
    required this.titre,
    required this.resume,
    required this.cohortes,
    required this.tuteurs,
    required this.nbLecons,
    required this.nbLeconsTerminees,
    required this.progression,
    required this.versionServeur,
    required this.tailleTelechargement,
    this.derniereActivite,
    required this.ordre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titre'] = Variable<String>(titre);
    map['resume'] = Variable<String>(resume);
    map['cohortes'] = Variable<String>(cohortes);
    map['tuteurs'] = Variable<String>(tuteurs);
    map['nb_lecons'] = Variable<int>(nbLecons);
    map['nb_lecons_terminees'] = Variable<int>(nbLeconsTerminees);
    map['progression'] = Variable<int>(progression);
    map['version_serveur'] = Variable<String>(versionServeur);
    map['taille_telechargement'] = Variable<int>(tailleTelechargement);
    if (!nullToAbsent || derniereActivite != null) {
      map['derniere_activite'] = Variable<DateTime>(derniereActivite);
    }
    map['ordre'] = Variable<int>(ordre);
    return map;
  }

  FormationsCompanion toCompanion(bool nullToAbsent) {
    return FormationsCompanion(
      id: Value(id),
      titre: Value(titre),
      resume: Value(resume),
      cohortes: Value(cohortes),
      tuteurs: Value(tuteurs),
      nbLecons: Value(nbLecons),
      nbLeconsTerminees: Value(nbLeconsTerminees),
      progression: Value(progression),
      versionServeur: Value(versionServeur),
      tailleTelechargement: Value(tailleTelechargement),
      derniereActivite: derniereActivite == null && nullToAbsent ? const Value.absent() : Value(derniereActivite),
      ordre: Value(ordre),
    );
  }

  factory FormationLocale.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormationLocale(
      id: serializer.fromJson<int>(json['id']),
      titre: serializer.fromJson<String>(json['titre']),
      resume: serializer.fromJson<String>(json['resume']),
      cohortes: serializer.fromJson<String>(json['cohortes']),
      tuteurs: serializer.fromJson<String>(json['tuteurs']),
      nbLecons: serializer.fromJson<int>(json['nbLecons']),
      nbLeconsTerminees: serializer.fromJson<int>(json['nbLeconsTerminees']),
      progression: serializer.fromJson<int>(json['progression']),
      versionServeur: serializer.fromJson<String>(json['versionServeur']),
      tailleTelechargement: serializer.fromJson<int>(json['tailleTelechargement']),
      derniereActivite: serializer.fromJson<DateTime?>(json['derniereActivite']),
      ordre: serializer.fromJson<int>(json['ordre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titre': serializer.toJson<String>(titre),
      'resume': serializer.toJson<String>(resume),
      'cohortes': serializer.toJson<String>(cohortes),
      'tuteurs': serializer.toJson<String>(tuteurs),
      'nbLecons': serializer.toJson<int>(nbLecons),
      'nbLeconsTerminees': serializer.toJson<int>(nbLeconsTerminees),
      'progression': serializer.toJson<int>(progression),
      'versionServeur': serializer.toJson<String>(versionServeur),
      'tailleTelechargement': serializer.toJson<int>(tailleTelechargement),
      'derniereActivite': serializer.toJson<DateTime?>(derniereActivite),
      'ordre': serializer.toJson<int>(ordre),
    };
  }

  FormationLocale copyWith({
    int? id,
    String? titre,
    String? resume,
    String? cohortes,
    String? tuteurs,
    int? nbLecons,
    int? nbLeconsTerminees,
    int? progression,
    String? versionServeur,
    int? tailleTelechargement,
    Value<DateTime?> derniereActivite = const Value.absent(),
    int? ordre,
  }) => FormationLocale(
    id: id ?? this.id,
    titre: titre ?? this.titre,
    resume: resume ?? this.resume,
    cohortes: cohortes ?? this.cohortes,
    tuteurs: tuteurs ?? this.tuteurs,
    nbLecons: nbLecons ?? this.nbLecons,
    nbLeconsTerminees: nbLeconsTerminees ?? this.nbLeconsTerminees,
    progression: progression ?? this.progression,
    versionServeur: versionServeur ?? this.versionServeur,
    tailleTelechargement: tailleTelechargement ?? this.tailleTelechargement,
    derniereActivite: derniereActivite.present ? derniereActivite.value : this.derniereActivite,
    ordre: ordre ?? this.ordre,
  );
  FormationLocale copyWithCompanion(FormationsCompanion data) {
    return FormationLocale(
      id: data.id.present ? data.id.value : this.id,
      titre: data.titre.present ? data.titre.value : this.titre,
      resume: data.resume.present ? data.resume.value : this.resume,
      cohortes: data.cohortes.present ? data.cohortes.value : this.cohortes,
      tuteurs: data.tuteurs.present ? data.tuteurs.value : this.tuteurs,
      nbLecons: data.nbLecons.present ? data.nbLecons.value : this.nbLecons,
      nbLeconsTerminees: data.nbLeconsTerminees.present ? data.nbLeconsTerminees.value : this.nbLeconsTerminees,
      progression: data.progression.present ? data.progression.value : this.progression,
      versionServeur: data.versionServeur.present ? data.versionServeur.value : this.versionServeur,
      tailleTelechargement: data.tailleTelechargement.present
          ? data.tailleTelechargement.value
          : this.tailleTelechargement,
      derniereActivite: data.derniereActivite.present ? data.derniereActivite.value : this.derniereActivite,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormationLocale(')
          ..write('id: $id, ')
          ..write('titre: $titre, ')
          ..write('resume: $resume, ')
          ..write('cohortes: $cohortes, ')
          ..write('tuteurs: $tuteurs, ')
          ..write('nbLecons: $nbLecons, ')
          ..write('nbLeconsTerminees: $nbLeconsTerminees, ')
          ..write('progression: $progression, ')
          ..write('versionServeur: $versionServeur, ')
          ..write('tailleTelechargement: $tailleTelechargement, ')
          ..write('derniereActivite: $derniereActivite, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titre,
    resume,
    cohortes,
    tuteurs,
    nbLecons,
    nbLeconsTerminees,
    progression,
    versionServeur,
    tailleTelechargement,
    derniereActivite,
    ordre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormationLocale &&
          other.id == this.id &&
          other.titre == this.titre &&
          other.resume == this.resume &&
          other.cohortes == this.cohortes &&
          other.tuteurs == this.tuteurs &&
          other.nbLecons == this.nbLecons &&
          other.nbLeconsTerminees == this.nbLeconsTerminees &&
          other.progression == this.progression &&
          other.versionServeur == this.versionServeur &&
          other.tailleTelechargement == this.tailleTelechargement &&
          other.derniereActivite == this.derniereActivite &&
          other.ordre == this.ordre);
}

class FormationsCompanion extends UpdateCompanion<FormationLocale> {
  final Value<int> id;
  final Value<String> titre;
  final Value<String> resume;
  final Value<String> cohortes;
  final Value<String> tuteurs;
  final Value<int> nbLecons;
  final Value<int> nbLeconsTerminees;
  final Value<int> progression;
  final Value<String> versionServeur;
  final Value<int> tailleTelechargement;
  final Value<DateTime?> derniereActivite;
  final Value<int> ordre;
  const FormationsCompanion({
    this.id = const Value.absent(),
    this.titre = const Value.absent(),
    this.resume = const Value.absent(),
    this.cohortes = const Value.absent(),
    this.tuteurs = const Value.absent(),
    this.nbLecons = const Value.absent(),
    this.nbLeconsTerminees = const Value.absent(),
    this.progression = const Value.absent(),
    this.versionServeur = const Value.absent(),
    this.tailleTelechargement = const Value.absent(),
    this.derniereActivite = const Value.absent(),
    this.ordre = const Value.absent(),
  });
  FormationsCompanion.insert({
    this.id = const Value.absent(),
    required String titre,
    this.resume = const Value.absent(),
    this.cohortes = const Value.absent(),
    this.tuteurs = const Value.absent(),
    this.nbLecons = const Value.absent(),
    this.nbLeconsTerminees = const Value.absent(),
    this.progression = const Value.absent(),
    this.versionServeur = const Value.absent(),
    this.tailleTelechargement = const Value.absent(),
    this.derniereActivite = const Value.absent(),
    this.ordre = const Value.absent(),
  }) : titre = Value(titre);
  static Insertable<FormationLocale> custom({
    Expression<int>? id,
    Expression<String>? titre,
    Expression<String>? resume,
    Expression<String>? cohortes,
    Expression<String>? tuteurs,
    Expression<int>? nbLecons,
    Expression<int>? nbLeconsTerminees,
    Expression<int>? progression,
    Expression<String>? versionServeur,
    Expression<int>? tailleTelechargement,
    Expression<DateTime>? derniereActivite,
    Expression<int>? ordre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titre != null) 'titre': titre,
      if (resume != null) 'resume': resume,
      if (cohortes != null) 'cohortes': cohortes,
      if (tuteurs != null) 'tuteurs': tuteurs,
      if (nbLecons != null) 'nb_lecons': nbLecons,
      if (nbLeconsTerminees != null) 'nb_lecons_terminees': nbLeconsTerminees,
      if (progression != null) 'progression': progression,
      if (versionServeur != null) 'version_serveur': versionServeur,
      if (tailleTelechargement != null) 'taille_telechargement': tailleTelechargement,
      if (derniereActivite != null) 'derniere_activite': derniereActivite,
      if (ordre != null) 'ordre': ordre,
    });
  }

  FormationsCompanion copyWith({
    Value<int>? id,
    Value<String>? titre,
    Value<String>? resume,
    Value<String>? cohortes,
    Value<String>? tuteurs,
    Value<int>? nbLecons,
    Value<int>? nbLeconsTerminees,
    Value<int>? progression,
    Value<String>? versionServeur,
    Value<int>? tailleTelechargement,
    Value<DateTime?>? derniereActivite,
    Value<int>? ordre,
  }) {
    return FormationsCompanion(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      resume: resume ?? this.resume,
      cohortes: cohortes ?? this.cohortes,
      tuteurs: tuteurs ?? this.tuteurs,
      nbLecons: nbLecons ?? this.nbLecons,
      nbLeconsTerminees: nbLeconsTerminees ?? this.nbLeconsTerminees,
      progression: progression ?? this.progression,
      versionServeur: versionServeur ?? this.versionServeur,
      tailleTelechargement: tailleTelechargement ?? this.tailleTelechargement,
      derniereActivite: derniereActivite ?? this.derniereActivite,
      ordre: ordre ?? this.ordre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titre.present) {
      map['titre'] = Variable<String>(titre.value);
    }
    if (resume.present) {
      map['resume'] = Variable<String>(resume.value);
    }
    if (cohortes.present) {
      map['cohortes'] = Variable<String>(cohortes.value);
    }
    if (tuteurs.present) {
      map['tuteurs'] = Variable<String>(tuteurs.value);
    }
    if (nbLecons.present) {
      map['nb_lecons'] = Variable<int>(nbLecons.value);
    }
    if (nbLeconsTerminees.present) {
      map['nb_lecons_terminees'] = Variable<int>(nbLeconsTerminees.value);
    }
    if (progression.present) {
      map['progression'] = Variable<int>(progression.value);
    }
    if (versionServeur.present) {
      map['version_serveur'] = Variable<String>(versionServeur.value);
    }
    if (tailleTelechargement.present) {
      map['taille_telechargement'] = Variable<int>(tailleTelechargement.value);
    }
    if (derniereActivite.present) {
      map['derniere_activite'] = Variable<DateTime>(derniereActivite.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormationsCompanion(')
          ..write('id: $id, ')
          ..write('titre: $titre, ')
          ..write('resume: $resume, ')
          ..write('cohortes: $cohortes, ')
          ..write('tuteurs: $tuteurs, ')
          ..write('nbLecons: $nbLecons, ')
          ..write('nbLeconsTerminees: $nbLeconsTerminees, ')
          ..write('progression: $progression, ')
          ..write('versionServeur: $versionServeur, ')
          ..write('tailleTelechargement: $tailleTelechargement, ')
          ..write('derniereActivite: $derniereActivite, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }
}

class $EtatsLeconsTable extends EtatsLecons with TableInfo<$EtatsLeconsTable, EtatLeconLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtatsLeconsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _leconIdMeta = const VerificationMeta('leconId');
  @override
  late final GeneratedColumn<int> leconId = GeneratedColumn<int>(
    'lecon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coursIdMeta = const VerificationMeta('coursId');
  @override
  late final GeneratedColumn<int> coursId = GeneratedColumn<int>(
    'cours_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termineeMeta = const VerificationMeta('terminee');
  @override
  late final GeneratedColumn<bool> terminee = GeneratedColumn<bool>(
    'terminee',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("terminee" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ouverteMeta = const VerificationMeta('ouverte');
  @override
  late final GeneratedColumn<bool> ouverte = GeneratedColumn<bool>(
    'ouverte',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("ouverte" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tempsSecondesMeta = const VerificationMeta('tempsSecondes');
  @override
  late final GeneratedColumn<int> tempsSecondes = GeneratedColumn<int>(
    'temps_secondes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [leconId, coursId, terminee, ouverte, tempsSecondes, majLe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etats_lecons';
  @override
  VerificationContext validateIntegrity(Insertable<EtatLeconLocal> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lecon_id')) {
      context.handle(_leconIdMeta, leconId.isAcceptableOrUnknown(data['lecon_id']!, _leconIdMeta));
    }
    if (data.containsKey('cours_id')) {
      context.handle(_coursIdMeta, coursId.isAcceptableOrUnknown(data['cours_id']!, _coursIdMeta));
    } else if (isInserting) {
      context.missing(_coursIdMeta);
    }
    if (data.containsKey('terminee')) {
      context.handle(_termineeMeta, terminee.isAcceptableOrUnknown(data['terminee']!, _termineeMeta));
    }
    if (data.containsKey('ouverte')) {
      context.handle(_ouverteMeta, ouverte.isAcceptableOrUnknown(data['ouverte']!, _ouverteMeta));
    }
    if (data.containsKey('temps_secondes')) {
      context.handle(
        _tempsSecondesMeta,
        tempsSecondes.isAcceptableOrUnknown(data['temps_secondes']!, _tempsSecondesMeta),
      );
    }
    if (data.containsKey('maj_le')) {
      context.handle(_majLeMeta, majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta));
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {leconId};
  @override
  EtatLeconLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EtatLeconLocal(
      leconId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}lecon_id'])!,
      coursId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cours_id'])!,
      terminee: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}terminee'])!,
      ouverte: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}ouverte'])!,
      tempsSecondes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}temps_secondes'])!,
      majLe: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}maj_le'])!,
    );
  }

  @override
  $EtatsLeconsTable createAlias(String alias) {
    return $EtatsLeconsTable(attachedDatabase, alias);
  }
}

class EtatLeconLocal extends DataClass implements Insertable<EtatLeconLocal> {
  final int leconId;
  final int coursId;
  final bool terminee;
  final bool ouverte;
  final int tempsSecondes;
  final DateTime majLe;
  const EtatLeconLocal({
    required this.leconId,
    required this.coursId,
    required this.terminee,
    required this.ouverte,
    required this.tempsSecondes,
    required this.majLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lecon_id'] = Variable<int>(leconId);
    map['cours_id'] = Variable<int>(coursId);
    map['terminee'] = Variable<bool>(terminee);
    map['ouverte'] = Variable<bool>(ouverte);
    map['temps_secondes'] = Variable<int>(tempsSecondes);
    map['maj_le'] = Variable<DateTime>(majLe);
    return map;
  }

  EtatsLeconsCompanion toCompanion(bool nullToAbsent) {
    return EtatsLeconsCompanion(
      leconId: Value(leconId),
      coursId: Value(coursId),
      terminee: Value(terminee),
      ouverte: Value(ouverte),
      tempsSecondes: Value(tempsSecondes),
      majLe: Value(majLe),
    );
  }

  factory EtatLeconLocal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EtatLeconLocal(
      leconId: serializer.fromJson<int>(json['leconId']),
      coursId: serializer.fromJson<int>(json['coursId']),
      terminee: serializer.fromJson<bool>(json['terminee']),
      ouverte: serializer.fromJson<bool>(json['ouverte']),
      tempsSecondes: serializer.fromJson<int>(json['tempsSecondes']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'leconId': serializer.toJson<int>(leconId),
      'coursId': serializer.toJson<int>(coursId),
      'terminee': serializer.toJson<bool>(terminee),
      'ouverte': serializer.toJson<bool>(ouverte),
      'tempsSecondes': serializer.toJson<int>(tempsSecondes),
      'majLe': serializer.toJson<DateTime>(majLe),
    };
  }

  EtatLeconLocal copyWith({
    int? leconId,
    int? coursId,
    bool? terminee,
    bool? ouverte,
    int? tempsSecondes,
    DateTime? majLe,
  }) => EtatLeconLocal(
    leconId: leconId ?? this.leconId,
    coursId: coursId ?? this.coursId,
    terminee: terminee ?? this.terminee,
    ouverte: ouverte ?? this.ouverte,
    tempsSecondes: tempsSecondes ?? this.tempsSecondes,
    majLe: majLe ?? this.majLe,
  );
  EtatLeconLocal copyWithCompanion(EtatsLeconsCompanion data) {
    return EtatLeconLocal(
      leconId: data.leconId.present ? data.leconId.value : this.leconId,
      coursId: data.coursId.present ? data.coursId.value : this.coursId,
      terminee: data.terminee.present ? data.terminee.value : this.terminee,
      ouverte: data.ouverte.present ? data.ouverte.value : this.ouverte,
      tempsSecondes: data.tempsSecondes.present ? data.tempsSecondes.value : this.tempsSecondes,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EtatLeconLocal(')
          ..write('leconId: $leconId, ')
          ..write('coursId: $coursId, ')
          ..write('terminee: $terminee, ')
          ..write('ouverte: $ouverte, ')
          ..write('tempsSecondes: $tempsSecondes, ')
          ..write('majLe: $majLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(leconId, coursId, terminee, ouverte, tempsSecondes, majLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EtatLeconLocal &&
          other.leconId == this.leconId &&
          other.coursId == this.coursId &&
          other.terminee == this.terminee &&
          other.ouverte == this.ouverte &&
          other.tempsSecondes == this.tempsSecondes &&
          other.majLe == this.majLe);
}

class EtatsLeconsCompanion extends UpdateCompanion<EtatLeconLocal> {
  final Value<int> leconId;
  final Value<int> coursId;
  final Value<bool> terminee;
  final Value<bool> ouverte;
  final Value<int> tempsSecondes;
  final Value<DateTime> majLe;
  const EtatsLeconsCompanion({
    this.leconId = const Value.absent(),
    this.coursId = const Value.absent(),
    this.terminee = const Value.absent(),
    this.ouverte = const Value.absent(),
    this.tempsSecondes = const Value.absent(),
    this.majLe = const Value.absent(),
  });
  EtatsLeconsCompanion.insert({
    this.leconId = const Value.absent(),
    required int coursId,
    this.terminee = const Value.absent(),
    this.ouverte = const Value.absent(),
    this.tempsSecondes = const Value.absent(),
    required DateTime majLe,
  }) : coursId = Value(coursId),
       majLe = Value(majLe);
  static Insertable<EtatLeconLocal> custom({
    Expression<int>? leconId,
    Expression<int>? coursId,
    Expression<bool>? terminee,
    Expression<bool>? ouverte,
    Expression<int>? tempsSecondes,
    Expression<DateTime>? majLe,
  }) {
    return RawValuesInsertable({
      if (leconId != null) 'lecon_id': leconId,
      if (coursId != null) 'cours_id': coursId,
      if (terminee != null) 'terminee': terminee,
      if (ouverte != null) 'ouverte': ouverte,
      if (tempsSecondes != null) 'temps_secondes': tempsSecondes,
      if (majLe != null) 'maj_le': majLe,
    });
  }

  EtatsLeconsCompanion copyWith({
    Value<int>? leconId,
    Value<int>? coursId,
    Value<bool>? terminee,
    Value<bool>? ouverte,
    Value<int>? tempsSecondes,
    Value<DateTime>? majLe,
  }) {
    return EtatsLeconsCompanion(
      leconId: leconId ?? this.leconId,
      coursId: coursId ?? this.coursId,
      terminee: terminee ?? this.terminee,
      ouverte: ouverte ?? this.ouverte,
      tempsSecondes: tempsSecondes ?? this.tempsSecondes,
      majLe: majLe ?? this.majLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (leconId.present) {
      map['lecon_id'] = Variable<int>(leconId.value);
    }
    if (coursId.present) {
      map['cours_id'] = Variable<int>(coursId.value);
    }
    if (terminee.present) {
      map['terminee'] = Variable<bool>(terminee.value);
    }
    if (ouverte.present) {
      map['ouverte'] = Variable<bool>(ouverte.value);
    }
    if (tempsSecondes.present) {
      map['temps_secondes'] = Variable<int>(tempsSecondes.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtatsLeconsCompanion(')
          ..write('leconId: $leconId, ')
          ..write('coursId: $coursId, ')
          ..write('terminee: $terminee, ')
          ..write('ouverte: $ouverte, ')
          ..write('tempsSecondes: $tempsSecondes, ')
          ..write('majLe: $majLe')
          ..write(')'))
        .toString();
  }
}

class $EtatsScormTable extends EtatsScorm with TableInfo<$EtatsScormTable, EtatScormLigne> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EtatsScormTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _leconIdMeta = const VerificationMeta('leconId');
  @override
  late final GeneratedColumn<int> leconId = GeneratedColumn<int>(
    'lecon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coursIdMeta = const VerificationMeta('coursId');
  @override
  late final GeneratedColumn<int> coursId = GeneratedColumn<int>(
    'cours_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionStatusMeta = const VerificationMeta('completionStatus');
  @override
  late final GeneratedColumn<String> completionStatus = GeneratedColumn<String>(
    'completion_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _successStatusMeta = const VerificationMeta('successStatus');
  @override
  late final GeneratedColumn<String> successStatus = GeneratedColumn<String>(
    'success_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _scorePourcentMeta = const VerificationMeta('scorePourcent');
  @override
  late final GeneratedColumn<double> scorePourcent = GeneratedColumn<double>(
    'score_pourcent',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTimeSecondsMeta = const VerificationMeta('totalTimeSeconds');
  @override
  late final GeneratedColumn<int> totalTimeSeconds = GeneratedColumn<int>(
    'total_time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cmiMeta = const VerificationMeta('cmi');
  @override
  late final GeneratedColumn<String> cmi = GeneratedColumn<String>(
    'cmi',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    leconId,
    coursId,
    completionStatus,
    successStatus,
    scorePourcent,
    totalTimeSeconds,
    cmi,
    majLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'etats_scorm';
  @override
  VerificationContext validateIntegrity(Insertable<EtatScormLigne> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lecon_id')) {
      context.handle(_leconIdMeta, leconId.isAcceptableOrUnknown(data['lecon_id']!, _leconIdMeta));
    }
    if (data.containsKey('cours_id')) {
      context.handle(_coursIdMeta, coursId.isAcceptableOrUnknown(data['cours_id']!, _coursIdMeta));
    } else if (isInserting) {
      context.missing(_coursIdMeta);
    }
    if (data.containsKey('completion_status')) {
      context.handle(
        _completionStatusMeta,
        completionStatus.isAcceptableOrUnknown(data['completion_status']!, _completionStatusMeta),
      );
    }
    if (data.containsKey('success_status')) {
      context.handle(
        _successStatusMeta,
        successStatus.isAcceptableOrUnknown(data['success_status']!, _successStatusMeta),
      );
    }
    if (data.containsKey('score_pourcent')) {
      context.handle(
        _scorePourcentMeta,
        scorePourcent.isAcceptableOrUnknown(data['score_pourcent']!, _scorePourcentMeta),
      );
    }
    if (data.containsKey('total_time_seconds')) {
      context.handle(
        _totalTimeSecondsMeta,
        totalTimeSeconds.isAcceptableOrUnknown(data['total_time_seconds']!, _totalTimeSecondsMeta),
      );
    }
    if (data.containsKey('cmi')) {
      context.handle(_cmiMeta, cmi.isAcceptableOrUnknown(data['cmi']!, _cmiMeta));
    }
    if (data.containsKey('maj_le')) {
      context.handle(_majLeMeta, majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta));
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {leconId};
  @override
  EtatScormLigne map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EtatScormLigne(
      leconId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}lecon_id'])!,
      coursId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cours_id'])!,
      completionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_status'],
      )!,
      successStatus: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}success_status'])!,
      scorePourcent: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}score_pourcent']),
      totalTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_time_seconds'],
      )!,
      cmi: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cmi']),
      majLe: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}maj_le'])!,
    );
  }

  @override
  $EtatsScormTable createAlias(String alias) {
    return $EtatsScormTable(attachedDatabase, alias);
  }
}

class EtatScormLigne extends DataClass implements Insertable<EtatScormLigne> {
  final int leconId;
  final int coursId;
  final String completionStatus;
  final String successStatus;
  final double? scorePourcent;
  final int totalTimeSeconds;
  final String? cmi;
  final DateTime majLe;
  const EtatScormLigne({
    required this.leconId,
    required this.coursId,
    required this.completionStatus,
    required this.successStatus,
    this.scorePourcent,
    required this.totalTimeSeconds,
    this.cmi,
    required this.majLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lecon_id'] = Variable<int>(leconId);
    map['cours_id'] = Variable<int>(coursId);
    map['completion_status'] = Variable<String>(completionStatus);
    map['success_status'] = Variable<String>(successStatus);
    if (!nullToAbsent || scorePourcent != null) {
      map['score_pourcent'] = Variable<double>(scorePourcent);
    }
    map['total_time_seconds'] = Variable<int>(totalTimeSeconds);
    if (!nullToAbsent || cmi != null) {
      map['cmi'] = Variable<String>(cmi);
    }
    map['maj_le'] = Variable<DateTime>(majLe);
    return map;
  }

  EtatsScormCompanion toCompanion(bool nullToAbsent) {
    return EtatsScormCompanion(
      leconId: Value(leconId),
      coursId: Value(coursId),
      completionStatus: Value(completionStatus),
      successStatus: Value(successStatus),
      scorePourcent: scorePourcent == null && nullToAbsent ? const Value.absent() : Value(scorePourcent),
      totalTimeSeconds: Value(totalTimeSeconds),
      cmi: cmi == null && nullToAbsent ? const Value.absent() : Value(cmi),
      majLe: Value(majLe),
    );
  }

  factory EtatScormLigne.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EtatScormLigne(
      leconId: serializer.fromJson<int>(json['leconId']),
      coursId: serializer.fromJson<int>(json['coursId']),
      completionStatus: serializer.fromJson<String>(json['completionStatus']),
      successStatus: serializer.fromJson<String>(json['successStatus']),
      scorePourcent: serializer.fromJson<double?>(json['scorePourcent']),
      totalTimeSeconds: serializer.fromJson<int>(json['totalTimeSeconds']),
      cmi: serializer.fromJson<String?>(json['cmi']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'leconId': serializer.toJson<int>(leconId),
      'coursId': serializer.toJson<int>(coursId),
      'completionStatus': serializer.toJson<String>(completionStatus),
      'successStatus': serializer.toJson<String>(successStatus),
      'scorePourcent': serializer.toJson<double?>(scorePourcent),
      'totalTimeSeconds': serializer.toJson<int>(totalTimeSeconds),
      'cmi': serializer.toJson<String?>(cmi),
      'majLe': serializer.toJson<DateTime>(majLe),
    };
  }

  EtatScormLigne copyWith({
    int? leconId,
    int? coursId,
    String? completionStatus,
    String? successStatus,
    Value<double?> scorePourcent = const Value.absent(),
    int? totalTimeSeconds,
    Value<String?> cmi = const Value.absent(),
    DateTime? majLe,
  }) => EtatScormLigne(
    leconId: leconId ?? this.leconId,
    coursId: coursId ?? this.coursId,
    completionStatus: completionStatus ?? this.completionStatus,
    successStatus: successStatus ?? this.successStatus,
    scorePourcent: scorePourcent.present ? scorePourcent.value : this.scorePourcent,
    totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
    cmi: cmi.present ? cmi.value : this.cmi,
    majLe: majLe ?? this.majLe,
  );
  EtatScormLigne copyWithCompanion(EtatsScormCompanion data) {
    return EtatScormLigne(
      leconId: data.leconId.present ? data.leconId.value : this.leconId,
      coursId: data.coursId.present ? data.coursId.value : this.coursId,
      completionStatus: data.completionStatus.present ? data.completionStatus.value : this.completionStatus,
      successStatus: data.successStatus.present ? data.successStatus.value : this.successStatus,
      scorePourcent: data.scorePourcent.present ? data.scorePourcent.value : this.scorePourcent,
      totalTimeSeconds: data.totalTimeSeconds.present ? data.totalTimeSeconds.value : this.totalTimeSeconds,
      cmi: data.cmi.present ? data.cmi.value : this.cmi,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EtatScormLigne(')
          ..write('leconId: $leconId, ')
          ..write('coursId: $coursId, ')
          ..write('completionStatus: $completionStatus, ')
          ..write('successStatus: $successStatus, ')
          ..write('scorePourcent: $scorePourcent, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('cmi: $cmi, ')
          ..write('majLe: $majLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(leconId, coursId, completionStatus, successStatus, scorePourcent, totalTimeSeconds, cmi, majLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EtatScormLigne &&
          other.leconId == this.leconId &&
          other.coursId == this.coursId &&
          other.completionStatus == this.completionStatus &&
          other.successStatus == this.successStatus &&
          other.scorePourcent == this.scorePourcent &&
          other.totalTimeSeconds == this.totalTimeSeconds &&
          other.cmi == this.cmi &&
          other.majLe == this.majLe);
}

class EtatsScormCompanion extends UpdateCompanion<EtatScormLigne> {
  final Value<int> leconId;
  final Value<int> coursId;
  final Value<String> completionStatus;
  final Value<String> successStatus;
  final Value<double?> scorePourcent;
  final Value<int> totalTimeSeconds;
  final Value<String?> cmi;
  final Value<DateTime> majLe;
  const EtatsScormCompanion({
    this.leconId = const Value.absent(),
    this.coursId = const Value.absent(),
    this.completionStatus = const Value.absent(),
    this.successStatus = const Value.absent(),
    this.scorePourcent = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.cmi = const Value.absent(),
    this.majLe = const Value.absent(),
  });
  EtatsScormCompanion.insert({
    this.leconId = const Value.absent(),
    required int coursId,
    this.completionStatus = const Value.absent(),
    this.successStatus = const Value.absent(),
    this.scorePourcent = const Value.absent(),
    this.totalTimeSeconds = const Value.absent(),
    this.cmi = const Value.absent(),
    required DateTime majLe,
  }) : coursId = Value(coursId),
       majLe = Value(majLe);
  static Insertable<EtatScormLigne> custom({
    Expression<int>? leconId,
    Expression<int>? coursId,
    Expression<String>? completionStatus,
    Expression<String>? successStatus,
    Expression<double>? scorePourcent,
    Expression<int>? totalTimeSeconds,
    Expression<String>? cmi,
    Expression<DateTime>? majLe,
  }) {
    return RawValuesInsertable({
      if (leconId != null) 'lecon_id': leconId,
      if (coursId != null) 'cours_id': coursId,
      if (completionStatus != null) 'completion_status': completionStatus,
      if (successStatus != null) 'success_status': successStatus,
      if (scorePourcent != null) 'score_pourcent': scorePourcent,
      if (totalTimeSeconds != null) 'total_time_seconds': totalTimeSeconds,
      if (cmi != null) 'cmi': cmi,
      if (majLe != null) 'maj_le': majLe,
    });
  }

  EtatsScormCompanion copyWith({
    Value<int>? leconId,
    Value<int>? coursId,
    Value<String>? completionStatus,
    Value<String>? successStatus,
    Value<double?>? scorePourcent,
    Value<int>? totalTimeSeconds,
    Value<String?>? cmi,
    Value<DateTime>? majLe,
  }) {
    return EtatsScormCompanion(
      leconId: leconId ?? this.leconId,
      coursId: coursId ?? this.coursId,
      completionStatus: completionStatus ?? this.completionStatus,
      successStatus: successStatus ?? this.successStatus,
      scorePourcent: scorePourcent ?? this.scorePourcent,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      cmi: cmi ?? this.cmi,
      majLe: majLe ?? this.majLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (leconId.present) {
      map['lecon_id'] = Variable<int>(leconId.value);
    }
    if (coursId.present) {
      map['cours_id'] = Variable<int>(coursId.value);
    }
    if (completionStatus.present) {
      map['completion_status'] = Variable<String>(completionStatus.value);
    }
    if (successStatus.present) {
      map['success_status'] = Variable<String>(successStatus.value);
    }
    if (scorePourcent.present) {
      map['score_pourcent'] = Variable<double>(scorePourcent.value);
    }
    if (totalTimeSeconds.present) {
      map['total_time_seconds'] = Variable<int>(totalTimeSeconds.value);
    }
    if (cmi.present) {
      map['cmi'] = Variable<String>(cmi.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EtatsScormCompanion(')
          ..write('leconId: $leconId, ')
          ..write('coursId: $coursId, ')
          ..write('completionStatus: $completionStatus, ')
          ..write('successStatus: $successStatus, ')
          ..write('scorePourcent: $scorePourcent, ')
          ..write('totalTimeSeconds: $totalTimeSeconds, ')
          ..write('cmi: $cmi, ')
          ..write('majLe: $majLe')
          ..write(')'))
        .toString();
  }
}

class $EvenementsTable extends Evenements with TableInfo<$EvenementsTable, EvenementLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvenementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coursIdMeta = const VerificationMeta('coursId');
  @override
  late final GeneratedColumn<int> coursId = GeneratedColumn<int>(
    'cours_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leconIdMeta = const VerificationMeta('leconId');
  @override
  late final GeneratedColumn<int> leconId = GeneratedColumn<int>(
    'lecon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _survenuLeMeta = const VerificationMeta('survenuLe');
  @override
  late final GeneratedColumn<DateTime> survenuLe = GeneratedColumn<DateTime>(
    'survenu_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _donneesMeta = const VerificationMeta('donnees');
  @override
  late final GeneratedColumn<String> donnees = GeneratedColumn<String>(
    'donnees',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _rangMeta = const VerificationMeta('rang');
  @override
  late final GeneratedColumn<int> rang = GeneratedColumn<int>(
    'rang',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _essaisMeta = const VerificationMeta('essais');
  @override
  late final GeneratedColumn<int> essais = GeneratedColumn<int>(
    'essais',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, coursId, leconId, survenuLe, donnees, rang, essais];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evenements';
  @override
  VerificationContext validateIntegrity(Insertable<EvenementLocal> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('cours_id')) {
      context.handle(_coursIdMeta, coursId.isAcceptableOrUnknown(data['cours_id']!, _coursIdMeta));
    } else if (isInserting) {
      context.missing(_coursIdMeta);
    }
    if (data.containsKey('lecon_id')) {
      context.handle(_leconIdMeta, leconId.isAcceptableOrUnknown(data['lecon_id']!, _leconIdMeta));
    } else if (isInserting) {
      context.missing(_leconIdMeta);
    }
    if (data.containsKey('survenu_le')) {
      context.handle(_survenuLeMeta, survenuLe.isAcceptableOrUnknown(data['survenu_le']!, _survenuLeMeta));
    } else if (isInserting) {
      context.missing(_survenuLeMeta);
    }
    if (data.containsKey('donnees')) {
      context.handle(_donneesMeta, donnees.isAcceptableOrUnknown(data['donnees']!, _donneesMeta));
    }
    if (data.containsKey('rang')) {
      context.handle(_rangMeta, rang.isAcceptableOrUnknown(data['rang']!, _rangMeta));
    }
    if (data.containsKey('essais')) {
      context.handle(_essaisMeta, essais.isAcceptableOrUnknown(data['essais']!, _essaisMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rang};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {id},
  ];
  @override
  EvenementLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvenementLocal(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      coursId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}cours_id'])!,
      leconId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}lecon_id'])!,
      survenuLe: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}survenu_le'])!,
      donnees: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}donnees'])!,
      rang: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rang'])!,
      essais: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}essais'])!,
    );
  }

  @override
  $EvenementsTable createAlias(String alias) {
    return $EvenementsTable(attachedDatabase, alias);
  }
}

class EvenementLocal extends DataClass implements Insertable<EvenementLocal> {
  final String id;
  final String type;
  final int coursId;
  final int leconId;
  final DateTime survenuLe;
  final String donnees;
  final int rang;
  final int essais;
  const EvenementLocal({
    required this.id,
    required this.type,
    required this.coursId,
    required this.leconId,
    required this.survenuLe,
    required this.donnees,
    required this.rang,
    required this.essais,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['cours_id'] = Variable<int>(coursId);
    map['lecon_id'] = Variable<int>(leconId);
    map['survenu_le'] = Variable<DateTime>(survenuLe);
    map['donnees'] = Variable<String>(donnees);
    map['rang'] = Variable<int>(rang);
    map['essais'] = Variable<int>(essais);
    return map;
  }

  EvenementsCompanion toCompanion(bool nullToAbsent) {
    return EvenementsCompanion(
      id: Value(id),
      type: Value(type),
      coursId: Value(coursId),
      leconId: Value(leconId),
      survenuLe: Value(survenuLe),
      donnees: Value(donnees),
      rang: Value(rang),
      essais: Value(essais),
    );
  }

  factory EvenementLocal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvenementLocal(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      coursId: serializer.fromJson<int>(json['coursId']),
      leconId: serializer.fromJson<int>(json['leconId']),
      survenuLe: serializer.fromJson<DateTime>(json['survenuLe']),
      donnees: serializer.fromJson<String>(json['donnees']),
      rang: serializer.fromJson<int>(json['rang']),
      essais: serializer.fromJson<int>(json['essais']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'coursId': serializer.toJson<int>(coursId),
      'leconId': serializer.toJson<int>(leconId),
      'survenuLe': serializer.toJson<DateTime>(survenuLe),
      'donnees': serializer.toJson<String>(donnees),
      'rang': serializer.toJson<int>(rang),
      'essais': serializer.toJson<int>(essais),
    };
  }

  EvenementLocal copyWith({
    String? id,
    String? type,
    int? coursId,
    int? leconId,
    DateTime? survenuLe,
    String? donnees,
    int? rang,
    int? essais,
  }) => EvenementLocal(
    id: id ?? this.id,
    type: type ?? this.type,
    coursId: coursId ?? this.coursId,
    leconId: leconId ?? this.leconId,
    survenuLe: survenuLe ?? this.survenuLe,
    donnees: donnees ?? this.donnees,
    rang: rang ?? this.rang,
    essais: essais ?? this.essais,
  );
  EvenementLocal copyWithCompanion(EvenementsCompanion data) {
    return EvenementLocal(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      coursId: data.coursId.present ? data.coursId.value : this.coursId,
      leconId: data.leconId.present ? data.leconId.value : this.leconId,
      survenuLe: data.survenuLe.present ? data.survenuLe.value : this.survenuLe,
      donnees: data.donnees.present ? data.donnees.value : this.donnees,
      rang: data.rang.present ? data.rang.value : this.rang,
      essais: data.essais.present ? data.essais.value : this.essais,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvenementLocal(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('coursId: $coursId, ')
          ..write('leconId: $leconId, ')
          ..write('survenuLe: $survenuLe, ')
          ..write('donnees: $donnees, ')
          ..write('rang: $rang, ')
          ..write('essais: $essais')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, coursId, leconId, survenuLe, donnees, rang, essais);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvenementLocal &&
          other.id == this.id &&
          other.type == this.type &&
          other.coursId == this.coursId &&
          other.leconId == this.leconId &&
          other.survenuLe == this.survenuLe &&
          other.donnees == this.donnees &&
          other.rang == this.rang &&
          other.essais == this.essais);
}

class EvenementsCompanion extends UpdateCompanion<EvenementLocal> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> coursId;
  final Value<int> leconId;
  final Value<DateTime> survenuLe;
  final Value<String> donnees;
  final Value<int> rang;
  final Value<int> essais;
  const EvenementsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.coursId = const Value.absent(),
    this.leconId = const Value.absent(),
    this.survenuLe = const Value.absent(),
    this.donnees = const Value.absent(),
    this.rang = const Value.absent(),
    this.essais = const Value.absent(),
  });
  EvenementsCompanion.insert({
    required String id,
    required String type,
    required int coursId,
    required int leconId,
    required DateTime survenuLe,
    this.donnees = const Value.absent(),
    this.rang = const Value.absent(),
    this.essais = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       coursId = Value(coursId),
       leconId = Value(leconId),
       survenuLe = Value(survenuLe);
  static Insertable<EvenementLocal> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? coursId,
    Expression<int>? leconId,
    Expression<DateTime>? survenuLe,
    Expression<String>? donnees,
    Expression<int>? rang,
    Expression<int>? essais,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (coursId != null) 'cours_id': coursId,
      if (leconId != null) 'lecon_id': leconId,
      if (survenuLe != null) 'survenu_le': survenuLe,
      if (donnees != null) 'donnees': donnees,
      if (rang != null) 'rang': rang,
      if (essais != null) 'essais': essais,
    });
  }

  EvenementsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<int>? coursId,
    Value<int>? leconId,
    Value<DateTime>? survenuLe,
    Value<String>? donnees,
    Value<int>? rang,
    Value<int>? essais,
  }) {
    return EvenementsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      coursId: coursId ?? this.coursId,
      leconId: leconId ?? this.leconId,
      survenuLe: survenuLe ?? this.survenuLe,
      donnees: donnees ?? this.donnees,
      rang: rang ?? this.rang,
      essais: essais ?? this.essais,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (coursId.present) {
      map['cours_id'] = Variable<int>(coursId.value);
    }
    if (leconId.present) {
      map['lecon_id'] = Variable<int>(leconId.value);
    }
    if (survenuLe.present) {
      map['survenu_le'] = Variable<DateTime>(survenuLe.value);
    }
    if (donnees.present) {
      map['donnees'] = Variable<String>(donnees.value);
    }
    if (rang.present) {
      map['rang'] = Variable<int>(rang.value);
    }
    if (essais.present) {
      map['essais'] = Variable<int>(essais.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvenementsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('coursId: $coursId, ')
          ..write('leconId: $leconId, ')
          ..write('survenuLe: $survenuLe, ')
          ..write('donnees: $donnees, ')
          ..write('rang: $rang, ')
          ..write('essais: $essais')
          ..write(')'))
        .toString();
  }
}

class $EvenementsRefusesTable extends EvenementsRefuses with TableInfo<$EvenementsRefusesTable, EvenementRefuse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvenementsRefusesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _raisonMeta = const VerificationMeta('raison');
  @override
  late final GeneratedColumn<String> raison = GeneratedColumn<String>(
    'raison',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _donneesMeta = const VerificationMeta('donnees');
  @override
  late final GeneratedColumn<String> donnees = GeneratedColumn<String>(
    'donnees',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _refuseLeMeta = const VerificationMeta('refuseLe');
  @override
  late final GeneratedColumn<DateTime> refuseLe = GeneratedColumn<DateTime>(
    'refuse_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, raison, donnees, refuseLe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evenements_refuses';
  @override
  VerificationContext validateIntegrity(Insertable<EvenementRefuse> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('raison')) {
      context.handle(_raisonMeta, raison.isAcceptableOrUnknown(data['raison']!, _raisonMeta));
    }
    if (data.containsKey('donnees')) {
      context.handle(_donneesMeta, donnees.isAcceptableOrUnknown(data['donnees']!, _donneesMeta));
    }
    if (data.containsKey('refuse_le')) {
      context.handle(_refuseLeMeta, refuseLe.isAcceptableOrUnknown(data['refuse_le']!, _refuseLeMeta));
    } else if (isInserting) {
      context.missing(_refuseLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EvenementRefuse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvenementRefuse(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      raison: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}raison'])!,
      donnees: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}donnees'])!,
      refuseLe: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}refuse_le'])!,
    );
  }

  @override
  $EvenementsRefusesTable createAlias(String alias) {
    return $EvenementsRefusesTable(attachedDatabase, alias);
  }
}

class EvenementRefuse extends DataClass implements Insertable<EvenementRefuse> {
  final String id;
  final String type;
  final String raison;
  final String donnees;
  final DateTime refuseLe;
  const EvenementRefuse({
    required this.id,
    required this.type,
    required this.raison,
    required this.donnees,
    required this.refuseLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['raison'] = Variable<String>(raison);
    map['donnees'] = Variable<String>(donnees);
    map['refuse_le'] = Variable<DateTime>(refuseLe);
    return map;
  }

  EvenementsRefusesCompanion toCompanion(bool nullToAbsent) {
    return EvenementsRefusesCompanion(
      id: Value(id),
      type: Value(type),
      raison: Value(raison),
      donnees: Value(donnees),
      refuseLe: Value(refuseLe),
    );
  }

  factory EvenementRefuse.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvenementRefuse(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      raison: serializer.fromJson<String>(json['raison']),
      donnees: serializer.fromJson<String>(json['donnees']),
      refuseLe: serializer.fromJson<DateTime>(json['refuseLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'raison': serializer.toJson<String>(raison),
      'donnees': serializer.toJson<String>(donnees),
      'refuseLe': serializer.toJson<DateTime>(refuseLe),
    };
  }

  EvenementRefuse copyWith({String? id, String? type, String? raison, String? donnees, DateTime? refuseLe}) =>
      EvenementRefuse(
        id: id ?? this.id,
        type: type ?? this.type,
        raison: raison ?? this.raison,
        donnees: donnees ?? this.donnees,
        refuseLe: refuseLe ?? this.refuseLe,
      );
  EvenementRefuse copyWithCompanion(EvenementsRefusesCompanion data) {
    return EvenementRefuse(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      raison: data.raison.present ? data.raison.value : this.raison,
      donnees: data.donnees.present ? data.donnees.value : this.donnees,
      refuseLe: data.refuseLe.present ? data.refuseLe.value : this.refuseLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvenementRefuse(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('raison: $raison, ')
          ..write('donnees: $donnees, ')
          ..write('refuseLe: $refuseLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, raison, donnees, refuseLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvenementRefuse &&
          other.id == this.id &&
          other.type == this.type &&
          other.raison == this.raison &&
          other.donnees == this.donnees &&
          other.refuseLe == this.refuseLe);
}

class EvenementsRefusesCompanion extends UpdateCompanion<EvenementRefuse> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> raison;
  final Value<String> donnees;
  final Value<DateTime> refuseLe;
  final Value<int> rowid;
  const EvenementsRefusesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.raison = const Value.absent(),
    this.donnees = const Value.absent(),
    this.refuseLe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvenementsRefusesCompanion.insert({
    required String id,
    required String type,
    this.raison = const Value.absent(),
    this.donnees = const Value.absent(),
    required DateTime refuseLe,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       refuseLe = Value(refuseLe);
  static Insertable<EvenementRefuse> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? raison,
    Expression<String>? donnees,
    Expression<DateTime>? refuseLe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (raison != null) 'raison': raison,
      if (donnees != null) 'donnees': donnees,
      if (refuseLe != null) 'refuse_le': refuseLe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvenementsRefusesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? raison,
    Value<String>? donnees,
    Value<DateTime>? refuseLe,
    Value<int>? rowid,
  }) {
    return EvenementsRefusesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      raison: raison ?? this.raison,
      donnees: donnees ?? this.donnees,
      refuseLe: refuseLe ?? this.refuseLe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (raison.present) {
      map['raison'] = Variable<String>(raison.value);
    }
    if (donnees.present) {
      map['donnees'] = Variable<String>(donnees.value);
    }
    if (refuseLe.present) {
      map['refuse_le'] = Variable<DateTime>(refuseLe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvenementsRefusesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('raison: $raison, ')
          ..write('donnees: $donnees, ')
          ..write('refuseLe: $refuseLe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaLigne> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cleMeta = const VerificationMeta('cle');
  @override
  late final GeneratedColumn<String> cle = GeneratedColumn<String>(
    'cle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valeurMeta = const VerificationMeta('valeur');
  @override
  late final GeneratedColumn<String> valeur = GeneratedColumn<String>(
    'valeur',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cle, valeur];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(Insertable<MetaLigne> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cle')) {
      context.handle(_cleMeta, cle.isAcceptableOrUnknown(data['cle']!, _cleMeta));
    } else if (isInserting) {
      context.missing(_cleMeta);
    }
    if (data.containsKey('valeur')) {
      context.handle(_valeurMeta, valeur.isAcceptableOrUnknown(data['valeur']!, _valeurMeta));
    } else if (isInserting) {
      context.missing(_valeurMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cle};
  @override
  MetaLigne map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaLigne(
      cle: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}cle'])!,
      valeur: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}valeur'])!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaLigne extends DataClass implements Insertable<MetaLigne> {
  final String cle;
  final String valeur;
  const MetaLigne({required this.cle, required this.valeur});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cle'] = Variable<String>(cle);
    map['valeur'] = Variable<String>(valeur);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(cle: Value(cle), valeur: Value(valeur));
  }

  factory MetaLigne.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaLigne(
      cle: serializer.fromJson<String>(json['cle']),
      valeur: serializer.fromJson<String>(json['valeur']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'cle': serializer.toJson<String>(cle), 'valeur': serializer.toJson<String>(valeur)};
  }

  MetaLigne copyWith({String? cle, String? valeur}) => MetaLigne(cle: cle ?? this.cle, valeur: valeur ?? this.valeur);
  MetaLigne copyWithCompanion(MetaCompanion data) {
    return MetaLigne(
      cle: data.cle.present ? data.cle.value : this.cle,
      valeur: data.valeur.present ? data.valeur.value : this.valeur,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaLigne(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cle, valeur);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MetaLigne && other.cle == this.cle && other.valeur == this.valeur);
}

class MetaCompanion extends UpdateCompanion<MetaLigne> {
  final Value<String> cle;
  final Value<String> valeur;
  final Value<int> rowid;
  const MetaCompanion({
    this.cle = const Value.absent(),
    this.valeur = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({required String cle, required String valeur, this.rowid = const Value.absent()})
    : cle = Value(cle),
      valeur = Value(valeur);
  static Insertable<MetaLigne> custom({Expression<String>? cle, Expression<String>? valeur, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (cle != null) 'cle': cle,
      if (valeur != null) 'valeur': valeur,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({Value<String>? cle, Value<String>? valeur, Value<int>? rowid}) {
    return MetaCompanion(cle: cle ?? this.cle, valeur: valeur ?? this.valeur, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cle.present) {
      map['cle'] = Variable<String>(cle.value);
    }
    if (valeur.present) {
      map['valeur'] = Variable<String>(valeur.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('cle: $cle, ')
          ..write('valeur: $valeur, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseProfil extends GeneratedDatabase {
  _$BaseProfil(QueryExecutor e) : super(e);
  $BaseProfilManager get managers => $BaseProfilManager(this);
  late final $FormationsTable formations = $FormationsTable(this);
  late final $EtatsLeconsTable etatsLecons = $EtatsLeconsTable(this);
  late final $EtatsScormTable etatsScorm = $EtatsScormTable(this);
  late final $EvenementsTable evenements = $EvenementsTable(this);
  late final $EvenementsRefusesTable evenementsRefuses = $EvenementsRefusesTable(this);
  late final $MetaTable meta = $MetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    formations,
    etatsLecons,
    etatsScorm,
    evenements,
    evenementsRefuses,
    meta,
  ];
}

typedef $$FormationsTableCreateCompanionBuilder = FormationsCompanion Function({
  Value<int> id,
  required String titre,
  Value<String> resume,
  Value<String> cohortes,
  Value<String> tuteurs,
  Value<int> nbLecons,
  Value<int> nbLeconsTerminees,
  Value<int> progression,
  Value<String> versionServeur,
  Value<int> tailleTelechargement,
  Value<DateTime?> derniereActivite,
  Value<int> ordre,
});
typedef $$FormationsTableUpdateCompanionBuilder = FormationsCompanion Function({
  Value<int> id,
  Value<String> titre,
  Value<String> resume,
  Value<String> cohortes,
  Value<String> tuteurs,
  Value<int> nbLecons,
  Value<int> nbLeconsTerminees,
  Value<int> progression,
  Value<String> versionServeur,
  Value<int> tailleTelechargement,
  Value<DateTime?> derniereActivite,
  Value<int> ordre,
});

class $$FormationsTableFilterComposer extends Composer<_$BaseProfil, $FormationsTable> {
  $$FormationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get titre =>
      $composableBuilder(column: $table.titre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resume =>
      $composableBuilder(column: $table.resume, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cohortes =>
      $composableBuilder(column: $table.cohortes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tuteurs =>
      $composableBuilder(column: $table.tuteurs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nbLecons =>
      $composableBuilder(column: $table.nbLecons, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nbLeconsTerminees =>
      $composableBuilder(column: $table.nbLeconsTerminees, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get progression =>
      $composableBuilder(column: $table.progression, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get versionServeur =>
      $composableBuilder(column: $table.versionServeur, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tailleTelechargement =>
      $composableBuilder(column: $table.tailleTelechargement, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get derniereActivite =>
      $composableBuilder(column: $table.derniereActivite, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ordre => $composableBuilder(column: $table.ordre, builder: (column) => ColumnFilters(column));
}

class $$FormationsTableOrderingComposer extends Composer<_$BaseProfil, $FormationsTable> {
  $$FormationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get titre =>
      $composableBuilder(column: $table.titre, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resume =>
      $composableBuilder(column: $table.resume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cohortes =>
      $composableBuilder(column: $table.cohortes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tuteurs =>
      $composableBuilder(column: $table.tuteurs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nbLecons =>
      $composableBuilder(column: $table.nbLecons, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nbLeconsTerminees =>
      $composableBuilder(column: $table.nbLeconsTerminees, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get progression =>
      $composableBuilder(column: $table.progression, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get versionServeur =>
      $composableBuilder(column: $table.versionServeur, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tailleTelechargement =>
      $composableBuilder(column: $table.tailleTelechargement, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get derniereActivite =>
      $composableBuilder(column: $table.derniereActivite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => ColumnOrderings(column));
}

class $$FormationsTableAnnotationComposer extends Composer<_$BaseProfil, $FormationsTable> {
  $$FormationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titre => $composableBuilder(column: $table.titre, builder: (column) => column);

  GeneratedColumn<String> get resume => $composableBuilder(column: $table.resume, builder: (column) => column);

  GeneratedColumn<String> get cohortes => $composableBuilder(column: $table.cohortes, builder: (column) => column);

  GeneratedColumn<String> get tuteurs => $composableBuilder(column: $table.tuteurs, builder: (column) => column);

  GeneratedColumn<int> get nbLecons => $composableBuilder(column: $table.nbLecons, builder: (column) => column);

  GeneratedColumn<int> get nbLeconsTerminees =>
      $composableBuilder(column: $table.nbLeconsTerminees, builder: (column) => column);

  GeneratedColumn<int> get progression => $composableBuilder(column: $table.progression, builder: (column) => column);

  GeneratedColumn<String> get versionServeur =>
      $composableBuilder(column: $table.versionServeur, builder: (column) => column);

  GeneratedColumn<int> get tailleTelechargement =>
      $composableBuilder(column: $table.tailleTelechargement, builder: (column) => column);

  GeneratedColumn<DateTime> get derniereActivite =>
      $composableBuilder(column: $table.derniereActivite, builder: (column) => column);

  GeneratedColumn<int> get ordre => $composableBuilder(column: $table.ordre, builder: (column) => column);
}

class $$FormationsTableTableManager
    extends
        RootTableManager<
          _$BaseProfil,
          $FormationsTable,
          FormationLocale,
          $$FormationsTableFilterComposer,
          $$FormationsTableOrderingComposer,
          $$FormationsTableAnnotationComposer,
          $$FormationsTableCreateCompanionBuilder,
          $$FormationsTableUpdateCompanionBuilder,
          (FormationLocale, BaseReferences<_$BaseProfil, $FormationsTable, FormationLocale>),
          FormationLocale,
          PrefetchHooks Function()
        > {
  $$FormationsTableTableManager(_$BaseProfil db, $FormationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FormationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FormationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FormationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> titre = const Value.absent(),
                Value<String> resume = const Value.absent(),
                Value<String> cohortes = const Value.absent(),
                Value<String> tuteurs = const Value.absent(),
                Value<int> nbLecons = const Value.absent(),
                Value<int> nbLeconsTerminees = const Value.absent(),
                Value<int> progression = const Value.absent(),
                Value<String> versionServeur = const Value.absent(),
                Value<int> tailleTelechargement = const Value.absent(),
                Value<DateTime?> derniereActivite = const Value.absent(),
                Value<int> ordre = const Value.absent(),
              }) => FormationsCompanion(
                id: id,
                titre: titre,
                resume: resume,
                cohortes: cohortes,
                tuteurs: tuteurs,
                nbLecons: nbLecons,
                nbLeconsTerminees: nbLeconsTerminees,
                progression: progression,
                versionServeur: versionServeur,
                tailleTelechargement: tailleTelechargement,
                derniereActivite: derniereActivite,
                ordre: ordre,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String titre,
                Value<String> resume = const Value.absent(),
                Value<String> cohortes = const Value.absent(),
                Value<String> tuteurs = const Value.absent(),
                Value<int> nbLecons = const Value.absent(),
                Value<int> nbLeconsTerminees = const Value.absent(),
                Value<int> progression = const Value.absent(),
                Value<String> versionServeur = const Value.absent(),
                Value<int> tailleTelechargement = const Value.absent(),
                Value<DateTime?> derniereActivite = const Value.absent(),
                Value<int> ordre = const Value.absent(),
              }) => FormationsCompanion.insert(
                id: id,
                titre: titre,
                resume: resume,
                cohortes: cohortes,
                tuteurs: tuteurs,
                nbLecons: nbLecons,
                nbLeconsTerminees: nbLeconsTerminees,
                progression: progression,
                versionServeur: versionServeur,
                tailleTelechargement: tailleTelechargement,
                derniereActivite: derniereActivite,
                ordre: ordre,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FormationsTable, FormationLocale>(table),
                  BaseReferences<_$BaseProfil, $FormationsTable, FormationLocale>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormationsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseProfil,
      $FormationsTable,
      FormationLocale,
      $$FormationsTableFilterComposer,
      $$FormationsTableOrderingComposer,
      $$FormationsTableAnnotationComposer,
      $$FormationsTableCreateCompanionBuilder,
      $$FormationsTableUpdateCompanionBuilder,
      (FormationLocale, BaseReferences<_$BaseProfil, $FormationsTable, FormationLocale>),
      FormationLocale,
      PrefetchHooks Function()
    >;
typedef $$EtatsLeconsTableCreateCompanionBuilder = EtatsLeconsCompanion Function({
  Value<int> leconId,
  required int coursId,
  Value<bool> terminee,
  Value<bool> ouverte,
  Value<int> tempsSecondes,
  required DateTime majLe,
});
typedef $$EtatsLeconsTableUpdateCompanionBuilder = EtatsLeconsCompanion Function({
  Value<int> leconId,
  Value<int> coursId,
  Value<bool> terminee,
  Value<bool> ouverte,
  Value<int> tempsSecondes,
  Value<DateTime> majLe,
});

class $$EtatsLeconsTableFilterComposer extends Composer<_$BaseProfil, $EtatsLeconsTable> {
  $$EtatsLeconsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get leconId =>
      $composableBuilder(column: $table.leconId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get terminee =>
      $composableBuilder(column: $table.terminee, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ouverte =>
      $composableBuilder(column: $table.ouverte, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tempsSecondes =>
      $composableBuilder(column: $table.tempsSecondes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => ColumnFilters(column));
}

class $$EtatsLeconsTableOrderingComposer extends Composer<_$BaseProfil, $EtatsLeconsTable> {
  $$EtatsLeconsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get leconId =>
      $composableBuilder(column: $table.leconId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get terminee =>
      $composableBuilder(column: $table.terminee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ouverte =>
      $composableBuilder(column: $table.ouverte, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tempsSecondes =>
      $composableBuilder(column: $table.tempsSecondes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => ColumnOrderings(column));
}

class $$EtatsLeconsTableAnnotationComposer extends Composer<_$BaseProfil, $EtatsLeconsTable> {
  $$EtatsLeconsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get leconId => $composableBuilder(column: $table.leconId, builder: (column) => column);

  GeneratedColumn<int> get coursId => $composableBuilder(column: $table.coursId, builder: (column) => column);

  GeneratedColumn<bool> get terminee => $composableBuilder(column: $table.terminee, builder: (column) => column);

  GeneratedColumn<bool> get ouverte => $composableBuilder(column: $table.ouverte, builder: (column) => column);

  GeneratedColumn<int> get tempsSecondes =>
      $composableBuilder(column: $table.tempsSecondes, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe => $composableBuilder(column: $table.majLe, builder: (column) => column);
}

class $$EtatsLeconsTableTableManager
    extends
        RootTableManager<
          _$BaseProfil,
          $EtatsLeconsTable,
          EtatLeconLocal,
          $$EtatsLeconsTableFilterComposer,
          $$EtatsLeconsTableOrderingComposer,
          $$EtatsLeconsTableAnnotationComposer,
          $$EtatsLeconsTableCreateCompanionBuilder,
          $$EtatsLeconsTableUpdateCompanionBuilder,
          (EtatLeconLocal, BaseReferences<_$BaseProfil, $EtatsLeconsTable, EtatLeconLocal>),
          EtatLeconLocal,
          PrefetchHooks Function()
        > {
  $$EtatsLeconsTableTableManager(_$BaseProfil db, $EtatsLeconsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EtatsLeconsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EtatsLeconsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EtatsLeconsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> leconId = const Value.absent(),
                Value<int> coursId = const Value.absent(),
                Value<bool> terminee = const Value.absent(),
                Value<bool> ouverte = const Value.absent(),
                Value<int> tempsSecondes = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
              }) => EtatsLeconsCompanion(
                leconId: leconId,
                coursId: coursId,
                terminee: terminee,
                ouverte: ouverte,
                tempsSecondes: tempsSecondes,
                majLe: majLe,
              ),
          createCompanionCallback:
              ({
                Value<int> leconId = const Value.absent(),
                required int coursId,
                Value<bool> terminee = const Value.absent(),
                Value<bool> ouverte = const Value.absent(),
                Value<int> tempsSecondes = const Value.absent(),
                required DateTime majLe,
              }) => EtatsLeconsCompanion.insert(
                leconId: leconId,
                coursId: coursId,
                terminee: terminee,
                ouverte: ouverte,
                tempsSecondes: tempsSecondes,
                majLe: majLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EtatsLeconsTable, EtatLeconLocal>(table),
                  BaseReferences<_$BaseProfil, $EtatsLeconsTable, EtatLeconLocal>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EtatsLeconsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseProfil,
      $EtatsLeconsTable,
      EtatLeconLocal,
      $$EtatsLeconsTableFilterComposer,
      $$EtatsLeconsTableOrderingComposer,
      $$EtatsLeconsTableAnnotationComposer,
      $$EtatsLeconsTableCreateCompanionBuilder,
      $$EtatsLeconsTableUpdateCompanionBuilder,
      (EtatLeconLocal, BaseReferences<_$BaseProfil, $EtatsLeconsTable, EtatLeconLocal>),
      EtatLeconLocal,
      PrefetchHooks Function()
    >;
typedef $$EtatsScormTableCreateCompanionBuilder = EtatsScormCompanion Function({
  Value<int> leconId,
  required int coursId,
  Value<String> completionStatus,
  Value<String> successStatus,
  Value<double?> scorePourcent,
  Value<int> totalTimeSeconds,
  Value<String?> cmi,
  required DateTime majLe,
});
typedef $$EtatsScormTableUpdateCompanionBuilder = EtatsScormCompanion Function({
  Value<int> leconId,
  Value<int> coursId,
  Value<String> completionStatus,
  Value<String> successStatus,
  Value<double?> scorePourcent,
  Value<int> totalTimeSeconds,
  Value<String?> cmi,
  Value<DateTime> majLe,
});

class $$EtatsScormTableFilterComposer extends Composer<_$BaseProfil, $EtatsScormTable> {
  $$EtatsScormTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get leconId =>
      $composableBuilder(column: $table.leconId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get completionStatus =>
      $composableBuilder(column: $table.completionStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get successStatus =>
      $composableBuilder(column: $table.successStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scorePourcent =>
      $composableBuilder(column: $table.scorePourcent, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalTimeSeconds =>
      $composableBuilder(column: $table.totalTimeSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cmi => $composableBuilder(column: $table.cmi, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => ColumnFilters(column));
}

class $$EtatsScormTableOrderingComposer extends Composer<_$BaseProfil, $EtatsScormTable> {
  $$EtatsScormTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get leconId =>
      $composableBuilder(column: $table.leconId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get completionStatus =>
      $composableBuilder(column: $table.completionStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get successStatus =>
      $composableBuilder(column: $table.successStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scorePourcent =>
      $composableBuilder(column: $table.scorePourcent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalTimeSeconds =>
      $composableBuilder(column: $table.totalTimeSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cmi =>
      $composableBuilder(column: $table.cmi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => ColumnOrderings(column));
}

class $$EtatsScormTableAnnotationComposer extends Composer<_$BaseProfil, $EtatsScormTable> {
  $$EtatsScormTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get leconId => $composableBuilder(column: $table.leconId, builder: (column) => column);

  GeneratedColumn<int> get coursId => $composableBuilder(column: $table.coursId, builder: (column) => column);

  GeneratedColumn<String> get completionStatus =>
      $composableBuilder(column: $table.completionStatus, builder: (column) => column);

  GeneratedColumn<String> get successStatus =>
      $composableBuilder(column: $table.successStatus, builder: (column) => column);

  GeneratedColumn<double> get scorePourcent =>
      $composableBuilder(column: $table.scorePourcent, builder: (column) => column);

  GeneratedColumn<int> get totalTimeSeconds =>
      $composableBuilder(column: $table.totalTimeSeconds, builder: (column) => column);

  GeneratedColumn<String> get cmi => $composableBuilder(column: $table.cmi, builder: (column) => column);

  GeneratedColumn<DateTime> get majLe => $composableBuilder(column: $table.majLe, builder: (column) => column);
}

class $$EtatsScormTableTableManager
    extends
        RootTableManager<
          _$BaseProfil,
          $EtatsScormTable,
          EtatScormLigne,
          $$EtatsScormTableFilterComposer,
          $$EtatsScormTableOrderingComposer,
          $$EtatsScormTableAnnotationComposer,
          $$EtatsScormTableCreateCompanionBuilder,
          $$EtatsScormTableUpdateCompanionBuilder,
          (EtatScormLigne, BaseReferences<_$BaseProfil, $EtatsScormTable, EtatScormLigne>),
          EtatScormLigne,
          PrefetchHooks Function()
        > {
  $$EtatsScormTableTableManager(_$BaseProfil db, $EtatsScormTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EtatsScormTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EtatsScormTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EtatsScormTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> leconId = const Value.absent(),
                Value<int> coursId = const Value.absent(),
                Value<String> completionStatus = const Value.absent(),
                Value<String> successStatus = const Value.absent(),
                Value<double?> scorePourcent = const Value.absent(),
                Value<int> totalTimeSeconds = const Value.absent(),
                Value<String?> cmi = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
              }) => EtatsScormCompanion(
                leconId: leconId,
                coursId: coursId,
                completionStatus: completionStatus,
                successStatus: successStatus,
                scorePourcent: scorePourcent,
                totalTimeSeconds: totalTimeSeconds,
                cmi: cmi,
                majLe: majLe,
              ),
          createCompanionCallback:
              ({
                Value<int> leconId = const Value.absent(),
                required int coursId,
                Value<String> completionStatus = const Value.absent(),
                Value<String> successStatus = const Value.absent(),
                Value<double?> scorePourcent = const Value.absent(),
                Value<int> totalTimeSeconds = const Value.absent(),
                Value<String?> cmi = const Value.absent(),
                required DateTime majLe,
              }) => EtatsScormCompanion.insert(
                leconId: leconId,
                coursId: coursId,
                completionStatus: completionStatus,
                successStatus: successStatus,
                scorePourcent: scorePourcent,
                totalTimeSeconds: totalTimeSeconds,
                cmi: cmi,
                majLe: majLe,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EtatsScormTable, EtatScormLigne>(table),
                  BaseReferences<_$BaseProfil, $EtatsScormTable, EtatScormLigne>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EtatsScormTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseProfil,
      $EtatsScormTable,
      EtatScormLigne,
      $$EtatsScormTableFilterComposer,
      $$EtatsScormTableOrderingComposer,
      $$EtatsScormTableAnnotationComposer,
      $$EtatsScormTableCreateCompanionBuilder,
      $$EtatsScormTableUpdateCompanionBuilder,
      (EtatScormLigne, BaseReferences<_$BaseProfil, $EtatsScormTable, EtatScormLigne>),
      EtatScormLigne,
      PrefetchHooks Function()
    >;
typedef $$EvenementsTableCreateCompanionBuilder = EvenementsCompanion Function({
  required String id,
  required String type,
  required int coursId,
  required int leconId,
  required DateTime survenuLe,
  Value<String> donnees,
  Value<int> rang,
  Value<int> essais,
});
typedef $$EvenementsTableUpdateCompanionBuilder = EvenementsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<int> coursId,
  Value<int> leconId,
  Value<DateTime> survenuLe,
  Value<String> donnees,
  Value<int> rang,
  Value<int> essais,
});

class $$EvenementsTableFilterComposer extends Composer<_$BaseProfil, $EvenementsTable> {
  $$EvenementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get leconId =>
      $composableBuilder(column: $table.leconId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get survenuLe =>
      $composableBuilder(column: $table.survenuLe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donnees =>
      $composableBuilder(column: $table.donnees, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rang => $composableBuilder(column: $table.rang, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get essais =>
      $composableBuilder(column: $table.essais, builder: (column) => ColumnFilters(column));
}

class $$EvenementsTableOrderingComposer extends Composer<_$BaseProfil, $EvenementsTable> {
  $$EvenementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get leconId =>
      $composableBuilder(column: $table.leconId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get survenuLe =>
      $composableBuilder(column: $table.survenuLe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donnees =>
      $composableBuilder(column: $table.donnees, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rang =>
      $composableBuilder(column: $table.rang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get essais =>
      $composableBuilder(column: $table.essais, builder: (column) => ColumnOrderings(column));
}

class $$EvenementsTableAnnotationComposer extends Composer<_$BaseProfil, $EvenementsTable> {
  $$EvenementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get coursId => $composableBuilder(column: $table.coursId, builder: (column) => column);

  GeneratedColumn<int> get leconId => $composableBuilder(column: $table.leconId, builder: (column) => column);

  GeneratedColumn<DateTime> get survenuLe => $composableBuilder(column: $table.survenuLe, builder: (column) => column);

  GeneratedColumn<String> get donnees => $composableBuilder(column: $table.donnees, builder: (column) => column);

  GeneratedColumn<int> get rang => $composableBuilder(column: $table.rang, builder: (column) => column);

  GeneratedColumn<int> get essais => $composableBuilder(column: $table.essais, builder: (column) => column);
}

class $$EvenementsTableTableManager
    extends
        RootTableManager<
          _$BaseProfil,
          $EvenementsTable,
          EvenementLocal,
          $$EvenementsTableFilterComposer,
          $$EvenementsTableOrderingComposer,
          $$EvenementsTableAnnotationComposer,
          $$EvenementsTableCreateCompanionBuilder,
          $$EvenementsTableUpdateCompanionBuilder,
          (EvenementLocal, BaseReferences<_$BaseProfil, $EvenementsTable, EvenementLocal>),
          EvenementLocal,
          PrefetchHooks Function()
        > {
  $$EvenementsTableTableManager(_$BaseProfil db, $EvenementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EvenementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EvenementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EvenementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> coursId = const Value.absent(),
                Value<int> leconId = const Value.absent(),
                Value<DateTime> survenuLe = const Value.absent(),
                Value<String> donnees = const Value.absent(),
                Value<int> rang = const Value.absent(),
                Value<int> essais = const Value.absent(),
              }) => EvenementsCompanion(
                id: id,
                type: type,
                coursId: coursId,
                leconId: leconId,
                survenuLe: survenuLe,
                donnees: donnees,
                rang: rang,
                essais: essais,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required int coursId,
                required int leconId,
                required DateTime survenuLe,
                Value<String> donnees = const Value.absent(),
                Value<int> rang = const Value.absent(),
                Value<int> essais = const Value.absent(),
              }) => EvenementsCompanion.insert(
                id: id,
                type: type,
                coursId: coursId,
                leconId: leconId,
                survenuLe: survenuLe,
                donnees: donnees,
                rang: rang,
                essais: essais,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EvenementsTable, EvenementLocal>(table),
                  BaseReferences<_$BaseProfil, $EvenementsTable, EvenementLocal>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EvenementsTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseProfil,
      $EvenementsTable,
      EvenementLocal,
      $$EvenementsTableFilterComposer,
      $$EvenementsTableOrderingComposer,
      $$EvenementsTableAnnotationComposer,
      $$EvenementsTableCreateCompanionBuilder,
      $$EvenementsTableUpdateCompanionBuilder,
      (EvenementLocal, BaseReferences<_$BaseProfil, $EvenementsTable, EvenementLocal>),
      EvenementLocal,
      PrefetchHooks Function()
    >;
typedef $$EvenementsRefusesTableCreateCompanionBuilder = EvenementsRefusesCompanion Function({
  required String id,
  required String type,
  Value<String> raison,
  Value<String> donnees,
  required DateTime refuseLe,
  Value<int> rowid,
});
typedef $$EvenementsRefusesTableUpdateCompanionBuilder = EvenementsRefusesCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> raison,
  Value<String> donnees,
  Value<DateTime> refuseLe,
  Value<int> rowid,
});

class $$EvenementsRefusesTableFilterComposer extends Composer<_$BaseProfil, $EvenementsRefusesTable> {
  $$EvenementsRefusesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get raison =>
      $composableBuilder(column: $table.raison, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get donnees =>
      $composableBuilder(column: $table.donnees, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get refuseLe =>
      $composableBuilder(column: $table.refuseLe, builder: (column) => ColumnFilters(column));
}

class $$EvenementsRefusesTableOrderingComposer extends Composer<_$BaseProfil, $EvenementsRefusesTable> {
  $$EvenementsRefusesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get raison =>
      $composableBuilder(column: $table.raison, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get donnees =>
      $composableBuilder(column: $table.donnees, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get refuseLe =>
      $composableBuilder(column: $table.refuseLe, builder: (column) => ColumnOrderings(column));
}

class $$EvenementsRefusesTableAnnotationComposer extends Composer<_$BaseProfil, $EvenementsRefusesTable> {
  $$EvenementsRefusesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type => $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get raison => $composableBuilder(column: $table.raison, builder: (column) => column);

  GeneratedColumn<String> get donnees => $composableBuilder(column: $table.donnees, builder: (column) => column);

  GeneratedColumn<DateTime> get refuseLe => $composableBuilder(column: $table.refuseLe, builder: (column) => column);
}

class $$EvenementsRefusesTableTableManager
    extends
        RootTableManager<
          _$BaseProfil,
          $EvenementsRefusesTable,
          EvenementRefuse,
          $$EvenementsRefusesTableFilterComposer,
          $$EvenementsRefusesTableOrderingComposer,
          $$EvenementsRefusesTableAnnotationComposer,
          $$EvenementsRefusesTableCreateCompanionBuilder,
          $$EvenementsRefusesTableUpdateCompanionBuilder,
          (EvenementRefuse, BaseReferences<_$BaseProfil, $EvenementsRefusesTable, EvenementRefuse>),
          EvenementRefuse,
          PrefetchHooks Function()
        > {
  $$EvenementsRefusesTableTableManager(_$BaseProfil db, $EvenementsRefusesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$EvenementsRefusesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$EvenementsRefusesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$EvenementsRefusesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> raison = const Value.absent(),
                Value<String> donnees = const Value.absent(),
                Value<DateTime> refuseLe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EvenementsRefusesCompanion(
                id: id,
                type: type,
                raison: raison,
                donnees: donnees,
                refuseLe: refuseLe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String> raison = const Value.absent(),
                Value<String> donnees = const Value.absent(),
                required DateTime refuseLe,
                Value<int> rowid = const Value.absent(),
              }) => EvenementsRefusesCompanion.insert(
                id: id,
                type: type,
                raison: raison,
                donnees: donnees,
                refuseLe: refuseLe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EvenementsRefusesTable, EvenementRefuse>(table),
                  BaseReferences<_$BaseProfil, $EvenementsRefusesTable, EvenementRefuse>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EvenementsRefusesTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseProfil,
      $EvenementsRefusesTable,
      EvenementRefuse,
      $$EvenementsRefusesTableFilterComposer,
      $$EvenementsRefusesTableOrderingComposer,
      $$EvenementsRefusesTableAnnotationComposer,
      $$EvenementsRefusesTableCreateCompanionBuilder,
      $$EvenementsRefusesTableUpdateCompanionBuilder,
      (EvenementRefuse, BaseReferences<_$BaseProfil, $EvenementsRefusesTable, EvenementRefuse>),
      EvenementRefuse,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String cle,
  required String valeur,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> cle,
  Value<String> valeur,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$BaseProfil, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cle => $composableBuilder(column: $table.cle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valeur =>
      $composableBuilder(column: $table.valeur, builder: (column) => ColumnFilters(column));
}

class $$MetaTableOrderingComposer extends Composer<_$BaseProfil, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cle =>
      $composableBuilder(column: $table.cle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valeur =>
      $composableBuilder(column: $table.valeur, builder: (column) => ColumnOrderings(column));
}

class $$MetaTableAnnotationComposer extends Composer<_$BaseProfil, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cle => $composableBuilder(column: $table.cle, builder: (column) => column);

  GeneratedColumn<String> get valeur => $composableBuilder(column: $table.valeur, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$BaseProfil,
          $MetaTable,
          MetaLigne,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaLigne, BaseReferences<_$BaseProfil, $MetaTable, MetaLigne>),
          MetaLigne,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$BaseProfil db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cle = const Value.absent(),
            Value<String> valeur = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(cle: cle, valeur: valeur, rowid: rowid),
          createCompanionCallback: ({
            required String cle,
            required String valeur,
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(cle: cle, valeur: valeur, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaLigne>(table),
                  BaseReferences<_$BaseProfil, $MetaTable, MetaLigne>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseProfil,
      $MetaTable,
      MetaLigne,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaLigne, BaseReferences<_$BaseProfil, $MetaTable, MetaLigne>),
      MetaLigne,
      PrefetchHooks Function()
    >;

class $BaseProfilManager {
  final _$BaseProfil _db;
  $BaseProfilManager(this._db);
  $$FormationsTableTableManager get formations => $$FormationsTableTableManager(_db, _db.formations);
  $$EtatsLeconsTableTableManager get etatsLecons => $$EtatsLeconsTableTableManager(_db, _db.etatsLecons);
  $$EtatsScormTableTableManager get etatsScorm => $$EtatsScormTableTableManager(_db, _db.etatsScorm);
  $$EvenementsTableTableManager get evenements => $$EvenementsTableTableManager(_db, _db.evenements);
  $$EvenementsRefusesTableTableManager get evenementsRefuses =>
      $$EvenementsRefusesTableTableManager(_db, _db.evenementsRefuses);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
