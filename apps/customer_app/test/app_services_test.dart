import 'package:core/core.dart';
import 'package:customer_app/app/app_bloc_observer.dart';
import 'package:customer_app/app/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(resetDependencies);
  tearDown(resetDependencies);

  group('configureDependencies', () {
    test('registers config and logger singletons', () async {
      final config = AppConfig.parse(
        flavor: Flavor.dev,
        apiBaseUrl: 'https://api.example.com',
      );
      final logger = ConsoleLogger(minLevel: LogLevel.debug, sink: (_) {});

      await configureDependencies(config: config, logger: logger);

      expect(getIt<AppConfig>(), same(config));
      expect(getIt<AppLogger>(), same(logger));
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
