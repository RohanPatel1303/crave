import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards Android manifest settings that only fail on a device.
void main() {
  test('MainActivity does not set taskAffinity', () {
    final xml = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    // With taskAffinity="" (Flutter's template default), AppAuth's redirect
    // lands in a different task, logs "No stored state", and drops the
    // sign-in result, so the app never gets its tokens.
    expect(xml, isNot(contains('android:taskAffinity')));
  });
}
