import 'package:api_client/testing.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';
import 'package:menu_feature/menu_feature.dart';

// Drift stores times in whole seconds, so tests use fixed times.
final _firstFetch = DateTime.utc(2026, 11, 17, 12);
final _secondFetch = DateTime.utc(2026, 11, 17, 13);

const _restaurantsBody = {
  'restaurants': [
    {'id': 'taqueria-sol', 'name': 'Taqueria Sol', 'cuisine': 'Mexican'},
    {'id': 'pho-corner', 'name': 'Pho Corner', 'cuisine': 'Vietnamese'},
  ],
};

Map<String, Object?> _menuBody({int pastorPrice = 450}) => {
  'restaurantId': 'taqueria-sol',
  'currency': 'USD',
  'categories': [
    {
      'id': 'tacos',
      'name': 'Tacos',
      'items': [
        {
          'id': 'al-pastor',
          'name': 'Al pastor taco',
          'description': 'Pork, pineapple, onion, cilantro',
          'price': {'minorUnits': pastorPrice, 'currency': 'USD'},
          'available': true,
        },
      ],
    },
  ],
};

Menu _expectedMenu({required DateTime fetchedAt, int pastorPrice = 450}) =>
    Menu(
      restaurantId: 'taqueria-sol',
      fetchedAt: fetchedAt,
      categories: [
        MenuCategory(
          id: 'tacos',
          name: 'Tacos',
          items: [
            MenuItem(
              id: 'al-pastor',
              name: 'Al pastor taco',
              description: 'Pork, pineapple, onion, cilantro',
              price: Money(pastorPrice, currency: 'USD'),
              available: true,
            ),
          ],
        ),
      ],
    );

