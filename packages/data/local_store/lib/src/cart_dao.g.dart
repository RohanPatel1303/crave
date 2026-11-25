// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_dao.dart';

// ignore_for_file: type=lint
mixin _$CartDaoMixin on DatabaseAccessor<CraveDatabase> {
  $CartLinesTable get cartLines => attachedDatabase.cartLines;
  CartDaoManager get managers => CartDaoManager(this);
}

class CartDaoManager {
  final _$CartDaoMixin _db;
  CartDaoManager(this._db);
  $$CartLinesTableTableManager get cartLines =>
      $$CartLinesTableTableManager(_db.attachedDatabase, _db.cartLines);
}
