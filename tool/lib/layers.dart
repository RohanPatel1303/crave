/// Information about a package used to check dependency layers.
final class PackageInfo {
  /// Creates package information with its name, path, and dependencies.
  const PackageInfo({
    required this.name,
    required this.path,
    required this.dependencies,
  });

  /// The package's name.
  final String name;

  /// The package's path relative to the repository root.
  final String path;

  /// The names of packages this package depends on.
  final Set<String> dependencies;
}

const _layerPrefixes = <String, int>{
  'packages/core': 0,
  'packages/design_system': 1,
  'packages/data': 1,
  'packages/features': 2,
  'apps': 3,
};

int? _layerForPath(String path) {
  for (final entry in _layerPrefixes.entries) {
    if (path == entry.key || path.startsWith('${entry.key}/')) {
      return entry.value;
    }
  }
  return null;
}

bool _isToolingPath(String path) => path == 'tool' || path.startsWith('tool/');

/// Returns dependency-layer violations found among [packages].
List<String> findViolations(List<PackageInfo> packages) {
  final checkedPackages = packages
      .where((package) => !_isToolingPath(package.path))
      .toList();

  final packagesByName = {
    for (final package in checkedPackages) package.name: package,
  };

  final violations = <String>[];

  for (final package in checkedPackages) {
    final layer = _layerForPath(package.path);

    if (layer == null) {
      violations.add(
        'Package ${package.name} at ${package.path} is not assigned a layer.',
      );
      continue;
    }

    for (final dependencyName in package.dependencies) {
      if (layer == 0 && dependencyName == 'flutter') {
        violations.add(
          'Layer 0 package ${package.name} must not depend on Flutter.',
        );
        continue;
      }

      final dependency = packagesByName[dependencyName];
      if (dependency == null) {
        continue;
      }

      final dependencyLayer = _layerForPath(dependency.path);
      if (dependencyLayer == null) {
        violations.add(
          'Package ${package.name} depends on ${dependency.name}, '
          'which is not assigned a layer.',
        );
      } else if (dependencyLayer >= layer) {
        violations.add(
          'Package ${package.name} (layer $layer) may not depend on '
          '${dependency.name} (layer $dependencyLayer).',
        );
      }
    }
  }

  return violations;
}
