import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the iOS build settings files, which nothing else reads until Xcode
/// builds the app.
void main() {
  const flutterDir = 'ios/Flutter';

  for (final flavor in Flavor.values) {
    group('${flavor.name} flavor', () {
      final settings = _readSettings(
        '$flutterDir/flavors/${flavor.name}.xcconfig',
      );

      test('defines the bundle ID, display name and redirect scheme', () {
        expect(
          settings.keys,
          containsAll([
            'PRODUCT_BUNDLE_IDENTIFIER',
            'APP_DISPLAY_NAME',
            'APP_AUTH_REDIRECT_SCHEME',
          ]),
        );
      });

      test('uses the same display name as the Android flavor', () {
        expect(settings['APP_DISPLAY_NAME'], _androidAppNames()[flavor.name]);
      });

      test('suffixes the bundle ID and redirect scheme outside prod', () {
        final suffix = flavor == Flavor.prod ? '' : '.${flavor.name}';
        expect(
          settings['PRODUCT_BUNDLE_IDENTIFIER'],
          'dev.crave.customerApp$suffix',
        );
        expect(
          settings['APP_AUTH_REDIRECT_SCHEME'],
          'dev.crave.customer.${flavor.name}',
        );
      });

      for (final configuration in ['Debug', 'Release', 'Profile']) {
        test(
          '$configuration-${flavor.name}.xcconfig includes its settings',
          () {
            final lines = File(
              '$flutterDir/$configuration-${flavor.name}.xcconfig',
            ).readAsLinesSync();

            expect(lines, [
              '#include "Generated.xcconfig"',
              '#include "flavors/${flavor.name}.xcconfig"',
            ]);
          },
        );
      }
    });
  }

  test('flavors/ has one file per flavor and nothing else', () {
    final names = Directory('$flutterDir/flavors')
        .listSync()
        .map((entry) => entry.uri.pathSegments.last)
        .toSet();

    expect(names, {
      for (final flavor in Flavor.values) '${flavor.name}.xcconfig',
    });
  });
}

/// The `KEY = value` settings in an xcconfig file, skipping comments.
Map<String, String> _readSettings(String path) => {
  for (final line in File(path).readAsLinesSync())
    if (RegExp(r'^\s*(\w+)\s*=\s*(.*?)\s*$').firstMatch(line) case final m?)
      m.group(1)!: m.group(2)!,
};

/// The `app_name` of each Android product flavor, by flavor name.
Map<String, String> _androidAppNames() {
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();
  return {
    for (final match in RegExp(
      r'create\("(\w+)"\)\s*\{[^}]*'
      r'resValue\("string",\s*"app_name",\s*"([^"]+)"\)',
    ).allMatches(gradle))
      match.group(1)!: match.group(2)!,
  };
}
