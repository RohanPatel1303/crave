import 'package:flutter/foundation.dart' show immutable;

/// The authenticated user returned by the API.
@immutable
final class CurrentUser {
  /// Creates a user with an identifier and email address.
  const CurrentUser({required this.id, required this.email});

  /// Creates a user from an API response.
  factory CurrentUser.fromJson(Object? json) {
    if (json case {'id': final String id, 'email': final String email}) {
      return CurrentUser(id: id, email: email);
    }

    throw const FormatException('Invalid user response.');
  }

  /// The user's stable identifier.
  final String id;

  /// The user's email address.
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentUser && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}
