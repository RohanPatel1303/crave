import 'package:local_store/testing.dart';
import 'package:test/test.dart';

void main() {
  test('inMemoryCraveDatabase opens an empty database', () async {
    final db = inMemoryCraveDatabase();
    addTearDown(db.close);

    expect(await db.menuDao.watchRestaurants().first, isEmpty);
  });
}
