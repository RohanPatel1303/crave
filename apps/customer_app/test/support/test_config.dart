import 'package:core/core.dart';

AppConfig testConfig(Flavor flavor) => AppConfig.parse(
  flavor: flavor,
  apiBaseUrl: 'https://api.example.com',
  oidcIssuer: 'https://id.example.com/realms/crave',
  oidcRedirectUri: 'dev.crave.customer:/oauthredirect',
);
