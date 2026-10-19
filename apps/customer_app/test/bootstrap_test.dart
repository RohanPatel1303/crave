import 'package:core/core.dart';
import 'package:customer_app/bootstrap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
