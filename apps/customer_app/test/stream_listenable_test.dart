import 'dart:async';

import 'package:customer_app/app/stream_listenable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<int> controller;

  setUp(() {
    controller = StreamController<int>();
  });

  tearDown(() async {
    await controller.close();
  });

  test('notifies listeners once per stream event', () async {
    final listenable = StreamListenable(controller.stream);
    addTearDown(listenable.dispose);
    var notifications = 0;
    listenable.addListener(() => notifications++);

    controller
      ..add(1)
      ..add(2)
      ..add(3);
    await Future<void>.delayed(Duration.zero);

    expect(notifications, 3);
  });

  test('cancels its stream subscription when disposed', () {
    final listenable = StreamListenable(controller.stream);
    expect(controller.hasListener, isTrue);

    listenable.dispose();

    expect(controller.hasListener, isFalse);
  });
}
