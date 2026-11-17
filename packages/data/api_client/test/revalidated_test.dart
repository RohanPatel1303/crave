import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

void main() {
  group('Fresh', () {
    test('is equal when value and etag are equal', () {
      const a = Fresh('menu', etag: '"v1"');
      const b = Fresh('menu', etag: '"v1"');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const Fresh('menu', etag: '"v2"')));
      expect(a, isNot(const Fresh('other', etag: '"v1"')));
    });

    test('describes its value and etag', () {
      expect(
        const Fresh('menu', etag: '"v1"').toString(),
        'Fresh(menu, etag: "v1")',
      );
    });
  });

  group('NotModified', () {
    test('is equal to another NotModified of the same type', () {
      expect(const NotModified<String>(), const NotModified<String>());
      expect(
        const NotModified<String>().hashCode,
        const NotModified<String>().hashCode,
      );
      expect(const NotModified<String>(), isNot(const NotModified<int>()));
    });

    test('is not equal to Fresh', () {
      expect(
        const NotModified<String>(),
        isNot(const Fresh('menu', etag: null)),
      );
    });

    test('describes itself', () {
      expect(const NotModified<String>().toString(), 'NotModified()');
    });
  });
}
