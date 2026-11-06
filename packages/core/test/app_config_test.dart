import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('AppConfig.parse', () {
    test('keeps the OIDC issuer and redirect URI', () {
      final config = _parse(
        flavor: Flavor.dev,
        oidcIssuer: 'http://localhost:8081/realms/crave',
        oidcRedirectUri: 'dev.crave.customer.dev:/oauthredirect',
      );

      expect(
        config.oidcIssuer,
        Uri.parse('http://localhost:8081/realms/crave'),
      );
      expect(config.oidcRedirectUri, 'dev.crave.customer.dev:/oauthredirect');
    });

    test('throws when OIDC_ISSUER is empty or not absolute', () {
      for (final oidcIssuer in ['', 'id.example.com']) {
        expect(
          () => _parse(flavor: Flavor.dev, oidcIssuer: oidcIssuer),
          throwsA(
            isA<ArgumentError>().having(
              (error) => error.message,
              'message',
              contains('OIDC_ISSUER'),
            ),
          ),
          reason: 'Expected "$oidcIssuer" to be rejected',
        );
      }
    });

    test('accepts an HTTP OIDC issuer only in dev', () {
      const issuer = 'http://localhost:8081/realms/crave';
      expect(
        () => _parse(flavor: Flavor.dev, oidcIssuer: issuer),
        returnsNormally,
      );
      for (final flavor in [Flavor.staging, Flavor.prod]) {
        expect(
          () => _parse(flavor: flavor, oidcIssuer: issuer),
          throwsA(isA<ArgumentError>()),
          reason: '$flavor should reject an HTTP issuer',
        );
      }
    });

    test('throws when OIDC_REDIRECT_URI is empty, with a hint', () {
      expect(
        () => _parse(flavor: Flavor.dev, oidcRedirectUri: ''),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('OIDC_REDIRECT_URI'),
              contains('--dart-define-from-file=config/<flavor>.json'),
            ),
          ),
        ),
      );
    });

    test('builds a config with the flavor and parsed API base URL', () {
      final config = _parse(
        flavor: Flavor.dev,
        apiBaseUrl: 'http://10.0.2.2:8080',
      );

      expect(config.flavor, Flavor.dev);
      expect(config.apiBaseUrl, Uri.parse('http://10.0.2.2:8080'));
    });

    test('throws when API_BASE_URL is empty with a configuration hint', () {
      expect(
        () => _parse(flavor: Flavor.dev, apiBaseUrl: ''),
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
          () => _parse(flavor: Flavor.dev, apiBaseUrl: apiBaseUrl),
          throwsA(isA<ArgumentError>()),
          reason: 'Expected "$apiBaseUrl" to be rejected',
        );
      }
    });

    test('throws when a production API base URL is not HTTPS', () {
      expect(
        () => _parse(flavor: Flavor.prod, apiBaseUrl: 'http://api.example.com'),
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
        () => _parse(flavor: flavor, apiBaseUrl: 'http://api.example.com'),
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

  test('allowInsecureIdentityConnections is true only for dev', () {
    expect(_config(Flavor.dev).allowInsecureIdentityConnections, isTrue);
    expect(_config(Flavor.staging).allowInsecureIdentityConnections, isFalse);
    expect(_config(Flavor.prod).allowInsecureIdentityConnections, isFalse);
  });

  test('isProduction is true only for prod', () {
    expect(_config(Flavor.dev).isProduction, isFalse);
    expect(_config(Flavor.staging).isProduction, isFalse);
    expect(_config(Flavor.prod).isProduction, isTrue);
  });
}

AppConfig _config(Flavor flavor) => _parse(flavor: flavor);

AppConfig _parse({
  required Flavor flavor,
  String apiBaseUrl = 'https://api.example.com',
  String oidcIssuer = 'https://id.example.com/realms/crave',
  String oidcRedirectUri = 'dev.crave.customer:/oauthredirect',
}) => AppConfig.parse(
  flavor: flavor,
  apiBaseUrl: apiBaseUrl,
  oidcIssuer: oidcIssuer,
  oidcRedirectUri: oidcRedirectUri,
);
