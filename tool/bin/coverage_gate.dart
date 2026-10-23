import 'dart:io';

import 'package:repo_tools/coverage.dart';

Future<void> main(List<String> args) async {
  final threshold = _parseThreshold(args);
  if (threshold == null) {
    stderr.writeln(
      'Usage: dart tool/bin/coverage_gate.dart [--threshold <0-100>]',
    );
    exitCode = 1;
    return;
  }

  final lcovByPackage = <String, String?>{};
  final packagesWithTests = <String>{};

  // Tooling is intentionally excluded; only product packages are gated.
  for (final root in ['packages', 'apps']) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      final parts = entity.path.replaceAll(r'\', '/').split('/');
      if (entity is Directory && parts.last == 'test') {
        final package = parts.take(parts.length - 1).join('/');
        if (File('$package/pubspec.yaml').existsSync()) {
          packagesWithTests.add(package);
          lcovByPackage.putIfAbsent(package, () => null);
        }
        continue;
      }

      if (entity is! File) continue;
      final coverageIndex = parts.indexOf('coverage');
      if (coverageIndex < 2 ||
          coverageIndex != parts.length - 2 ||
          parts.last != 'lcov.info' ||
          parts.first != root) {
        continue;
      }

      final package = parts.take(coverageIndex).join('/');
      if (!File('$package/pubspec.yaml').existsSync()) continue;
      final contents = await entity.readAsString();
      final previous = lcovByPackage[package];
      lcovByPackage[package] = previous == null
          ? contents
          : '$previous\n$contents';
    }
  }

  final report = evaluateCoverage(
    lcovByPackage,
    packagesWithTests: packagesWithTests,
    threshold: threshold,
  );

  stdout.writeln('Coverage by package:');
  for (final entry in report.packages.entries) {
    final totals = entry.value;
    stdout.writeln(
      '  ${entry.key}: ${_formatPercent(totals)} '
      '(${totals.linesHit}/${totals.linesFound} lines)',
    );
  }
  stdout.writeln(
    'Total coverage: ${_formatPercent(report.total)} '
    '(${report.total.linesHit}/${report.total.linesFound} lines; '
    'threshold ${threshold.toStringAsFixed(1)}%)',
  );

  for (final failure in report.failures) {
    stderr.writeln('Coverage gate failed: $failure');
  }
  if (!report.passes) exitCode = 1;
}

double? _parseThreshold(List<String> args) {
  var value = Platform.environment['COVERAGE_THRESHOLD'];
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--threshold' && i + 1 < args.length) {
      value = args[++i];
    } else if (args[i].startsWith('--threshold=')) {
      value = args[i].substring('--threshold='.length);
    } else {
      return null;
    }
  }

  final threshold = value == null
      ? defaultCoverageThreshold
      : double.tryParse(value);
  if (threshold == null ||
      !threshold.isFinite ||
      threshold < 0 ||
      threshold > 100) {
    return null;
  }
  return threshold;
}

String _formatPercent(CoverageTotals totals) =>
    '${totals.percent.toStringAsFixed(1)}%';
