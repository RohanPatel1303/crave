/// Default minimum workspace line coverage percentage.
const double defaultCoverageThreshold = 80;

/// Line counts for one package's LCOV report.
final class CoverageTotals {
  /// Creates coverage totals from LCOV line counts.
  const CoverageTotals({required this.linesFound, required this.linesHit});

  /// The number of executable lines found.
  final int linesFound;

  /// The number of executable lines hit.
  final int linesHit;

  /// The percentage of executable lines hit.
  double get percent => linesFound == 0 ? 0 : linesHit * 100 / linesFound;
}

/// Coverage totals and any reasons the coverage gate should fail.
final class CoverageReport {
  CoverageReport._({
    required Map<String, CoverageTotals> packages,
    required this.total,
    required List<String> failures,
    required this.threshold,
  }) : packages = Map.unmodifiable(packages),
       failures = List.unmodifiable(failures);

  /// Coverage totals keyed by package path.
  final Map<String, CoverageTotals> packages;

  /// Combined coverage totals for the workspace.
  final CoverageTotals total;

  /// Reasons this report does not pass the gate.
  final List<String> failures;

  /// The minimum required workspace line coverage.
  final double threshold;

  /// Whether the workspace satisfies the coverage gate.
  bool get passes => failures.isEmpty;
}

/// Evaluates workspace LCOV contents without accessing the filesystem.
///
/// [lcovByPackage] maps package paths to LCOV contents, or `null` when no
/// report exists. Every package in [packagesWithTests] must have a report.
CoverageReport evaluateCoverage(
  Map<String, String?> lcovByPackage, {
  required Set<String> packagesWithTests,
  double threshold = defaultCoverageThreshold,
}) {
  if (!threshold.isFinite || threshold < 0 || threshold > 100) {
    throw ArgumentError.value(
      threshold,
      'threshold',
      'Must be between 0 and 100.',
    );
  }

  final failures = <String>[];
  for (final package in packagesWithTests.toList()..sort()) {
    if (lcovByPackage[package] == null) {
      failures.add(
        '$package: missing coverage/lcov.info for package with tests.',
      );
    }
  }

  final packages = <String, CoverageTotals>{};
  for (final entry
      in lcovByPackage.entries.toList()
        ..sort((left, right) => left.key.compareTo(right.key))) {
    final contents = entry.value;
    if (contents == null) continue;

    var linesFound = 0;
    var linesHit = 0;
    var hasLineCounts = false;
    for (final line in contents.split('\n')) {
      if (line.startsWith('LF:')) {
        final value = int.tryParse(line.substring(3));
        if (value == null || value < 0) {
          failures.add('${entry.key}: invalid LCOV line count "$line".');
        } else {
          linesFound += value;
          hasLineCounts = true;
        }
      } else if (line.startsWith('LH:')) {
        final value = int.tryParse(line.substring(3));
        if (value == null || value < 0) {
          failures.add('${entry.key}: invalid LCOV hit count "$line".');
        } else {
          linesHit += value;
          hasLineCounts = true;
        }
      }
    }

    if (!hasLineCounts) {
      failures.add('${entry.key}: LCOV report contains no line totals.');
    }
    if (linesHit > linesFound) {
      failures.add('${entry.key}: LCOV hits exceed the number of lines found.');
    }

    packages[entry.key] = CoverageTotals(
      linesFound: linesFound,
      linesHit: linesHit,
    );
  }

  final total = packages.values.fold(
    const CoverageTotals(linesFound: 0, linesHit: 0),
    (sum, package) => CoverageTotals(
      linesFound: sum.linesFound + package.linesFound,
      linesHit: sum.linesHit + package.linesHit,
    ),
  );

  if (packages.isEmpty) {
    failures.add('No coverage/lcov.info files found under packages/ or apps/.');
  } else if (total.linesFound == 0) {
    failures.add('Coverage reports contain no executable lines.');
  } else if (total.percent < threshold) {
    failures.add(
      'Total coverage ${total.percent.toStringAsFixed(1)}% is below '
      'the ${threshold.toStringAsFixed(1)}% threshold.',
    );
  }

  return CoverageReport._(
    packages: packages,
    total: total,
    failures: failures,
    threshold: threshold,
  );
}
