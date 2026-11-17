import 'package:meta/meta.dart';

/// The outcome of a conditional request that sent the last known ETag.
@immutable
sealed class Revalidated<T> {
  /// Creates a revalidation outcome.
  const Revalidated();
}

/// The server sent a new representation, which replaces the cached one.
final class Fresh<T> extends Revalidated<T> {
  /// Creates a fresh outcome with the decoded [value] and its [etag].
  const Fresh(this.value, {required this.etag});

  /// The decoded response body.
  final T value;

  /// The response's ETag, or `null` if the server sent none.
  final String? etag;

  @override
  bool operator ==(Object other) =>
      other is Fresh<T> && other.value == value && other.etag == etag;

  @override
  int get hashCode => Object.hash(value, etag);

  @override
  String toString() => 'Fresh($value, etag: $etag)';
}

/// The server answered 304 Not Modified, so the cached copy is still current.
final class NotModified<T> extends Revalidated<T> {
  /// Creates a not-modified outcome.
  const NotModified();

  @override
  bool operator ==(Object other) => other is NotModified<T>;

  @override
  int get hashCode => (NotModified<T>).hashCode;

  @override
  String toString() => 'NotModified()';
}
