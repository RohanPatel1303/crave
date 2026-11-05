import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards that cleartext HTTP is allowed only in the dev flavor, and only to
/// localhost. Nothing else checks these files until the app hits the network.
void main() {
  const androidSrc = 'android/app/src';

  test('dev network security config permits cleartext only to localhost', () {
    final file = File('$androidSrc/dev/res/xml/network_security_config.xml');
    expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
    final xml = file.readAsStringSync();

    expect(
      RegExp('cleartextTrafficPermitted="true"').allMatches(xml),
      hasLength(1),
    );
    expect(xml, isNot(contains('<base-config')));
    final domains = RegExp('<domain[^>]*>([^<]*)</domain>')
        .allMatches(xml)
        .map((m) => m.group(1)!.trim())
        .toList();
    expect(domains, ['localhost']);
    expect(xml, contains('includeSubdomains="false"'));
  });

  test('dev manifest applies the network security config', () {
    final xml = File('$androidSrc/dev/AndroidManifest.xml').readAsStringSync();

    expect(
      xml,
      contains('android:networkSecurityConfig="@xml/network_security_config"'),
    );
  });

  test('no other source set enables cleartext traffic', () {
    final offenders = Directory(androidSrc)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.xml'))
        .where((f) => !f.path.startsWith('$androidSrc/dev/'))
        .where((f) {
          final xml = f.readAsStringSync();
          return xml.contains('usesCleartextTraffic="true"') ||
              xml.contains('cleartextTrafficPermitted="true"') ||
              xml.contains('networkSecurityConfig');
        })
        .map((f) => f.path)
        .toList();

    expect(offenders, isEmpty);
  });
}
