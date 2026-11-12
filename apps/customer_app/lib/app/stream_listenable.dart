import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies listeners once for each event of a stream.
///
/// Use it to drive a [Listenable] API, such as `GoRouter.refreshListenable`,
/// from a stream, such as a bloc's states. The subscription ends when the
/// stream does, which for a bloc's stream is when the bloc closes, or when
/// this is disposed.
final class StreamListenable extends ChangeNotifier {
  /// Listens to [stream] until it ends or [dispose] is called.
  StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
