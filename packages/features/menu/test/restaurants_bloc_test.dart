import 'dart:async';

import 'package:api_client/testing.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_store/testing.dart';
import 'package:menu_feature/menu_feature.dart';

const _path = '/restaurants';
const _request = 'GET $_path';

const _down = FakeResponse(503);

FakeResponse _restaurants(List<String> names) => FakeResponse(200, {
  'restaurants': [
    for (final name in names)
      {'id': name.toLowerCase(), 'name': name, 'cuisine': 'Mexican'},
  ],
});

List<Restaurant> _expected(List<String> names) => [
  for (final name in names)
    Restaurant(id: name.toLowerCase(), name: name, cuisine: 'Mexican'),
];

void main() {
  late CraveDatabase db;
  late FakeApiServer server;
  late MenuRepository repository;
  late RestaurantsBloc bloc;
  late List<SyncedState<List<Restaurant>>> states;
  late StreamSubscription<SyncedState<List<Restaurant>>> statesSubscription;

  setUp(() {
    db = inMemoryCraveDatabase();
    server = FakeApiServer((method, path) => _restaurants(['Sol']));
    repository = MenuRepository(apiClient: server.client, menuDao: db.menuDao);
    bloc = RestaurantsBloc(repository: repository);
    states = [];
    statesSubscription = bloc.stream.listen(states.add);
  });

  tearDown(() async {
    await statesSubscription.cancel();
    await bloc.close();
    await db.close();
  });

  /// Makes the server hold each request until the returned completer is
  /// completed with a response.
  Completer<FakeResponse> holdServer() {
    final completer = Completer<FakeResponse>();
    server.respond = (method, path) => completer.future;
    return completer;
  }

  test('before the database emits, loaded is false', () async {
    expect(bloc.state, const SyncedState<List<Restaurant>>());

    bloc.add(const RestaurantsStarted());

    expect(bloc.state.loaded, isFalse);
    expect(bloc.state.data, isNull);

    await pumpEventQueue();
    expect(bloc.state.loaded, isTrue);
  });

  test('a first visit with the server down ends with no data and a '
      'failure', () async {
    server.respond = (method, path) => _down;

    bloc.add(const RestaurantsStarted());
    await pumpEventQueue();

    expect(bloc.state.loaded, isTrue);
    expect(bloc.state.data, isEmpty);
    expect(bloc.state.refreshing, isFalse);
    expect(bloc.state.refreshFailure, isA<ServerFailure>());
  });

  test('saved restaurants show straight away, and stay when the refresh '
      'fails, with the failure set', () async {
    expect(await repository.refreshRestaurants(), isA<Ok<void>>());
    final response = holdServer();

    bloc.add(const RestaurantsStarted());
    await pumpEventQueue();

    expect(bloc.state.data, _expected(['Sol']));
    expect(bloc.state.loaded, isTrue);
    expect(bloc.state.refreshing, isTrue);

    response.complete(_down);
    await pumpEventQueue();

    expect(bloc.state.data, _expected(['Sol']));
    expect(bloc.state.refreshing, isFalse);
    expect(bloc.state.refreshFailure, isA<ServerFailure>());
  });

  test('a successful refresh shows the new data and clears an earlier '
      'failure', () async {
    server.respond = (method, path) => _down;
    bloc.add(const RestaurantsStarted());
    await pumpEventQueue();
    expect(bloc.state.refreshFailure, isNotNull);

    final response = holdServer();
    bloc.add(const RestaurantsRefreshRequested());
    await pumpEventQueue();

    expect(bloc.state.refreshing, isTrue);
    expect(bloc.state.refreshFailure, isNull);

    response.complete(_restaurants(['Sol', 'Luna']));
    await pumpEventQueue();

    expect(bloc.state.data, _expected(['Sol', 'Luna']));
    expect(bloc.state.refreshing, isFalse);
    expect(bloc.state.refreshFailure, isNull);
  });

  test('two refresh events while the first is still running make one '
      'request', () async {
    final response = holdServer();
    bloc.add(const RestaurantsStarted());
    await pumpEventQueue();

    bloc
      ..add(const RestaurantsRefreshRequested())
      ..add(const RestaurantsRefreshRequested());
    await pumpEventQueue();

    expect(server.requests, [_request]);

    response.complete(_restaurants(['Sol']));
    await pumpEventQueue();
    expect(bloc.state.refreshing, isFalse);

    // Refreshes are dropped only while one is running.
    server.respond = (method, path) => _restaurants(['Sol']);
    bloc.add(const RestaurantsRefreshRequested());
    await pumpEventQueue();

    expect(server.requests, [_request, _request]);
  });

  test('closing the bloc cancels the subscription', () async {
    bloc.add(const RestaurantsStarted());
    await pumpEventQueue();
    final countBeforeClose = states.length;

    await bloc.close();

    // A live subscription would add an event to the closed bloc, which
    // throws and fails this test.
    server.respond = (method, path) => _restaurants(['Sol', 'Luna']);
    expect(await repository.refreshRestaurants(), isA<Ok<void>>());
    await pumpEventQueue();

    expect(states, hasLength(countBeforeClose));
  });
}
