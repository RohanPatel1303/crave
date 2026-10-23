import 'package:core/core.dart';
import 'package:customer_app/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FlutterExceptionHandler? previousFlutterErrorHandler;
  late bool Function(Object, StackTrace)? previousPlatformErrorHandler;
  late void Function(FlutterErrorDetails) previousPresentError;

  setUp(() {
    previousFlutterErrorHandler = FlutterError.onError;
    previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
    previousPresentError = FlutterError.presentError;
    FlutterError.presentError = (_) {};
  });

  tearDown(() {
    FlutterError.onError = previousFlutterErrorHandler;
    PlatformDispatcher.instance.onError = previousPlatformErrorHandler;
    FlutterError.presentError = previousPresentError;
  });

  group('ensureFlavorsMatch', () {
    test('allows a null native flavor', () {
      expect(
        () => ensureFlavorsMatch(configFlavor: Flavor.dev, nativeFlavor: null),
        returnsNormally,
      );
    });

    test('allows matching flavors', () {
      expect(
        () => ensureFlavorsMatch(
          configFlavor: Flavor.staging,
          nativeFlavor: 'staging',
        ),
        returnsNormally,
      );
    });

    test('throws when flavors do not match', () {
      expect(
        () =>
            ensureFlavorsMatch(configFlavor: Flavor.dev, nativeFlavor: 'prod'),
        throwsA(
          isA<StateError>()
              .having((error) => error.message, 'message', contains('dev'))
              .having((error) => error.message, 'message', contains('prod')),
        ),
      );
    });
  });

  test('installErrorHandlers logs Flutter errors', () {
    final logs = <String>[];
    final logger = ConsoleLogger(minLevel: LogLevel.error, sink: logs.add);
    final error = StateError('test Flutter error');

    installErrorHandlers(logger);
    FlutterError.onError!(
      FlutterErrorDetails(exception: error, stack: StackTrace.current),
    );

    expect(logs, hasLength(1));
    expect(logs.single, contains('Flutter error'));
    expect(logs.single, contains(error.toString()));
  });

  // bootstrap's fromEnvironment and runApp wiring is not covered by unit tests.
}
