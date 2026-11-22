import 'dart:async';

import 'package:api_client/testing.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';
import 'package:menu_feature/menu_feature.dart';

const _restaurantId = 'taqueria-sol';
const _menuPath = '/restaurants/$_restaurantId/menu';
const _menuRequest = 'GET $_menuPath';

// Drift stores times in whole seconds, so tests use a fixed time.
final _now = DateTime.utc(2026, 11, 21, 12);

const _down = FakeResponse(503);

const _restaurantsResponse = FakeResponse(200, {
  'restaurants': [
    {'id': _restaurantId, 'name': 'Taqueria Sol', 'cuisine': 'Mexican'},
  ],
});

FakeResponse _menu({required int price, String etag = '"v1"'}) => FakeResponse(
  200,
  {
    'restaurantId': _restaurantId,
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
            'price': {'minorUnits': price, 'currency': 'USD'},
            'available': true,
          },
        ],
      },
    ],
  },
  {'ETag': etag},
);

/// The price of the only item in [menu].
int? _price(Menu? menu) =>
    menu?.categories.single.items.single.price.minorUnits;

void main() {
  late CraveDatabase db;
  late FakeApiServer server;
  late FutureOr<FakeResponse> Function() menuResponse;
  late MenuRepository repository;
  late MenuBloc bloc;
  late List<SyncedState<Menu>> states;
  late StreamSubscription<SyncedState<Menu>> statesSubscription;

  setUp(() async {
    db = inMemoryCraveDatabase();
    menuResponse = () => _menu(price: 450);
    server = FakeApiServer(
      (method, path) => switch (path) {
        '/restaurants' => _restaurantsResponse,
        _menuPath => menuResponse(),
        _ => const FakeResponse(404, {'code': 'NOT_FOUND', 'message': ''}),
      },
    );
    repository = MenuRepository(
      apiClient: server.client,
      menuDao: db.menuDao,
      now: () => _now,
    );
    // A menu references its restaurant, so the restaurant is stored first.
    expect(await repository.refreshRestaurants(), isA<Ok<void>>());
    server.requests.clear();

    bloc = MenuBloc(repository: repository, restaurantId: _restaurantId);
    states = [];
    statesSubscription = bloc.stream.listen(states.add);
  });

  tearDown(() async {
    await statesSubscription.cancel();
    await bloc.close();
    await db.close();
  });

  /// Makes the server hold menu requests until the returned completer is
  /// completed with a response.
  Completer<FakeResponse> holdMenu() {
    final completer = Completer<FakeResponse>();
    menuResponse = () => completer.future;
    return completer;
  }

  test('before the database emits, loaded is false', () async {
    expect(bloc.state, const SyncedState<Menu>());

    bloc.add(const MenuStarted());

    expect(bloc.state.loaded, isFalse);
    expect(bloc.state.data, isNull);

    await pumpEventQueue();
    expect(bloc.state.loaded, isTrue);
  });

  test('a first visit with the server down ends with no data and a '
      'failure', () async {
    menuResponse = () => _down;

    bloc.add(const MenuStarted());
    await pumpEventQueue();

    expect(bloc.state.loaded, isTrue);
    expect(bloc.state.data, isNull);
    expect(bloc.state.refreshing, isFalse);
    expect(bloc.state.refreshFailure, isA<ServerFailure>());
  });

  test('a saved menu shows straight away, and stays when the refresh '
      'fails, with the failure set', () async {
    expect(await repository.refreshMenu(_restaurantId), isA<Ok<void>>());
    final response = holdMenu();

    bloc.add(const MenuStarted());
    await pumpEventQueue();

    expect(_price(bloc.state.data), 450);
    expect(bloc.state.loaded, isTrue);
    expect(bloc.state.refreshing, isTrue);

    response.complete(_down);
    await pumpEventQueue();

    expect(_price(bloc.state.data), 450);
    expect(bloc.state.refreshing, isFalse);
    expect(bloc.state.refreshFailure, isA<ServerFailure>());
  });

  test('a successful refresh shows the new data and clears an earlier '
      'failure', () async {
    menuResponse = () => _down;
    bloc.add(const MenuStarted());
    await pumpEventQueue();
    expect(bloc.state.refreshFailure, isNotNull);

    final response = holdMenu();
    bloc.add(const MenuRefreshRequested());
    await pumpEventQueue();

    expect(bloc.state.refreshing, isTrue);
    expect(bloc.state.refreshFailure, isNull);

    response.complete(_menu(price: 500, etag: '"v2"'));
    await pumpEventQueue();

    expect(_price(bloc.state.data), 500);
    expect(bloc.state.data?.fetchedAt, _now);
    expect(bloc.state.refreshing, isFalse);
    expect(bloc.state.refreshFailure, isNull);
  });

  test('two refresh events while the first is still running make one '
      'request', () async {
    final response = holdMenu();
    bloc.add(const MenuStarted());
    await pumpEventQueue();

    bloc
      ..add(const MenuRefreshRequested())
      ..add(const MenuRefreshRequested());
    await pumpEventQueue();

    expect(server.requests, [_menuRequest]);

    response.complete(_menu(price: 450));
    await pumpEventQueue();
    expect(bloc.state.refreshing, isFalse);

    // Refreshes are dropped only while one is running.
    menuResponse = () => _menu(price: 450);
    bloc.add(const MenuRefreshRequested());
    await pumpEventQueue();

    expect(server.requests, [_menuRequest, _menuRequest]);
  });

  test('closing the bloc cancels the subscription', () async {
    bloc.add(const MenuStarted());
    await pumpEventQueue();
    final countBeforeClose = states.length;

    await bloc.close();

    // A live subscription would add an event to the closed bloc, which
    // throws and fails this test.
    menuResponse = () => _menu(price: 500, etag: '"v2"');
    expect(await repository.refreshMenu(_restaurantId), isA<Ok<void>>());
    await pumpEventQueue();

    expect(states, hasLength(countBeforeClose));
  });
}
