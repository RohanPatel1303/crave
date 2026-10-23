import 'package:repo_tools/coverage.dart';
import 'package:test/test.dart';

void main() {
  test('calculates coverage from LCOV line totals', () {
    final report = evaluateCoverage(
      {'packages/core': 'LF:10\nLH:9\n'},
      packagesWithTests: {'packages/core'},
    );

    expect(report.passes, isTrue);
    expect(report.packages['packages/core']?.percent, 90);
    expect(report.total.percent, 90);
  });

  test('sums line totals across packages before applying the threshold', () {
    final report = evaluateCoverage(
      {
        'packages/core': 'LF:10\nLH:9\n',
        'packages/design_system': 'LF:100\nLH:50\n',
      },
      packagesWithTests: {'packages/core', 'packages/design_system'},
    );

    expect(report.total.linesFound, 110);
    expect(report.total.linesHit, 59);
    expect(report.total.percent, closeTo(53.64, 0.01));
    expect(report.passes, isFalse);
  });

  test('fails when no coverage input is available', () {
    final report = evaluateCoverage(const {}, packagesWithTests: const {});

    expect(report.passes, isFalse);
    expect(report.failures, contains(contains('No coverage/lcov.info files')));
    expect(report.total.percent, 0);
  });

  test('fails when a package with tests has no LCOV report', () {
    final report = evaluateCoverage(
      const {'packages/core': null},
      packagesWithTests: const {'packages/core'},
    );

    expect(report.passes, isFalse);
    expect(report.failures, contains(contains('packages/core')));
    expect(report.failures, contains(contains('missing coverage/lcov.info')));
  });
}
