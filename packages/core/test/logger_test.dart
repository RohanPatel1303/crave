import 'package:core/core.dart';
import 'package:test/test.dart';

void main() {
  group('ConsoleLogger', () {
    test('drops entries below the minimum level', () {
      final lines = <String>[];
      ConsoleLogger(
        minLevel: LogLevel.info,
        sink: lines.add,
      ).log(LogLevel.debug, 'Debug details');

      expect(lines, isEmpty);
    });

    test(
      'writes entries at or above the minimum level with a level prefix',
      () {
        final lines = <String>[];
        ConsoleLogger(minLevel: LogLevel.info, sink: lines.add)
          ..log(LogLevel.info, 'Order placed')
          ..log(LogLevel.warning, 'Inventory is low')
          ..log(LogLevel.error, 'Payment failed');

        expect(lines, [
          '[INFO] Order placed',
          '[WARNING] Inventory is low',
          '[ERROR] Payment failed',
        ]);
      },
    );

    test('appends an error when one is provided', () {
      final lines = <String>[];
      ConsoleLogger(
        minLevel: LogLevel.debug,
        sink: lines.add,
      ).log(LogLevel.error, 'Request failed', error: StateError('offline'));

      expect(lines, ['[ERROR] Request failed | Bad state: offline']);
    });

    test('appends a stack trace on its own line when one is provided', () {
      final lines = <String>[];
      final stackTrace = StackTrace.fromString('line 1\nline 2');

      ConsoleLogger(
        minLevel: LogLevel.debug,
        sink: lines.add,
      ).log(LogLevel.error, 'Request failed', stackTrace: stackTrace);

      expect(lines, ['[ERROR] Request failed\n$stackTrace']);
    });

    test('extension shorthands log at their respective levels', () {
      final lines = <String>[];
      ConsoleLogger(minLevel: LogLevel.debug, sink: lines.add)
        ..debug('Debug details')
        ..info('Order placed')
        ..warning('Inventory is low')
        ..error('Payment failed');

      expect(lines, [
        '[DEBUG] Debug details',
        '[INFO] Order placed',
        '[WARNING] Inventory is low',
        '[ERROR] Payment failed',
      ]);
    });
  });
}
