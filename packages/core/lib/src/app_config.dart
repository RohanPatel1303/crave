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
  /// Creates a configuration from the `FLAVOR` and `API_BASE_URL` defines.
  factory AppConfig.fromEnvironment() => AppConfig.parse(
    flavor: Flavor.parse(const String.fromEnvironment('FLAVOR')),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
  );

  /// Creates an app configuration from its flavor and API base URL.
  ///
  /// Throws [ArgumentError] when the URL is empty, is not absolute, or uses
  /// a non-HTTPS scheme for the production flavor.
  factory AppConfig.parse({
    required Flavor flavor,
    required String apiBaseUrl,
  }) {
    if (apiBaseUrl.isEmpty) {
      throw ArgumentError(
        'API_BASE_URL is required. Provide it with '
        '--dart-define-from-file=config/<flavor>.json.',
      );
    }

    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError(
        'API_BASE_URL must be an absolute URL with a scheme and host.',
      );
    }

    if (flavor == Flavor.prod && uri.scheme != 'https') {
      throw ArgumentError('Production API_BASE_URL must use HTTPS.');
    }

    return AppConfig._(flavor: flavor, apiBaseUrl: uri);
  }

  AppConfig._({required this.flavor, required this.apiBaseUrl});

  /// The build flavor.
  final Flavor flavor;

  /// The parsed base URI used for API requests.
  final Uri apiBaseUrl;

  /// Whether verbose logging should be enabled for this flavor.
  bool get verboseLogging => flavor != Flavor.prod;

  /// Whether this configuration uses the production flavor.
  bool get isProduction => flavor == Flavor.prod;
}