void main() {
  late CraveDatabase db;
  late FakeApiServer server;
  late DateTime now;
  late FakeResponse Function() menuResponse;
  late MenuRepository repository;

  setUp(() {
    db = inMemoryCraveDatabase();
    now = _firstFetch;
    menuResponse = () =>
        FakeResponse(200, _menuBody(), const {'ETag': '"menu-v1"'});
    server = FakeApiServer(
      (method, path) => switch (path) {
        '/restaurants' => const FakeResponse(200, _restaurantsBody),
        '/restaurants/taqueria-sol/menu' => menuResponse(),
        _ => const FakeResponse(404, {'code': 'NOT_FOUND', 'message': ''}),
      },
    );
    repository = MenuRepository(
      apiClient: server.client,
      menuDao: db.menuDao,
      now: () => now,
    );
  });

  tearDown(() => db.close());

  /// Stores the restaurants and a first copy of the menu.
  Future<void> storeFirstMenu() async {
    expect(await repository.refreshRestaurants(), isA<Ok<void>>());
    expect(await repository.refreshMenu('taqueria-sol'), isA<Ok<void>>());
  }

  test('refreshRestaurants stores the list, and watchRestaurants emits it in '
      "the server's order", () async {
    final result = await repository.refreshRestaurants();

    expect(result, isA<Ok<void>>());
    expect(await repository.watchRestaurants().first, const [
      Restaurant(id: 'taqueria-sol', name: 'Taqueria Sol', cuisine: 'Mexican'),
      Restaurant(id: 'pho-corner', name: 'Pho Corner', cuisine: 'Vietnamese'),
    ]);
  });

  test('the first refreshMenu sends no If-None-Match and stores the menu, its '
      'ETag and the time', () async {
    await storeFirstMenu();

    expect(server.requests.last, 'GET /restaurants/taqueria-sol/menu');
    expect(server.requestHeaders.last, isNot(contains('if-none-match')));
    final stored = await db.menuDao.watchMenu('taqueria-sol').first;
    expect(stored!.etag, '"menu-v1"');
    expect(stored.fetchedAt.isAtSameMomentAs(_firstFetch), isTrue);
    expect(stored.categories.single.items.single.id, 'al-pastor');
  });

  test('watchMenu emits prices as Money', () async {
    await storeFirstMenu();

    final menu = await repository.watchMenu('taqueria-sol').first;

    expect(menu, _expectedMenu(fetchedAt: _firstFetch));
    expect(
      menu!.categories.single.items.single.price,
      Money(450, currency: 'USD'),
    );
  });

  test('the second refreshMenu sends the stored ETag', () async {
    await storeFirstMenu();

    await repository.refreshMenu('taqueria-sol');

    expect(server.requestHeaders.last['if-none-match'], '"menu-v1"');
  });

  test(
    'on a 304, the menu is unchanged and fetchedAt moves to the new time',
    () async {
      await storeFirstMenu();
      menuResponse = () => const FakeResponse(304);
      now = _secondFetch;

      final result = await repository.refreshMenu('taqueria-sol');

      expect(result, isA<Ok<void>>());
      expect(
        await repository.watchMenu('taqueria-sol').first,
        _expectedMenu(fetchedAt: _secondFetch),
      );
      final stored = await db.menuDao.watchMenu('taqueria-sol').first;
      expect(stored!.etag, '"menu-v1"');
    },
  );

  test('on a 200 with a different menu, a watcher gets the new menu', () async {
    await storeFirstMenu();
    final emissions = <Menu?>[];
    final subscription = repository
        .watchMenu('taqueria-sol')
        .listen(emissions.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();
    menuResponse = () => FakeResponse(200, _menuBody(pastorPrice: 500), const {
      'ETag': '"menu-v2"',
    });
    now = _secondFetch;

    final result = await repository.refreshMenu('taqueria-sol');
    await pumpEventQueue();

    expect(result, isA<Ok<void>>());
    expect(emissions, [
      _expectedMenu(fetchedAt: _firstFetch),
      _expectedMenu(fetchedAt: _secondFetch, pastorPrice: 500),
    ]);
    final stored = await db.menuDao.watchMenu('taqueria-sol').first;
    expect(stored!.etag, '"menu-v2"');
  });

  test(
    'on a 503, the result is an Err, and the saved menu is still there',
    () async {
      await storeFirstMenu();
      menuResponse = () => const FakeResponse(503);
      now = _secondFetch;

      final result = await repository.refreshMenu('taqueria-sol');

      expect(result.failureOrNull, isA<ServerFailure>());
      expect(
        await repository.watchMenu('taqueria-sol').first,
        _expectedMenu(fetchedAt: _firstFetch),
      );
    },
  );

  test('on a malformed body, the result is an Err, and the saved menu is '
      'still there', () async {
    await storeFirstMenu();
    menuResponse = () =>
        const FakeResponse(200, {'restaurantId': 'taqueria-sol'});
    now = _secondFetch;

    final result = await repository.refreshMenu('taqueria-sol');

    expect(result, isA<Err<void>>());
    expect(
      await repository.watchMenu('taqueria-sol').first,
      _expectedMenu(fetchedAt: _firstFetch),
    );
  });

  test(
    'a failed refreshRestaurants returns the Err and stores nothing',
    () async {
      server.respond = (method, path) => const FakeResponse(503);

      final result = await repository.refreshRestaurants();

      expect(result.failureOrNull, isA<ServerFailure>());
      expect(await repository.watchRestaurants().first, isEmpty);
    },
  );

  group('refreshMenu for a restaurant that is not stored, as after a deep '
      'link', () {
    test('refreshes the restaurants first, then stores the menu', () async {
      final result = await repository.refreshMenu('taqueria-sol');

      expect(result, isA<Ok<void>>());
      expect(server.requests, [
        'GET /restaurants',
        'GET /restaurants/taqueria-sol/menu',
      ]);
      expect(
        await repository.watchMenu('taqueria-sol').first,
        _expectedMenu(fetchedAt: _firstFetch),
      );
    });

    test('returns the failure, and requests no menu, when the restaurants '
        'refresh fails', () async {
      server = FakeApiServer(
        (method, path) =>
            const FakeResponse(503, {'code': 'INTERNAL', 'message': ''}),
      );
      repository = MenuRepository(
        apiClient: server.client,
        menuDao: db.menuDao,
        now: () => now,
      );

      final result = await repository.refreshMenu('taqueria-sol');

      expect(result, isA<Err<void>>());
      expect(server.requests, ['GET /restaurants']);
      expect(await repository.watchMenu('taqueria-sol').first, isNull);
    });

    test('returns a 404 ServerFailure, and requests no menu, when the '
        'restaurant is not listed', () async {
      final result = await repository.refreshMenu('closed-diner');

      expect(
        result,
        isA<Err<void>>().having(
          (err) => err.failure,
          'failure',
          isA<ServerFailure>().having(
            (failure) => failure.statusCode,
            'statusCode',
            404,
          ),
        ),
      );
      expect(server.requests, ['GET /restaurants']);
    });
  });

  test('refreshMenu does not refresh the restaurants when the restaurant is '
      'stored', () async {
    await storeFirstMenu();

    expect(server.requests, [
      'GET /restaurants',
      'GET /restaurants/taqueria-sol/menu',
    ]);
  });

  test('watchMenu never makes a request', () async {
    final emissions = <Menu?>[];
    final subscription = repository
        .watchMenu('taqueria-sol')
        .listen(emissions.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    expect(emissions, [null]);
    expect(server.requests, isEmpty);
  });

  test('watchRestaurants never makes a request', () async {
    expect(await repository.watchRestaurants().first, isEmpty);
    expect(server.requests, isEmpty);
  });
}
