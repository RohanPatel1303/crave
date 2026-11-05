import 'package:auth/auth.dart';

final storedTokens = TokenSet(
  accessToken: 'access',
  refreshToken: 'refresh',
  idToken: 'id',
  accessTokenExpiresAt: DateTime.utc(2100),
);
