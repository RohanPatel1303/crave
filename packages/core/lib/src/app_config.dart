/// Supported application build flavors.
enum Flavor {
  /// Local development.
  dev,

  /// Pre-release builds for QA and internal testers.
  staging,

  /// Store builds.
  prod;

  /// Parses the `FLAVOR` define into a [Flavor].
  ///
  /// Throws [ArgumentError] when [name] is empty or not a known flavor.
  /// There is deliberately no default: a build without a flavor is
  /// misconfigured, and silently falling back to [dev] would disable the
  /// production safety checks.
  static Flavor parse(String name) {
    final validNames = Flavor.values.map((flavor) => flavor.name).join(', ');

    if (name.isEmpty) {
      throw ArgumentError(
        'FLAVOR is required. Provide it with '
        '--dart-define-from-file=config/<flavor>.json.',
      );
    }

    for (final flavor in Flavor.values) {
      if (flavor.name == name) return flavor;
    }

    throw ArgumentError(
      'Unknown FLAVOR "$name". Expected one of: $validNames.',
    );
  }
}

/// Runtime configuration parsed from the application's compile-time defines.
final class AppConfig {
  /// Creates a configuration from the `FLAVOR`, `API_BASE_URL`, `OIDC_ISSUER`
  /// and `OIDC_REDIRECT_URI` defines.
  factory AppConfig.fromEnvironment() => AppConfig.parse(
    flavor: Flavor.parse(const String.fromEnvironment('FLAVOR')),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    oidcIssuer: const String.fromEnvironment('OIDC_ISSUER'),
    oidcRedirectUri: const String.fromEnvironment('OIDC_REDIRECT_URI'),
  );

  /// Creates an app configuration from its flavor, API base URL and OIDC
  /// settings.
  ///
  /// Throws [ArgumentError] when a value is empty, when a URL is not absolute,
  /// when a production API base URL is not HTTPS, or when the OIDC issuer is
  /// not HTTPS outside the dev flavor.
  factory AppConfig.parse({
    required Flavor flavor,
    required String apiBaseUrl,
    required String oidcIssuer,
    required String oidcRedirectUri,
  }) {
    final apiUri = _parseAbsoluteUrl('API_BASE_URL', apiBaseUrl);
    if (flavor == Flavor.prod && apiUri.scheme != 'https') {
      throw ArgumentError('Production API_BASE_URL must use HTTPS.');
    }

    final issuerUri = _parseAbsoluteUrl('OIDC_ISSUER', oidcIssuer);
    // Only dev lets the identity gateway use plain HTTP, so any other flavor
    // with an HTTP issuer would fail at the first sign-in instead of here.
    if (flavor != Flavor.dev && issuerUri.scheme != 'https') {
      throw ArgumentError('OIDC_ISSUER must use HTTPS outside the dev flavor.');
    }

    if (oidcRedirectUri.isEmpty) throw _missing('OIDC_REDIRECT_URI');

    return AppConfig._(
      flavor: flavor,
      apiBaseUrl: apiUri,
      oidcIssuer: issuerUri,
      oidcRedirectUri: oidcRedirectUri,
    );
  }

  AppConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.oidcIssuer,
    required this.oidcRedirectUri,
  });

  static Uri _parseAbsoluteUrl(String name, String value) {
    if (value.isEmpty) throw _missing(name);

    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError(
        '$name must be an absolute URL with a scheme and host.',
      );
    }
    return uri;
  }

  static ArgumentError _missing(String name) => ArgumentError(
    '$name is required. Provide it with '
    '--dart-define-from-file=config/<flavor>.json.',
  );

  /// The build flavor.
  final Flavor flavor;

  /// The parsed base URI used for API requests.
  final Uri apiBaseUrl;

  /// The OIDC identity provider's issuer URL.
  final Uri oidcIssuer;

  /// Where the identity provider redirects back to the app after sign-in.
  final String oidcRedirectUri;

  /// Whether verbose logging should be enabled for this flavor.
  bool get verboseLogging => flavor != Flavor.prod;

  /// Whether this configuration uses the production flavor.
  bool get isProduction => flavor == Flavor.prod;

  /// Whether the identity gateway may talk to a plain-HTTP provider, such as
  /// the local Keycloak. True only for the dev flavor.
  bool get allowInsecureIdentityConnections => flavor == Flavor.dev;
}
