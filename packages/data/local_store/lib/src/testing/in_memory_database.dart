import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:local_store/src/crave_database.dart';

/// Opens an empty [CraveDatabase] in memory, so tests need not import drift.
///
/// Its query streams stop as soon as their last listener leaves, instead of
/// one event loop later, so widget tests do not fail on a pending timer.
///
/// Close it in `tearDown`.
CraveDatabase inMemoryCraveDatabase() => CraveDatabase(
  DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true),
);
