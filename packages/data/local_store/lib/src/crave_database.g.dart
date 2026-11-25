// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crave_database.dart';

// ignore_for_file: type=lint
class $RestaurantsTable extends Restaurants
    with TableInfo<$RestaurantsTable, RestaurantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestaurantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuisineMeta = const VerificationMeta(
    'cuisine',
  );
  @override
  late final GeneratedColumn<String> cuisine = GeneratedColumn<String>(
    'cuisine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, cuisine, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restaurants';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestaurantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cuisine')) {
      context.handle(
        _cuisineMeta,
        cuisine.isAcceptableOrUnknown(data['cuisine']!, _cuisineMeta),
      );
    } else if (isInserting) {
      context.missing(_cuisineMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RestaurantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestaurantRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cuisine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuisine'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RestaurantsTable createAlias(String alias) {
    return $RestaurantsTable(attachedDatabase, alias);
  }
}

class RestaurantRow extends DataClass implements Insertable<RestaurantRow> {
  /// The server's restaurant ID.
  final String id;

  /// The display name.
  final String name;

  /// The cuisine label, such as "Thai".
  final String cuisine;

  /// The zero-based index in the server's list.
  final int position;
  const RestaurantRow({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['cuisine'] = Variable<String>(cuisine);
    map['position'] = Variable<int>(position);
    return map;
  }

  RestaurantsCompanion toCompanion(bool nullToAbsent) {
    return RestaurantsCompanion(
      id: Value(id),
      name: Value(name),
      cuisine: Value(cuisine),
      position: Value(position),
    );
  }

  factory RestaurantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestaurantRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cuisine: serializer.fromJson<String>(json['cuisine']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'cuisine': serializer.toJson<String>(cuisine),
      'position': serializer.toJson<int>(position),
    };
  }

  RestaurantRow copyWith({
    String? id,
    String? name,
    String? cuisine,
    int? position,
  }) => RestaurantRow(
    id: id ?? this.id,
    name: name ?? this.name,
    cuisine: cuisine ?? this.cuisine,
    position: position ?? this.position,
  );
  RestaurantRow copyWithCompanion(RestaurantsCompanion data) {
    return RestaurantRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cuisine: data.cuisine.present ? data.cuisine.value : this.cuisine,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestaurantRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cuisine: $cuisine, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, cuisine, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestaurantRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.cuisine == this.cuisine &&
          other.position == this.position);
}

