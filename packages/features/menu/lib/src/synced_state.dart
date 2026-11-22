import 'package:core/core.dart';
import 'package:meta/meta.dart';

/// The state of data that is read from the database and refreshed from the
/// network ([ADR 0011](../../../../../docs/adr/0011-offline-first-reads.md)).
///
/// [data] comes from the database, and [refreshing] and [refreshFailure]
/// describe the network refresh, so a failed refresh never hides stored data.
@immutable
final class SyncedState<T> {
  /// Creates a state. The defaults describe a state before the database has
  /// emitted anything.
  const SyncedState({
    this.data,
    this.loaded = false,
    this.refreshing = false,
    this.refreshFailure,
  });

  /// The latest value from the database, or null until it has one.
  final T? data;

  /// Whether the database has emitted at least once. When it is true and
  /// [data] is null, the database has nothing stored.
  final bool loaded;

  /// Whether a refresh from the network is in progress.
  final bool refreshing;

  /// The failure from the last refresh, if it failed. Clear it with
  /// `copyWith(clearFailure: true)` when a refresh starts.
  final AppFailure? refreshFailure;

  /// Returns a copy with the given fields replaced.
  ///
  /// A null argument keeps the current value. To set [data] or
  /// [refreshFailure] to null, pass [clearData] or [clearFailure] instead;
  /// passing a value together with its clear flag is an error.
  SyncedState<T> copyWith({
    T? data,
    bool clearData = false,
    bool? loaded,
    bool? refreshing,
    AppFailure? refreshFailure,
    bool clearFailure = false,
  }) {
    assert(
      !(clearData && data != null),
      'Pass either data or clearData, not both.',
    );
    assert(
      !(clearFailure && refreshFailure != null),
      'Pass either refreshFailure or clearFailure, not both.',
    );
    return SyncedState<T>(
      data: clearData ? null : data ?? this.data,
      loaded: loaded ?? this.loaded,
      refreshing: refreshing ?? this.refreshing,
      refreshFailure: clearFailure
          ? null
          : refreshFailure ?? this.refreshFailure,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncedState<T> &&
          other.data == data &&
          other.loaded == loaded &&
          other.refreshing == refreshing &&
          other.refreshFailure == refreshFailure;

  @override
  int get hashCode => Object.hash(data, loaded, refreshing, refreshFailure);

  @override
  String toString() =>
      'SyncedState(data: $data, loaded: $loaded, refreshing: $refreshing, '
      'refreshFailure: $refreshFailure)';
}
