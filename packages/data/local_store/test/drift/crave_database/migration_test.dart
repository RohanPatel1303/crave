// dart format width=80
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:local_store/src/crave_database.dart';
import 'package:test/test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = CraveDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migrating from v1 to v2 keeps restaurants and menus and adds an '
      'empty cart', () async {
    const oldRestaurant = v1.RestaurantsData(
      id: 'r1',
      name: 'Thai Garden',
      cuisine: 'Thai',
      position: 0,
    );
    const oldMenu = v1.MenusData(
      restaurantId: 'r1',
      currency: 'USD',
      etag: '"abc"',
      fetchedAt: 1700000000,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: CraveDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insert(oldDb.restaurants, oldRestaurant)
          ..insert(oldDb.menus, oldMenu);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.restaurants).get(), [
          const v2.RestaurantsData(
            id: 'r1',
            name: 'Thai Garden',
            cuisine: 'Thai',
            position: 0,
          ),
        ]);
        expect(await newDb.select(newDb.menus).get(), [
          const v2.MenusData(
            restaurantId: 'r1',
            currency: 'USD',
            etag: '"abc"',
            fetchedAt: 1700000000,
          ),
        ]);
        expect(await newDb.select(newDb.cartLines).get(), isEmpty);
      },
    );
  });
}
