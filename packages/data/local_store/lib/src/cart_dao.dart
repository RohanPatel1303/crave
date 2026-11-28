import 'package:drift/drift.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:local_store/src/stored_cart.dart';
import 'package:local_store/src/tables.dart';

part 'cart_dao.g.dart';

/// Reads and writes the cart.
///
/// It takes and returns only the plain [StoredCartLine] and [NewCartLine]
/// classes. Each item has at most one line, and lines keep the order in
/// which they were first added.
@DriftAccessor(tables: [CartLines])
class CartDao extends DatabaseAccessor<CraveDatabase> with _$CartDaoMixin {
  /// Creates a DAO bound to [db].
  CartDao(super.db);

  /// Emits the cart lines in the order first added, and again after each
  /// change.
  Stream<List<StoredCartLine>> watchLines() {
    final query = select(cartLines)..orderBy([(l) => OrderingTerm.asc(l.id)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          StoredCartLine(
            restaurantId: row.restaurantId,
            itemId: row.itemId,
            name: row.name,
            unitPriceMinorUnits: row.unitPriceMinorUnits,
            currency: row.currency,
            quantity: row.quantity,
          ),
      ],
    );
  }

  /// Adds one unit of [line]'s item, inserting a line with quantity 1 or
  /// incrementing the existing line's quantity.
  ///
  /// This is a single upsert, so concurrent calls never lose an increment.
  /// An existing line keeps its position, name and price. Throws a
  /// `SqliteException` if the line already has the maximum quantity of 99.
  Future<void> addOne(NewCartLine line) async {
    await into(cartLines).insert(
      CartLinesCompanion.insert(
        restaurantId: line.restaurantId,
        itemId: line.itemId,
        name: line.name,
        unitPriceMinorUnits: line.unitPriceMinorUnits,
        currency: line.currency,
        quantity: 1,
      ),
      onConflict: DoUpdate(
        (old) => CartLinesCompanion.custom(
          quantity: old.quantity + const Constant(1),
        ),
        target: [cartLines.restaurantId, cartLines.itemId],
      ),
    );
  }

  /// Sets the quantity of the line for [itemId] from [restaurantId].
  ///
  /// A [quantity] of 0 deletes the line. Does nothing if there is no such
  /// line. Throws an [ArgumentError] if [quantity] is below 0 or above 99.
  Future<void> setQuantity(
    String restaurantId,
    String itemId,
    int quantity,
  ) async {
    RangeError.checkValueInInterval(quantity, 0, 99, 'quantity');
    if (quantity == 0) {
      await (delete(
        cartLines,
      )..where((l) => _matches(l, restaurantId, itemId))).go();
      return;
    }
    await (update(cartLines)..where((l) => _matches(l, restaurantId, itemId)))
        .write(CartLinesCompanion(quantity: Value(quantity)));
  }

  /// Removes every line from the cart.
  Future<void> clear() async {
    await delete(cartLines).go();
  }

  /// Replaces the whole cart with one unit of [line], in one transaction,
  /// so watchers never see an empty cart in between.
  Future<void> replaceWith(NewCartLine line) {
    return transaction(() async {
      await clear();
      await addOne(line);
    });
  }

  /// Adds one unit of [line] with [addOne], unless the cart holds items from
  /// another restaurant.
  ///
  /// Returns that other restaurant's ID and writes nothing when the cart's
  /// first line is from a different restaurant; otherwise adds the line and
  /// returns null. The check and the insert happen in one transaction, so
  /// concurrent calls can never leave two restaurants in the cart. Like
  /// [addOne], throws a `SqliteException` if the line already has the
  /// maximum quantity of 99.
  Future<String?> addOneIfSameRestaurant(NewCartLine line) {
    return transaction(() async {
      final first =
          await (select(cartLines)
                ..orderBy([(l) => OrderingTerm.asc(l.id)])
                ..limit(1))
              .getSingleOrNull();
      if (first != null && first.restaurantId != line.restaurantId) {
        return first.restaurantId;
      }
      await addOne(line);
      return null;
    });
  }

  Expression<bool> _matches(
    $CartLinesTable l,
    String restaurantId,
    String itemId,
  ) => l.restaurantId.equals(restaurantId) & l.itemId.equals(itemId);
}
