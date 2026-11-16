import 'package:drift/native.dart';
import 'package:local_store/src/crave_database.dart';

/// Opens an empty [CraveDatabase] in memory, so tests need not import drift.
///
/// Close it in `tearDown`.
CraveDatabase inMemoryCraveDatabase() => CraveDatabase(NativeDatabase.memory());
