import 'package:meta/meta.dart';

/// The tokens issued for one signed-in session.
///
/// Stored as a single entry so the access and refresh tokens are always
/// written together.
@immutable
final class TokenSet {
  /// Creates a token set.
  const TokenSet({
    required this.accessToken,
    required this.refreshToken,
    required this.idToken,
    required this.accessTokenExpiresAt,
  });

  /// Creates a token set from the JSON produced by [toJson].
  factory TokenSet.fromJson(Object? json) {
    if (json case {
      'accessToken': final String accessToken,
      'refreshToken': final String refreshToken,
      'idToken': final String idToken,
      'accessTokenExpiresAt': final String expiresAt,
    }) {
      final accessTokenExpiresAt = DateTime.tryParse(expiresAt);
      if (accessTokenExpiresAt != null) {
        return TokenSet(
          accessToken: accessToken,
          refreshToken: refreshToken,
          idToken: idToken,
          accessTokenExpiresAt: accessTokenExpiresAt,
        );
      }
    }

    throw const FormatException('Invalid token set.');
  }

  /// The bearer token sent to the API.
  final String accessToken;

  /// The token used to obtain a new access token.
  final String refreshToken;

  /// The ID token, used as a hint when ending the session.
  final String idToken;

  /// When [accessToken] stops being accepted.
  final DateTime accessTokenExpiresAt;

  /// Returns the token set after a refresh.
  ///
  /// A refresh response may leave out [refreshToken] or [idToken], which in
  /// OAuth means "keep the current one", so those fall back to this set's.
  TokenSet refreshedWith({
    required String accessToken,
    required DateTime accessTokenExpiresAt,
    String? refreshToken,
    String? idToken,
  }) => TokenSet(
    accessToken: accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    idToken: idToken ?? this.idToken,
    accessTokenExpiresAt: accessTokenExpiresAt,
  );

  /// Converts this token set to JSON for storage.
  Map<String, Object?> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'accessTokenExpiresAt': accessTokenExpiresAt.toUtc().toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenSet &&
          other.accessToken == accessToken &&
          other.refreshToken == refreshToken &&
          other.idToken == idToken &&
          other.accessTokenExpiresAt.isAtSameMomentAs(accessTokenExpiresAt);

  @override
  int get hashCode => Object.hash(
    accessToken,
    refreshToken,
    idToken,
    accessTokenExpiresAt.microsecondsSinceEpoch,
  );
}
