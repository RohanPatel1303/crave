import 'dart:io';

const double _defaultThreshold = 80;

Future<void> main(List<String> args) async {
	final threshold = _parseThreshold(args);
	if (threshold == null) {
		stderr.writeln(
			'Usage: dart tool/bin/coverage_gate.dart [--threshold <0-100>]',
		);
		exitCode = 1;
		return;
	}

	final totalsByPackage = <String, _CoverageTotals>{};
	var lcovFileCount = 0;

	for (final root in ['packages', 'apps']) {
		final directory = Directory(root);
		if (!directory.existsSync()) continue;

		await for (final entity in directory.list(
			recursive: true,
			followLinks: false,
		)) {
			if (entity is! File) continue;

			final parts = entity.path.replaceAll(r'\', '/').split('/');
			final coverageIndex = parts.indexOf('coverage');
			if (coverageIndex < 2 ||
					coverageIndex != parts.length - 2 ||
					parts.last != 'lcov.info' ||
					parts.first != root) {
				continue;
			}

			final package = parts.take(coverageIndex).join('/');
			final totals = totalsByPackage.putIfAbsent(package, _CoverageTotals.new);
			totals.files++;
			lcovFileCount++;

			for (final line in await entity.readAsLines()) {
				if (line.startsWith('LF:')) {
					totals.linesFound += int.tryParse(line.substring(3)) ?? 0;
				} else if (line.startsWith('LH:')) {
					totals.linesHit += int.tryParse(line.substring(3)) ?? 0;
				}
			}
		}
	}

	if (lcovFileCount == 0) {
		stderr.writeln(
			'Coverage gate failed: no coverage/lcov.info files found under packages/ or apps/.',
		);
		exitCode = 1;
		return;
	}

	var totalFound = 0;
	var totalHit = 0;
	stdout.writeln('Coverage by package:');
	for (final package in totalsByPackage.keys.toList()..sort()) {
		final totals = totalsByPackage[package]!;
		totalFound += totals.linesFound;
		totalHit += totals.linesHit;
		stdout.writeln(
			'  $package: ${_formatPercent(totals.linesHit, totals.linesFound)} '
			'(${totals.linesHit}/${totals.linesFound} lines; ${totals.files} lcov file(s))',
		);
	}

	final totalPercent = _percent(totalHit, totalFound);
	stdout.writeln(
		'Total coverage: ${_formatPercent(totalHit, totalFound)} '
		'($totalHit/$totalFound lines; threshold ${threshold.toStringAsFixed(1)}%)',
	);

	if (totalFound == 0 || totalPercent < threshold) {
		stderr.writeln('Coverage gate failed.');
		exitCode = 1;
	}
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

	final threshold = value == null ? _defaultThreshold : double.tryParse(value);
	if (threshold == null ||
			!threshold.isFinite ||
			threshold < 0 ||
			threshold > 100) {
		return null;
	}
	return threshold;
}

double _percent(int hit, int found) => found == 0 ? 0 : hit * 100 / found;

String _formatPercent(int hit, int found) =>
		'${_percent(hit, found).toStringAsFixed(1)}%';

class _CoverageTotals {
	int linesFound = 0;
	int linesHit = 0;
	int files = 0;
}
