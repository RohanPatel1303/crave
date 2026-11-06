import 'package:api_client/api_client.dart';
import 'package:auth/auth.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:customer_app/app/app_bloc_observer.dart';
import 'package:customer_app/app/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_config.dart';

void main() {
  setUp(resetDependencies);
  tearDown(resetDependencies);

  group('configureDependencies', () {
    final config = testConfig(Flavor.dev);
    final logger = ConsoleLogger(minLevel: LogLevel.debug, sink: (_) {});

    // SecureTokenStore needs the platform plugin; this swaps in its
    // in-memory test implementation, with no stored session.
    setUp(() => FlutterSecureStorage.setMockInitialValues({}));

    test('registers config and logger singletons', () async {
      await configureDependencies(config: config, logger: logger);

      expect(getIt<AppConfig>(), same(config));
      expect(getIt<AppLogger>(), same(logger));
    });

    test('registers the session, API client and auth bloc', () async {
      await configureDependencies(config: config, logger: logger);

      expect(getIt.isRegistered<AuthSession>(), isTrue);
      expect(getIt.isRegistered<ApiClient>(), isTrue);
      expect(getIt.isRegistered<AuthBloc>(), isTrue);
    });

    test('starts the auth bloc, which finds no stored session', () async {
      await configureDependencies(config: config, logger: logger);
      final bloc = getIt<AuthBloc>();

      final state = bloc.state is AuthUnknown
          ? await bloc.stream.first
          : bloc.state;

      expect(state, isA<Unauthenticated>());
    });

    test('createApp builds the app from the registered dependencies', () async {
      await configureDependencies(config: config, logger: logger);

      final app = createApp();

      expect(app.config, same(config));
      expect(app.authBloc, same(getIt<AuthBloc>()));
    });

    test('resetting closes the auth bloc', () async {
      await configureDependencies(config: config, logger: logger);
      final bloc = getIt<AuthBloc>();

      await resetDependencies();

      expect(bloc.isClosed, isTrue);
    });
  });

  group('AppBlocObserver', () {
    late List<String> logs;
    late ConsoleLogger logger;
    late AppBlocObserver observer;
    late _TestCubit cubit;
    late BlocObserver previousObserver;

    setUp(() {
      previousObserver = Bloc.observer;
      logs = [];
      logger = ConsoleLogger(minLevel: LogLevel.debug, sink: logs.add);
      observer = AppBlocObserver(logger);
      Bloc.observer = observer;
      cubit = _TestCubit();
    });

    tearDown(() async {
      Bloc.observer = previousObserver;
      await cubit.close();
    });

    test('logs only state types at debug level', () {
      observer.onChange(
        cubit,
        const Change<String>(
          currentState: 'private-current-state',
          nextState: 'private-next-state',
        ),
      );

      expect(logs.single, contains('[DEBUG]'));
      expect(logs.single, contains('_TestCubit'));
      expect(logs.single, contains('String -> String'));
      expect(logs.single, isNot(contains('private-')));
    });

    test('forwards cubit errors to the logger', () {
      final error = StateError('test failure');
      final stackTrace = StackTrace.current;
      cubit.reportError(error, stackTrace);

      expect(logs, hasLength(1));
      expect(logs.single, contains('[ERROR]'));
      expect(logs.single, contains('_TestCubit'));
      expect(logs.single, contains(error.toString()));
      expect(logs.single, contains(stackTrace.toString()));
    });
  });
}

class _TestCubit extends Cubit<String> {
  _TestCubit() : super('initial-state');

  void reportError(Object error, StackTrace stackTrace) =>
      addError(error, stackTrace);
}
