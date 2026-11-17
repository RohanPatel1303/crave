import 'dart:convert';
import 'dart:io';

import 'package:api_client/api_client.dart';
import 'package:api_client/testing.dart';
import 'package:core/core.dart';
import 'package:test/test.dart';

/// The examples from docs/api.md, copied verbatim.
Map<String, Object?> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, Object?>;

final _restaurantsJson = _fixture('restaurants');
final _menuJson = _fixture('menu');

/// A deep copy of [json], so a test can change it freely.
Map<String, Object?> _copy(Map<String, Object?> json) =>
    jsonDecode(jsonEncode(json)) as Map<String, Object?>;

/// The map at [path] inside [json], where ints index into lists.
Map<String, Object?> _at(Map<String, Object?> json, List<Object> path) {
  Object? node = json;
  for (final step in path) {
    node = switch (step) {
      final int index => (node! as List<Object?>)[index],
      final String key => (node! as Map<String, Object?>)[key],
      _ => throw ArgumentError.value(step, 'path'),
    };
  }
  return node! as Map<String, Object?>;
}

/// Every object in the menu fixture, with the fields it must have.
const _menuObjects = <(List<Object>, List<String>)>[
  ([], ['restaurantId', 'currency', 'categories']),
  (['categories', 0], ['id', 'name', 'items']),
  (
    ['categories', 0, 'items', 0],
    ['id', 'name', 'description', 'price', 'available'],
  ),
  (['categories', 0, 'items', 0, 'price'], ['minorUnits', 'currency']),
];

final _isFormatFailure = isA<UnexpectedFailure>().having(
  (failure) => failure.cause,
  'cause',
  isA<FormatException>(),
);

void main() {
  late Object? body;
  late FakeApiServer server;

  setUp(() {
    body = null;
    server = FakeApiServer((method, path) => FakeResponse(200, body));
  });

  group('restaurants', () {
    test('parses the docs/api.md example', () async {
      body = _restaurantsJson;

      final result = await server.client.restaurants();

      expect(result, isA<Ok<List<ApiRestaurant>>>());
      expect(result.valueOrNull, const [
        ApiRestaurant(
          id: 'taqueria-sol',
          name: 'Taqueria Sol',
          cuisine: 'Mexican',
        ),
      ]);
      expect(server.requests, ['GET /restaurants']);
    });

    for (final field in ['id', 'name', 'cuisine']) {
      test('a restaurant without "$field" gives an Err', () async {
        final json = _copy(_restaurantsJson);
        _at(json, ['restaurants', 0]).remove(field);
        body = json;

        final result = await server.client.restaurants();

        expect(result.failureOrNull, _isFormatFailure);
      });
    }

    test('a response without "restaurants" gives an Err', () async {
      body = <String, Object?>{};

      final result = await server.client.restaurants();

      expect(result.failureOrNull, _isFormatFailure);
    });

    test('ignores unknown extra fields', () async {
      final json = _copy(_restaurantsJson);
      json['nextPage'] = 'abc';
      _at(json, ['restaurants', 0])['rating'] = 4.5;
      body = json;

      final result = await server.client.restaurants();

      expect(result.valueOrNull, hasLength(1));
    });
  });

  group('menu', () {
    test('parses the docs/api.md example', () async {
      body = _menuJson;
      server.respond = (method, path) =>
          FakeResponse(200, body, const {'ETag': '"menu-v1"'});

      final result = await server.client.menu('taqueria-sol');

      expect(
        result.valueOrNull,
        Fresh(
          ApiMenu(
            restaurantId: 'taqueria-sol',
            currency: 'USD',
            categories: [
              ApiMenuCategory(
                id: 'tacos',
                name: 'Tacos',
                items: [
                  ApiMenuItem(
                    id: 'al-pastor',
                    name: 'Al pastor taco',
                    description: 'Pork, pineapple, onion, cilantro',
                    price: Money(450, currency: 'USD'),
                    available: true,
                  ),
                ],
              ),
            ],
          ),
          etag: '"menu-v1"',
        ),
      );
      expect(server.requests, ['GET /restaurants/taqueria-sol/menu']);
      expect(server.requestHeaders.single, isNot(contains('if-none-match')));
    });

    test('sends the etag and gives NotModified for a 304', () async {
      server.respond = (method, path) => const FakeResponse(304);

      final result = await server.client.menu('taqueria-sol', etag: '"v1"');

      expect(result, const Ok<Revalidated<ApiMenu>>(NotModified()));
      expect(server.requestHeaders.single['if-none-match'], '"v1"');
    });

    test('a 404 gives Err(ServerFailure)', () async {
      server.respond = (method, path) => const FakeResponse(404, {
        'code': 'NOT_FOUND',
        'message': 'Restaurant not found',
        'requestId': 'req-1',
      });

      final result = await server.client.menu('missing');

      expect(result.failureOrNull, isA<ServerFailure>());
    });

    for (final (path, fields) in _menuObjects) {
      for (final field in fields) {
        test(
          'a menu without ${[...path, field].join('.')} gives an Err',
          () async {
            final json = _copy(_menuJson);
            _at(json, path).remove(field);
            body = json;

            final result = await server.client.menu('taqueria-sol');

            expect(result.failureOrNull, _isFormatFailure);
          },
        );
      }
    }

    test('a field of the wrong type gives an Err', () async {
      final json = _copy(_menuJson);
      _at(json, ['categories', 0, 'items', 0, 'price'])['minorUnits'] = '450';
      body = json;

      final result = await server.client.menu('taqueria-sol');

      expect(result.failureOrNull, _isFormatFailure);
    });

    test('a lowercase price currency such as usd gives an Err', () async {
      final json = _copy(_menuJson);
      _at(json, ['categories', 0, 'items', 0, 'price'])['currency'] = 'usd';
      body = json;

      final result = await server.client.menu('taqueria-sol');

      expect(result.failureOrNull, _isFormatFailure);
    });

    test('a lowercase menu currency such as usd gives an Err', () async {
      final json = _copy(_menuJson);
      json['currency'] = 'usd';
      body = json;

      final result = await server.client.menu('taqueria-sol');

      expect(result.failureOrNull, _isFormatFailure);
    });

    test('ignores unknown extra fields at every level', () async {
      final json = _copy(_menuJson);
      for (final (path, _) in _menuObjects) {
        _at(json, path)['addedLater'] = {'any': 'shape'};
      }
      body = json;

      final result = await server.client.menu('taqueria-sol');

      final menu = (result.valueOrNull! as Fresh<ApiMenu>).value;
      expect(menu.categories.single.items.single.id, 'al-pastor');
    });
  });

  test('equal values have equal hash codes', () {
    expect(
      ApiRestaurant.fromJson(_at(_restaurantsJson, ['restaurants', 0]))
          .hashCode,
      ApiRestaurant.fromJson(_at(_restaurantsJson, ['restaurants', 0]))
          .hashCode,
    );
    expect(
      ApiMenu.fromJson(_copy(_menuJson)).hashCode,
      ApiMenu.fromJson(_copy(_menuJson)).hashCode,
    );
  });
}