class RestaurantsCompanion extends UpdateCompanion<RestaurantRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> cuisine;
  final Value<int> position;
  final Value<int> rowid;
  const RestaurantsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cuisine = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestaurantsCompanion.insert({
    required String id,
    required String name,
    required String cuisine,
    required int position,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       cuisine = Value(cuisine),
       position = Value(position);
  static Insertable<RestaurantRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? cuisine,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cuisine != null) 'cuisine': cuisine,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestaurantsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? cuisine,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return RestaurantsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cuisine.present) {
      map['cuisine'] = Variable<String>(cuisine.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestaurantsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cuisine: $cuisine, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenusTable extends Menus with TableInfo<$MenusTable, MenuRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenusTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES restaurants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    restaurantId,
    currency,
    etag,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menus';
  @override
  VerificationContext validateIntegrity(
    Insertable<MenuRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {restaurantId};
  @override
  MenuRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuRow(
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $MenusTable createAlias(String alias) {
    return $MenusTable(attachedDatabase, alias);
  }
}

class MenuRow extends DataClass implements Insertable<MenuRow> {
  /// The restaurant this menu belongs to.
  final String restaurantId;

  /// The ISO 4217 currency code for the menu's prices.
  final String currency;

  /// The ETag the server returned, or null if it sent none.
  final String? etag;

  /// When the menu was last fetched from the server.
  final DateTime fetchedAt;
  const MenuRow({
    required this.restaurantId,
    required this.currency,
    this.etag,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  MenusCompanion toCompanion(bool nullToAbsent) {
    return MenusCompanion(
      restaurantId: Value(restaurantId),
      currency: Value(currency),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory MenuRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuRow(
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      currency: serializer.fromJson<String>(json['currency']),
      etag: serializer.fromJson<String?>(json['etag']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'restaurantId': serializer.toJson<String>(restaurantId),
      'currency': serializer.toJson<String>(currency),
      'etag': serializer.toJson<String?>(etag),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  MenuRow copyWith({
    String? restaurantId,
    String? currency,
    Value<String?> etag = const Value.absent(),
    DateTime? fetchedAt,
  }) => MenuRow(
    restaurantId: restaurantId ?? this.restaurantId,
    currency: currency ?? this.currency,
    etag: etag.present ? etag.value : this.etag,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  MenuRow copyWithCompanion(MenusCompanion data) {
    return MenuRow(
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      currency: data.currency.present ? data.currency.value : this.currency,
      etag: data.etag.present ? data.etag.value : this.etag,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuRow(')
          ..write('restaurantId: $restaurantId, ')
          ..write('currency: $currency, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(restaurantId, currency, etag, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuRow &&
          other.restaurantId == this.restaurantId &&
          other.currency == this.currency &&
          other.etag == this.etag &&
          other.fetchedAt == this.fetchedAt);
}

class MenusCompanion extends UpdateCompanion<MenuRow> {
  final Value<String> restaurantId;
  final Value<String> currency;
  final Value<String?> etag;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const MenusCompanion({
    this.restaurantId = const Value.absent(),
    this.currency = const Value.absent(),
    this.etag = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenusCompanion.insert({
    required String restaurantId,
    required String currency,
    this.etag = const Value.absent(),
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : restaurantId = Value(restaurantId),
       currency = Value(currency),
       fetchedAt = Value(fetchedAt);
  static Insertable<MenuRow> custom({
    Expression<String>? restaurantId,
    Expression<String>? currency,
    Expression<String>? etag,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (currency != null) 'currency': currency,
      if (etag != null) 'etag': etag,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenusCompanion copyWith({
    Value<String>? restaurantId,
    Value<String>? currency,
    Value<String?>? etag,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return MenusCompanion(
      restaurantId: restaurantId ?? this.restaurantId,
      currency: currency ?? this.currency,
      etag: etag ?? this.etag,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenusCompanion(')
          ..write('restaurantId: $restaurantId, ')
          ..write('currency: $currency, ')
          ..write('etag: $etag, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenuCategoriesTable extends MenuCategories
    with TableInfo<$MenuCategoriesTable, MenuCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenuCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES menus (restaurant_id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [restaurantId, id, name, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menu_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MenuCategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {restaurantId, id};
  @override
  MenuCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuCategoryRow(
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $MenuCategoriesTable createAlias(String alias) {
    return $MenuCategoriesTable(attachedDatabase, alias);
  }
}

class MenuCategoryRow extends DataClass implements Insertable<MenuCategoryRow> {
  /// The restaurant whose menu holds this category.
  final String restaurantId;

  /// The server's category ID, unique within the menu.
  final String id;

  /// The display name.
  final String name;

  /// The zero-based index within the menu.
  final int position;
  const MenuCategoryRow({
    required this.restaurantId,
    required this.id,
    required this.name,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  MenuCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MenuCategoriesCompanion(
      restaurantId: Value(restaurantId),
      id: Value(id),
      name: Value(name),
      position: Value(position),
    );
  }

  factory MenuCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuCategoryRow(
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'restaurantId': serializer.toJson<String>(restaurantId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  MenuCategoryRow copyWith({
    String? restaurantId,
    String? id,
    String? name,
    int? position,
  }) => MenuCategoryRow(
    restaurantId: restaurantId ?? this.restaurantId,
    id: id ?? this.id,
    name: name ?? this.name,
    position: position ?? this.position,
  );
  MenuCategoryRow copyWithCompanion(MenuCategoriesCompanion data) {
    return MenuCategoryRow(
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuCategoryRow(')
          ..write('restaurantId: $restaurantId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(restaurantId, id, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuCategoryRow &&
          other.restaurantId == this.restaurantId &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position);
}

class MenuCategoriesCompanion extends UpdateCompanion<MenuCategoryRow> {
  final Value<String> restaurantId;
  final Value<String> id;
  final Value<String> name;
  final Value<int> position;
  final Value<int> rowid;
  const MenuCategoriesCompanion({
    this.restaurantId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenuCategoriesCompanion.insert({
    required String restaurantId,
    required String id,
    required String name,
    required int position,
    this.rowid = const Value.absent(),
  }) : restaurantId = Value(restaurantId),
       id = Value(id),
       name = Value(name),
       position = Value(position);
  static Insertable<MenuCategoryRow> custom({
    Expression<String>? restaurantId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenuCategoriesCompanion copyWith({
    Value<String>? restaurantId,
    Value<String>? id,
    Value<String>? name,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return MenuCategoriesCompanion(
      restaurantId: restaurantId ?? this.restaurantId,
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenuCategoriesCompanion(')
          ..write('restaurantId: $restaurantId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MenuItemsTable extends MenuItems
    with TableInfo<$MenuItemsTable, MenuItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MenuItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMinorUnitsMeta = const VerificationMeta(
    'priceMinorUnits',
  );
  @override
  late final GeneratedColumn<int> priceMinorUnits = GeneratedColumn<int>(
    'price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _availableMeta = const VerificationMeta(
    'available',
  );
  @override
  late final GeneratedColumn<bool> available = GeneratedColumn<bool>(
    'available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("available" IN (0, 1))',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    restaurantId,
    categoryId,
    id,
    name,
    description,
    priceMinorUnits,
    currency,
    available,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'menu_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MenuItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('price_minor_units')) {
      context.handle(
        _priceMinorUnitsMeta,
        priceMinorUnits.isAcceptableOrUnknown(
          data['price_minor_units']!,
          _priceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priceMinorUnitsMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('available')) {
      context.handle(
        _availableMeta,
        available.isAcceptableOrUnknown(data['available']!, _availableMeta),
      );
    } else if (isInserting) {
      context.missing(_availableMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {restaurantId, id};
  @override
  MenuItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MenuItemRow(
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      priceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_minor_units'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      available: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}available'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $MenuItemsTable createAlias(String alias) {
    return $MenuItemsTable(attachedDatabase, alias);
  }
}

class MenuItemRow extends DataClass implements Insertable<MenuItemRow> {
  /// The restaurant whose menu holds this item.
  final String restaurantId;

  /// The category this item is listed under.
  final String categoryId;

  /// The server's item ID, unique within the menu.
  final String id;

  /// The display name.
  final String name;

  /// The item's description.
  final String description;

  /// The price in the currency's minor units, such as cents.
  final int priceMinorUnits;

  /// The ISO 4217 currency code for [priceMinorUnits].
  final String currency;

  /// Whether the item can currently be ordered.
  final bool available;

  /// The zero-based index within its category.
  final int position;
  const MenuItemRow({
    required this.restaurantId,
    required this.categoryId,
    required this.id,
    required this.name,
    required this.description,
    required this.priceMinorUnits,
    required this.currency,
    required this.available,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['category_id'] = Variable<String>(categoryId);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['price_minor_units'] = Variable<int>(priceMinorUnits);
    map['currency'] = Variable<String>(currency);
    map['available'] = Variable<bool>(available);
    map['position'] = Variable<int>(position);
    return map;
  }

  MenuItemsCompanion toCompanion(bool nullToAbsent) {
    return MenuItemsCompanion(
      restaurantId: Value(restaurantId),
      categoryId: Value(categoryId),
      id: Value(id),
      name: Value(name),
      description: Value(description),
      priceMinorUnits: Value(priceMinorUnits),
      currency: Value(currency),
      available: Value(available),
      position: Value(position),
    );
  }

  factory MenuItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MenuItemRow(
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      priceMinorUnits: serializer.fromJson<int>(json['priceMinorUnits']),
      currency: serializer.fromJson<String>(json['currency']),
      available: serializer.fromJson<bool>(json['available']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'restaurantId': serializer.toJson<String>(restaurantId),
      'categoryId': serializer.toJson<String>(categoryId),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'priceMinorUnits': serializer.toJson<int>(priceMinorUnits),
      'currency': serializer.toJson<String>(currency),
      'available': serializer.toJson<bool>(available),
      'position': serializer.toJson<int>(position),
    };
  }

  MenuItemRow copyWith({
    String? restaurantId,
    String? categoryId,
    String? id,
    String? name,
    String? description,
    int? priceMinorUnits,
    String? currency,
    bool? available,
    int? position,
  }) => MenuItemRow(
    restaurantId: restaurantId ?? this.restaurantId,
    categoryId: categoryId ?? this.categoryId,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    priceMinorUnits: priceMinorUnits ?? this.priceMinorUnits,
    currency: currency ?? this.currency,
    available: available ?? this.available,
    position: position ?? this.position,
  );
  MenuItemRow copyWithCompanion(MenuItemsCompanion data) {
    return MenuItemRow(
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      priceMinorUnits: data.priceMinorUnits.present
          ? data.priceMinorUnits.value
          : this.priceMinorUnits,
      currency: data.currency.present ? data.currency.value : this.currency,
      available: data.available.present ? data.available.value : this.available,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MenuItemRow(')
          ..write('restaurantId: $restaurantId, ')
          ..write('categoryId: $categoryId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('priceMinorUnits: $priceMinorUnits, ')
          ..write('currency: $currency, ')
          ..write('available: $available, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    restaurantId,
    categoryId,
    id,
    name,
    description,
    priceMinorUnits,
    currency,
    available,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuItemRow &&
          other.restaurantId == this.restaurantId &&
          other.categoryId == this.categoryId &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.priceMinorUnits == this.priceMinorUnits &&
          other.currency == this.currency &&
          other.available == this.available &&
          other.position == this.position);
}

class MenuItemsCompanion extends UpdateCompanion<MenuItemRow> {
  final Value<String> restaurantId;
  final Value<String> categoryId;
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> priceMinorUnits;
  final Value<String> currency;
  final Value<bool> available;
  final Value<int> position;
  final Value<int> rowid;
  const MenuItemsCompanion({
    this.restaurantId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.priceMinorUnits = const Value.absent(),
    this.currency = const Value.absent(),
    this.available = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MenuItemsCompanion.insert({
    required String restaurantId,
    required String categoryId,
    required String id,
    required String name,
    required String description,
    required int priceMinorUnits,
    required String currency,
    required bool available,
    required int position,
    this.rowid = const Value.absent(),
  }) : restaurantId = Value(restaurantId),
       categoryId = Value(categoryId),
       id = Value(id),
       name = Value(name),
       description = Value(description),
       priceMinorUnits = Value(priceMinorUnits),
       currency = Value(currency),
       available = Value(available),
       position = Value(position);
  static Insertable<MenuItemRow> custom({
    Expression<String>? restaurantId,
    Expression<String>? categoryId,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? priceMinorUnits,
    Expression<String>? currency,
    Expression<bool>? available,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (categoryId != null) 'category_id': categoryId,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (priceMinorUnits != null) 'price_minor_units': priceMinorUnits,
      if (currency != null) 'currency': currency,
      if (available != null) 'available': available,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MenuItemsCompanion copyWith({
    Value<String>? restaurantId,
    Value<String>? categoryId,
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? priceMinorUnits,
    Value<String>? currency,
    Value<bool>? available,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return MenuItemsCompanion(
      restaurantId: restaurantId ?? this.restaurantId,
      categoryId: categoryId ?? this.categoryId,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceMinorUnits: priceMinorUnits ?? this.priceMinorUnits,
      currency: currency ?? this.currency,
      available: available ?? this.available,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priceMinorUnits.present) {
      map['price_minor_units'] = Variable<int>(priceMinorUnits.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (available.present) {
      map['available'] = Variable<bool>(available.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MenuItemsCompanion(')
          ..write('restaurantId: $restaurantId, ')
          ..write('categoryId: $categoryId, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('priceMinorUnits: $priceMinorUnits, ')
          ..write('currency: $currency, ')
          ..write('available: $available, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CartLinesTable extends CartLines
    with TableInfo<$CartLinesTable, CartLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CartLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMinorUnitsMeta =
      const VerificationMeta('unitPriceMinorUnits');
  @override
  late final GeneratedColumn<int> unitPriceMinorUnits = GeneratedColumn<int>(
    'unit_price_minor_units',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    itemId,
    name,
    unitPriceMinorUnits,
    currency,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cart_lines';
  @override
  VerificationContext validateIntegrity(
    Insertable<CartLineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit_price_minor_units')) {
      context.handle(
        _unitPriceMinorUnitsMeta,
        unitPriceMinorUnits.isAcceptableOrUnknown(
          data['unit_price_minor_units']!,
          _unitPriceMinorUnitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorUnitsMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {restaurantId, itemId},
  ];
  @override
  CartLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CartLineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unitPriceMinorUnits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor_units'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $CartLinesTable createAlias(String alias) {
    return $CartLinesTable(attachedDatabase, alias);
  }
}

class CartLineRow extends DataClass implements Insertable<CartLineRow> {
  /// The local database ID for this cart line.
  final int id;

  /// The restaurant that offers the cart item.
  final String restaurantId;

  /// The server's item ID in the restaurant's menu.
  final String itemId;

  /// The display name of the cart item.
  final String name;

  /// The item's unit price in the currency's minor units.
  final int unitPriceMinorUnits;

  /// The ISO 4217 currency code for the unit price.
  final String currency;

  /// The number of units of this item in the cart.
  final int quantity;
  const CartLineRow({
    required this.id,
    required this.restaurantId,
    required this.itemId,
    required this.name,
    required this.unitPriceMinorUnits,
    required this.currency,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['item_id'] = Variable<String>(itemId);
    map['name'] = Variable<String>(name);
    map['unit_price_minor_units'] = Variable<int>(unitPriceMinorUnits);
    map['currency'] = Variable<String>(currency);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  CartLinesCompanion toCompanion(bool nullToAbsent) {
    return CartLinesCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      itemId: Value(itemId),
      name: Value(name),
      unitPriceMinorUnits: Value(unitPriceMinorUnits),
      currency: Value(currency),
      quantity: Value(quantity),
    );
  }

  factory CartLineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CartLineRow(
      id: serializer.fromJson<int>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      name: serializer.fromJson<String>(json['name']),
      unitPriceMinorUnits: serializer.fromJson<int>(
        json['unitPriceMinorUnits'],
      ),
      currency: serializer.fromJson<String>(json['currency']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'itemId': serializer.toJson<String>(itemId),
      'name': serializer.toJson<String>(name),
      'unitPriceMinorUnits': serializer.toJson<int>(unitPriceMinorUnits),
      'currency': serializer.toJson<String>(currency),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  CartLineRow copyWith({
    int? id,
    String? restaurantId,
    String? itemId,
    String? name,
    int? unitPriceMinorUnits,
    String? currency,
    int? quantity,
  }) => CartLineRow(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    itemId: itemId ?? this.itemId,
    name: name ?? this.name,
    unitPriceMinorUnits: unitPriceMinorUnits ?? this.unitPriceMinorUnits,
    currency: currency ?? this.currency,
    quantity: quantity ?? this.quantity,
  );
  CartLineRow copyWithCompanion(CartLinesCompanion data) {
    return CartLineRow(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      name: data.name.present ? data.name.value : this.name,
      unitPriceMinorUnits: data.unitPriceMinorUnits.present
          ? data.unitPriceMinorUnits.value
          : this.unitPriceMinorUnits,
      currency: data.currency.present ? data.currency.value : this.currency,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CartLineRow(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('itemId: $itemId, ')
          ..write('name: $name, ')
          ..write('unitPriceMinorUnits: $unitPriceMinorUnits, ')
          ..write('currency: $currency, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    restaurantId,
    itemId,
    name,
    unitPriceMinorUnits,
    currency,
    quantity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CartLineRow &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.itemId == this.itemId &&
          other.name == this.name &&
          other.unitPriceMinorUnits == this.unitPriceMinorUnits &&
          other.currency == this.currency &&
          other.quantity == this.quantity);
}

class CartLinesCompanion extends UpdateCompanion<CartLineRow> {
  final Value<int> id;
  final Value<String> restaurantId;
  final Value<String> itemId;
  final Value<String> name;
  final Value<int> unitPriceMinorUnits;
  final Value<String> currency;
  final Value<int> quantity;
  const CartLinesCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.name = const Value.absent(),
    this.unitPriceMinorUnits = const Value.absent(),
    this.currency = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  CartLinesCompanion.insert({
    this.id = const Value.absent(),
    required String restaurantId,
    required String itemId,
    required String name,
    required int unitPriceMinorUnits,
    required String currency,
    required int quantity,
  }) : restaurantId = Value(restaurantId),
       itemId = Value(itemId),
       name = Value(name),
       unitPriceMinorUnits = Value(unitPriceMinorUnits),
       currency = Value(currency),
       quantity = Value(quantity);
  static Insertable<CartLineRow> custom({
    Expression<int>? id,
    Expression<String>? restaurantId,
    Expression<String>? itemId,
    Expression<String>? name,
    Expression<int>? unitPriceMinorUnits,
    Expression<String>? currency,
    Expression<int>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (itemId != null) 'item_id': itemId,
      if (name != null) 'name': name,
      if (unitPriceMinorUnits != null)
        'unit_price_minor_units': unitPriceMinorUnits,
      if (currency != null) 'currency': currency,
      if (quantity != null) 'quantity': quantity,
    });
  }

  CartLinesCompanion copyWith({
    Value<int>? id,
    Value<String>? restaurantId,
    Value<String>? itemId,
    Value<String>? name,
    Value<int>? unitPriceMinorUnits,
    Value<String>? currency,
    Value<int>? quantity,
  }) {
    return CartLinesCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      unitPriceMinorUnits: unitPriceMinorUnits ?? this.unitPriceMinorUnits,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unitPriceMinorUnits.present) {
      map['unit_price_minor_units'] = Variable<int>(unitPriceMinorUnits.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartLinesCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('itemId: $itemId, ')
          ..write('name: $name, ')
          ..write('unitPriceMinorUnits: $unitPriceMinorUnits, ')
          ..write('currency: $currency, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

abstract class _$CraveDatabase extends GeneratedDatabase {
  _$CraveDatabase(QueryExecutor e) : super(e);
  $CraveDatabaseManager get managers => $CraveDatabaseManager(this);
  late final $RestaurantsTable restaurants = $RestaurantsTable(this);
  late final $MenusTable menus = $MenusTable(this);
  late final $MenuCategoriesTable menuCategories = $MenuCategoriesTable(this);
  late final $MenuItemsTable menuItems = $MenuItemsTable(this);
  late final $CartLinesTable cartLines = $CartLinesTable(this);
  late final MenuDao menuDao = MenuDao(this as CraveDatabase);
  late final CartDao cartDao = CartDao(this as CraveDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    restaurants,
    menus,
    menuCategories,
    menuItems,
    cartLines,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'restaurants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('menus', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'menus',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('menu_categories', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$RestaurantsTableCreateCompanionBuilder =
    RestaurantsCompanion Function({
      required String id,
      required String name,
      required String cuisine,
      required int position,
      Value<int> rowid,
    });
typedef $$RestaurantsTableUpdateCompanionBuilder =
    RestaurantsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> cuisine,
      Value<int> position,
      Value<int> rowid,
    });

final class $$RestaurantsTableReferences
    extends BaseReferences<_$CraveDatabase, $RestaurantsTable, RestaurantRow> {
  $$RestaurantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MenusTable, List<MenuRow>> _menusRefsTable(
    _$CraveDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.menus,
    aliasName: 'restaurants__id__menus__restaurant_id',
  );

  $$MenusTableProcessedTableManager get menusRefs {
    final manager = $$MenusTableTableManager(
      $_db,
      $_db.menus,
    ).filter((f) => f.restaurantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_menusRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RestaurantsTableFilterComposer
    extends Composer<_$CraveDatabase, $RestaurantsTable> {
  $$RestaurantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuisine => $composableBuilder(
    column: $table.cuisine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> menusRefs(
    Expression<bool> Function($$MenusTableFilterComposer f) f,
  ) {
    final $$MenusTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.menus,
      getReferencedColumn: (t) => t.restaurantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MenusTableFilterComposer(
            $db: $db,
            $table: $db.menus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RestaurantsTableOrderingComposer
    extends Composer<_$CraveDatabase, $RestaurantsTable> {
  $$RestaurantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuisine => $composableBuilder(
    column: $table.cuisine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RestaurantsTableAnnotationComposer
    extends Composer<_$CraveDatabase, $RestaurantsTable> {
  $$RestaurantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get cuisine =>
      $composableBuilder(column: $table.cuisine, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> menusRefs<T extends Object>(
    Expression<T> Function($$MenusTableAnnotationComposer a) f,
  ) {
    final $$MenusTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.menus,
      getReferencedColumn: (t) => t.restaurantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MenusTableAnnotationComposer(
            $db: $db,
            $table: $db.menus,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RestaurantsTableTableManager
    extends
        RootTableManager<
          _$CraveDatabase,
          $RestaurantsTable,
          RestaurantRow,
          $$RestaurantsTableFilterComposer,
          $$RestaurantsTableOrderingComposer,
          $$RestaurantsTableAnnotationComposer,
          $$RestaurantsTableCreateCompanionBuilder,
          $$RestaurantsTableUpdateCompanionBuilder,
          (RestaurantRow, $$RestaurantsTableReferences),
          RestaurantRow,
          PrefetchHooks Function({bool menusRefs})
        > {
  $$RestaurantsTableTableManager(_$CraveDatabase db, $RestaurantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestaurantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestaurantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestaurantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> cuisine = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestaurantsCompanion(
                id: id,
                name: name,
                cuisine: cuisine,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String cuisine,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => RestaurantsCompanion.insert(
                id: id,
                name: name,
                cuisine: cuisine,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RestaurantsTable, RestaurantRow>(table),
                  $$RestaurantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({menusRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (menusRefs) db.menus],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (menusRefs)
                    await $_getPrefetchedDataByColumns<
                      RestaurantRow,
                      $RestaurantsTable,
                      MenuRow,
                      $MenusTable
                    >(
                      currentTable: table,
                      referencedTable: $$RestaurantsTableReferences
                          ._menusRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RestaurantsTableReferences(db, table, p0).menusRefs,
                      currentColumn: 'id',
                      referencedColumn: 'restaurant_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RestaurantsTableProcessedTableManager =
    ProcessedTableManager<
      _$CraveDatabase,
      $RestaurantsTable,
      RestaurantRow,
      $$RestaurantsTableFilterComposer,
      $$RestaurantsTableOrderingComposer,
      $$RestaurantsTableAnnotationComposer,
      $$RestaurantsTableCreateCompanionBuilder,
      $$RestaurantsTableUpdateCompanionBuilder,
      (RestaurantRow, $$RestaurantsTableReferences),
      RestaurantRow,
      PrefetchHooks Function({bool menusRefs})
    >;
typedef $$MenusTableCreateCompanionBuilder = MenusCompanion Function({
  required String restaurantId,
  required String currency,
  Value<String?> etag,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$MenusTableUpdateCompanionBuilder = MenusCompanion Function({
  Value<String> restaurantId,
  Value<String> currency,
  Value<String?> etag,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

final class $$MenusTableReferences
    extends BaseReferences<_$CraveDatabase, $MenusTable, MenuRow> {
  $$MenusTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RestaurantsTable _restaurantIdTable(_$CraveDatabase db) =>
      db.restaurants.createAlias('menus__restaurant_id__restaurants__id');

  $$RestaurantsTableProcessedTableManager get restaurantId {
    final $_column = $_itemColumn<String>('restaurant_id')!;

    final manager = $$RestaurantsTableTableManager(
      $_db,
      $_db.restaurants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_restaurantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MenusTableFilterComposer
    extends Composer<_$CraveDatabase, $MenusTable> {
  $$MenusTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RestaurantsTableFilterComposer get restaurantId {
    final $$RestaurantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restaurantId,
      referencedTable: $db.restaurants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantsTableFilterComposer(
            $db: $db,
            $table: $db.restaurants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MenusTableOrderingComposer
    extends Composer<_$CraveDatabase, $MenusTable> {
  $$MenusTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RestaurantsTableOrderingComposer get restaurantId {
    final $$RestaurantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restaurantId,
      referencedTable: $db.restaurants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantsTableOrderingComposer(
            $db: $db,
            $table: $db.restaurants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MenusTableAnnotationComposer
    extends Composer<_$CraveDatabase, $MenusTable> {
  $$MenusTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$RestaurantsTableAnnotationComposer get restaurantId {
    final $$RestaurantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restaurantId,
      referencedTable: $db.restaurants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestaurantsTableAnnotationComposer(
            $db: $db,
            $table: $db.restaurants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MenusTableTableManager
    extends
        RootTableManager<
          _$CraveDatabase,
          $MenusTable,
          MenuRow,
          $$MenusTableFilterComposer,
          $$MenusTableOrderingComposer,
          $$MenusTableAnnotationComposer,
          $$MenusTableCreateCompanionBuilder,
          $$MenusTableUpdateCompanionBuilder,
          (MenuRow, $$MenusTableReferences),
          MenuRow,
          PrefetchHooks Function({bool restaurantId})
        > {
  $$MenusTableTableManager(_$CraveDatabase db, $MenusTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenusTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenusTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenusTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> restaurantId = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MenusCompanion(
                restaurantId: restaurantId,
                currency: currency,
                etag: etag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String restaurantId,
                required String currency,
                Value<String?> etag = const Value.absent(),
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => MenusCompanion.insert(
                restaurantId: restaurantId,
                currency: currency,
                etag: etag,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MenusTable, MenuRow>(table),
                  $$MenusTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({restaurantId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (restaurantId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.restaurantId,
                        referencedTable: $$MenusTableReferences
                            ._restaurantIdTable(db),
                        referencedColumn: $$MenusTableReferences
                            ._restaurantIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MenusTableProcessedTableManager =
    ProcessedTableManager<
      _$CraveDatabase,
      $MenusTable,
      MenuRow,
      $$MenusTableFilterComposer,
      $$MenusTableOrderingComposer,
      $$MenusTableAnnotationComposer,
      $$MenusTableCreateCompanionBuilder,
      $$MenusTableUpdateCompanionBuilder,
      (MenuRow, $$MenusTableReferences),
      MenuRow,
      PrefetchHooks Function({bool restaurantId})
    >;
typedef $$MenuCategoriesTableCreateCompanionBuilder =
    MenuCategoriesCompanion Function({
      required String restaurantId,
      required String id,
      required String name,
      required int position,
      Value<int> rowid,
    });
typedef $$MenuCategoriesTableUpdateCompanionBuilder =
    MenuCategoriesCompanion Function({
      Value<String> restaurantId,
      Value<String> id,
      Value<String> name,
      Value<int> position,
      Value<int> rowid,
    });

class $$MenuCategoriesTableFilterComposer
    extends Composer<_$CraveDatabase, $MenuCategoriesTable> {
  $$MenuCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MenuCategoriesTableOrderingComposer
    extends Composer<_$CraveDatabase, $MenuCategoriesTable> {
  $$MenuCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MenuCategoriesTableAnnotationComposer
    extends Composer<_$CraveDatabase, $MenuCategoriesTable> {
  $$MenuCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$MenuCategoriesTableTableManager
    extends
        RootTableManager<
          _$CraveDatabase,
          $MenuCategoriesTable,
          MenuCategoryRow,
          $$MenuCategoriesTableFilterComposer,
          $$MenuCategoriesTableOrderingComposer,
          $$MenuCategoriesTableAnnotationComposer,
          $$MenuCategoriesTableCreateCompanionBuilder,
          $$MenuCategoriesTableUpdateCompanionBuilder,
          (
            MenuCategoryRow,
            BaseReferences<
              _$CraveDatabase,
              $MenuCategoriesTable,
              MenuCategoryRow
            >,
          ),
          MenuCategoryRow,
          PrefetchHooks Function()
        > {
  $$MenuCategoriesTableTableManager(
    _$CraveDatabase db,
    $MenuCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenuCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenuCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenuCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> restaurantId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MenuCategoriesCompanion(
                restaurantId: restaurantId,
                id: id,
                name: name,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String restaurantId,
                required String id,
                required String name,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => MenuCategoriesCompanion.insert(
                restaurantId: restaurantId,
                id: id,
                name: name,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MenuCategoriesTable, MenuCategoryRow>(table),
                  BaseReferences<
                    _$CraveDatabase,
                    $MenuCategoriesTable,
                    MenuCategoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MenuCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$CraveDatabase,
      $MenuCategoriesTable,
      MenuCategoryRow,
      $$MenuCategoriesTableFilterComposer,
      $$MenuCategoriesTableOrderingComposer,
      $$MenuCategoriesTableAnnotationComposer,
      $$MenuCategoriesTableCreateCompanionBuilder,
      $$MenuCategoriesTableUpdateCompanionBuilder,
      (
        MenuCategoryRow,
        BaseReferences<_$CraveDatabase, $MenuCategoriesTable, MenuCategoryRow>,
      ),
      MenuCategoryRow,
      PrefetchHooks Function()
    >;
typedef $$MenuItemsTableCreateCompanionBuilder = MenuItemsCompanion Function({
  required String restaurantId,
  required String categoryId,
  required String id,
  required String name,
  required String description,
  required int priceMinorUnits,
  required String currency,
  required bool available,
  required int position,
  Value<int> rowid,
});
typedef $$MenuItemsTableUpdateCompanionBuilder = MenuItemsCompanion Function({
  Value<String> restaurantId,
  Value<String> categoryId,
  Value<String> id,
  Value<String> name,
  Value<String> description,
  Value<int> priceMinorUnits,
  Value<String> currency,
  Value<bool> available,
  Value<int> position,
  Value<int> rowid,
});

class $$MenuItemsTableFilterComposer
    extends Composer<_$CraveDatabase, $MenuItemsTable> {
  $$MenuItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceMinorUnits => $composableBuilder(
    column: $table.priceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MenuItemsTableOrderingComposer
    extends Composer<_$CraveDatabase, $MenuItemsTable> {
  $$MenuItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceMinorUnits => $composableBuilder(
    column: $table.priceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get available => $composableBuilder(
    column: $table.available,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MenuItemsTableAnnotationComposer
    extends Composer<_$CraveDatabase, $MenuItemsTable> {
  $$MenuItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceMinorUnits => $composableBuilder(
    column: $table.priceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get available =>
      $composableBuilder(column: $table.available, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$MenuItemsTableTableManager
    extends
        RootTableManager<
          _$CraveDatabase,
          $MenuItemsTable,
          MenuItemRow,
          $$MenuItemsTableFilterComposer,
          $$MenuItemsTableOrderingComposer,
          $$MenuItemsTableAnnotationComposer,
          $$MenuItemsTableCreateCompanionBuilder,
          $$MenuItemsTableUpdateCompanionBuilder,
          (
            MenuItemRow,
            BaseReferences<_$CraveDatabase, $MenuItemsTable, MenuItemRow>,
          ),
          MenuItemRow,
          PrefetchHooks Function()
        > {
  $$MenuItemsTableTableManager(_$CraveDatabase db, $MenuItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MenuItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MenuItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MenuItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> restaurantId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> priceMinorUnits = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<bool> available = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MenuItemsCompanion(
                restaurantId: restaurantId,
                categoryId: categoryId,
                id: id,
                name: name,
                description: description,
                priceMinorUnits: priceMinorUnits,
                currency: currency,
                available: available,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String restaurantId,
                required String categoryId,
                required String id,
                required String name,
                required String description,
                required int priceMinorUnits,
                required String currency,
                required bool available,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => MenuItemsCompanion.insert(
                restaurantId: restaurantId,
                categoryId: categoryId,
                id: id,
                name: name,
                description: description,
                priceMinorUnits: priceMinorUnits,
                currency: currency,
                available: available,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MenuItemsTable, MenuItemRow>(table),
                  BaseReferences<_$CraveDatabase, $MenuItemsTable, MenuItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MenuItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$CraveDatabase,
      $MenuItemsTable,
      MenuItemRow,
      $$MenuItemsTableFilterComposer,
      $$MenuItemsTableOrderingComposer,
      $$MenuItemsTableAnnotationComposer,
      $$MenuItemsTableCreateCompanionBuilder,
      $$MenuItemsTableUpdateCompanionBuilder,
      (
        MenuItemRow,
        BaseReferences<_$CraveDatabase, $MenuItemsTable, MenuItemRow>,
      ),
      MenuItemRow,
      PrefetchHooks Function()
    >;
typedef $$CartLinesTableCreateCompanionBuilder = CartLinesCompanion Function({
  Value<int> id,
  required String restaurantId,
  required String itemId,
  required String name,
  required int unitPriceMinorUnits,
  required String currency,
  required int quantity,
});
typedef $$CartLinesTableUpdateCompanionBuilder = CartLinesCompanion Function({
  Value<int> id,
  Value<String> restaurantId,
  Value<String> itemId,
  Value<String> name,
  Value<int> unitPriceMinorUnits,
  Value<String> currency,
  Value<int> quantity,
});

class $$CartLinesTableFilterComposer
    extends Composer<_$CraveDatabase, $CartLinesTable> {
  $$CartLinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinorUnits => $composableBuilder(
    column: $table.unitPriceMinorUnits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CartLinesTableOrderingComposer
    extends Composer<_$CraveDatabase, $CartLinesTable> {
  $$CartLinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinorUnits => $composableBuilder(
    column: $table.unitPriceMinorUnits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CartLinesTableAnnotationComposer
    extends Composer<_$CraveDatabase, $CartLinesTable> {
  $$CartLinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinorUnits => $composableBuilder(
    column: $table.unitPriceMinorUnits,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$CartLinesTableTableManager
    extends
        RootTableManager<
          _$CraveDatabase,
          $CartLinesTable,
          CartLineRow,
          $$CartLinesTableFilterComposer,
          $$CartLinesTableOrderingComposer,
          $$CartLinesTableAnnotationComposer,
          $$CartLinesTableCreateCompanionBuilder,
          $$CartLinesTableUpdateCompanionBuilder,
          (
            CartLineRow,
            BaseReferences<_$CraveDatabase, $CartLinesTable, CartLineRow>,
          ),
          CartLineRow,
          PrefetchHooks Function()
        > {
  $$CartLinesTableTableManager(_$CraveDatabase db, $CartLinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CartLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CartLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CartLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> unitPriceMinorUnits = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> quantity = const Value.absent(),
              }) => CartLinesCompanion(
                id: id,
                restaurantId: restaurantId,
                itemId: itemId,
                name: name,
                unitPriceMinorUnits: unitPriceMinorUnits,
                currency: currency,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String restaurantId,
                required String itemId,
                required String name,
                required int unitPriceMinorUnits,
                required String currency,
                required int quantity,
              }) => CartLinesCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                itemId: itemId,
                name: name,
                unitPriceMinorUnits: unitPriceMinorUnits,
                currency: currency,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CartLinesTable, CartLineRow>(table),
                  BaseReferences<_$CraveDatabase, $CartLinesTable, CartLineRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CartLinesTableProcessedTableManager =
    ProcessedTableManager<
      _$CraveDatabase,
      $CartLinesTable,
      CartLineRow,
      $$CartLinesTableFilterComposer,
      $$CartLinesTableOrderingComposer,
      $$CartLinesTableAnnotationComposer,
      $$CartLinesTableCreateCompanionBuilder,
      $$CartLinesTableUpdateCompanionBuilder,
      (
        CartLineRow,
        BaseReferences<_$CraveDatabase, $CartLinesTable, CartLineRow>,
      ),
      CartLineRow,
      PrefetchHooks Function()
    >;

class $CraveDatabaseManager {
  final _$CraveDatabase _db;
  $CraveDatabaseManager(this._db);
  $$RestaurantsTableTableManager get restaurants =>
      $$RestaurantsTableTableManager(_db, _db.restaurants);
  $$MenusTableTableManager get menus =>
      $$MenusTableTableManager(_db, _db.menus);
  $$MenuCategoriesTableTableManager get menuCategories =>
      $$MenuCategoriesTableTableManager(_db, _db.menuCategories);
  $$MenuItemsTableTableManager get menuItems =>
      $$MenuItemsTableTableManager(_db, _db.menuItems);
  $$CartLinesTableTableManager get cartLines =>
      $$CartLinesTableTableManager(_db, _db.cartLines);
}
