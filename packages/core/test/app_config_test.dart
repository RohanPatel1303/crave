import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('AppConfig.parse', () {
    test('builds a config with the flavor and parsed API base URL', () {
      final config = AppConfig.parse(
        flavor: Flavor.dev,
        apiBaseUrl: 'http://10.0.2.2:8080',
      );

      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl, Uri.parse('http://10.0.2.2:8080'));
    });

    test('throws when API_BASE_URL is empty with a configuration hint', () {
      expect(
        () => AppConfig.parse(flavor: Flavor.dev, apiBaseUrl: ''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('API_BASE_URL'),
              contains('--dart-define-from-file=config/<flavor>.json'),
            ),
          ),
        ),
      );
    });

    test('throws when the API base URL has no scheme or host', () {
      for (final apiBaseUrl in [
        'not a url',
        'api.example.com',
        'http://api.example.com:abc',
      ]) {
        expect(
          () => AppConfig.parse(flavor: Flavor.dev, apiBaseUrl: apiBaseUrl),
          throwsA(isA<ArgumentError>()),
          reason: 'Expected "$apiBaseUrl" to be rejected',
        );
      }
    });

    test('throws when a production API base URL is not HTTPS', () {
      expect(
        () => AppConfig.parse(
          flavor: Flavor.prod,
          apiBaseUrl: 'http://api.example.com',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Flavor.parse', () {
    test('throws when FLAVOR is empty, with a configuration hint', () {
      expect(
        () => Flavor.parse(''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('FLAVOR'),
              contains('--dart-define-from-file=config/<flavor>.json'),
            ),
          ),
        ),
      );
    });

    test('rejects an unknown name and lists the valid flavors', () {
      expect(
        () => Flavor.parse('Prod'),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            allOf(contains('"Prod"'), contains('dev, staging, prod')),
          ),
        ),
      );
    });

    test('returns the matching flavor for every valid name', () {
      for (final flavor in Flavor.values) {
        expect(Flavor.parse(flavor.name), flavor);
      }
    });
  });
  test('every non-production flavor accepts HTTP', () {
    for (final flavor in Flavor.values.where(
      (flavor) => flavor != Flavor.prod,
    )) {
      expect(
        () => AppConfig.parse(
          flavor: flavor,
          apiBaseUrl: 'http://api.example.com',
        ),
        returnsNormally,
        reason: '$flavor should accept HTTP',
      );
    }
  });

  test('verboseLogging is enabled for non-production flavors only', () {
    expect(_config(Flavor.dev).verboseLogging, isTrue);
    expect(_config(Flavor.staging).verboseLogging, isTrue);
    expect(_config(Flavor.prod).verboseLogging, isFalse);
  });

  test('isProduction is true only for prod', () {
    expect(_config(Flavor.dev).isProduction, isFalse);
    expect(_config(Flavor.staging).isProduction, isFalse);
    expect(_config(Flavor.prod).isProduction, isTrue);
  });
}

AppConfig _config(Flavor flavor) =>
    AppConfig.parse(flavor: flavor, apiBaseUrl: 'https://api.example.com');
