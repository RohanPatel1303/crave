import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the `--dart-define-from-file=config/<flavor>.json` files, which
/// nothing else reads until the app launches.
void main() {
  for (final flavor in Flavor.values) {
    test('config/${flavor.name}.json parses as the ${flavor.name} flavor', () {
      final file = File('config/${flavor.name}.json');
      expect(file.existsSync(), isTrue, reason: '${file.path} is missing');

      final json = jsonDecode(file.readAsStringSync());
      expect(json, isA<Map<String, Object?>>());
      final defines = json as Map<String, Object?>;

      final config = AppConfig.parse(
        flavor: Flavor.parse(defines['FLAVOR']! as String),
        apiBaseUrl: defines['API_BASE_URL']! as String,
        oidcIssuer: defines['OIDC_ISSUER']! as String,
        oidcRedirectUri: defines['OIDC_REDIRECT_URI']! as String,
      );

      expect(config.flavor, flavor);
      // The redirect scheme must match the Android flavor's
      // appAuthRedirectScheme, or the provider can't return to the app.
      expect(
        Uri.parse(config.oidcRedirectUri).scheme,
        _androidRedirectSchemes()[flavor.name],
      );
    });
  }

  test('config/ has one file per flavor and nothing else', () {
    final names = Directory('config')
        .listSync()
        .map((entry) => entry.uri.pathSegments.last)
        .toSet();

    expect(names, {for (final flavor in Flavor.values) '${flavor.name}.json'});
  });
}

/// The `appAuthRedirectScheme` of each Android product flavor, by name.
Map<String, String> _androidRedirectSchemes() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  return {
    for (final match in RegExp(
      r'create\("(\w+)"\)\s*\{[^}]*'
      r'manifestPlaceholders\["appAuthRedirectScheme"\]\s*=\s*"([^"]+)"',
    ).allMatches(gradle))
      match.group(1)!: match.group(2)!,
  };
}
