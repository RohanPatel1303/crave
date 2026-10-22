import 'dart:io';

import 'package:repo_tools/layers.dart';
import 'package:yaml/yaml.dart';

Future<void> main() async {
  final rootPubspec = loadYaml(await File('pubspec.yaml').readAsString());

  if (rootPubspec is! YamlMap || rootPubspec['workspace'] is! YamlList) {
    throw const FormatException(
      'Root pubspec.yaml must contain a workspace list.',
    );
  }

  final packagePaths = await _workspacePackagePaths(
    rootPubspec['workspace'] as YamlList,
  );

  final packages = <PackageInfo>[];

  for (final path in packagePaths.toList()..sort()) {
    final pubspec = loadYaml(await File('$path/pubspec.yaml').readAsString());

    if (pubspec is! YamlMap || pubspec['name'] is! String) {
      throw FormatException('$path/pubspec.yaml must define a package name.');
    }

    final dependencies = <String>{};
    for (final sectionName in ['dependencies', 'dev_dependencies']) {
      final section = pubspec[sectionName];
      if (section is YamlMap) {
        dependencies.addAll(section.keys.whereType<String>());
      }
    }

    packages.add(
      PackageInfo(
        name: pubspec['name'] as String,
        path: path,
        dependencies: dependencies,
      ),
    );
  }

  final violations = findViolations(packages);
  for (final violation in violations) {
    stderr.writeln(violation);
  }

  if (violations.isNotEmpty) {
    exitCode = 1;
  }
}

Future<Set<String>> _workspacePackagePaths(YamlList workspace) async {
  final paths = <String>{};

  for (final entry in workspace) {
    if (entry is! String) {
      throw const FormatException('Workspace entries must be strings.');
    }

    if (entry.endsWith('/*')) {
      final parentPath = entry.substring(0, entry.length - 2);
      final parent = Directory(parentPath);

      if (!parent.existsSync()) {
        throw FileSystemException(
          'Workspace glob directory does not exist',
          parentPath,
        );
      }

      await for (final entity in parent.list(followLinks: false)) {
        if (entity is Directory &&
            File('${entity.path}/pubspec.yaml').existsSync()) {
          paths.add(entity.path);
        }
      }
    } else {
      final directory = Directory(entry);
      if (!directory.existsSync()) {
        throw FileSystemException(
          'Workspace package directory does not exist',
          entry,
        );
      }

      if (!File('$entry/pubspec.yaml').existsSync()) {
        throw FileSystemException(
          'Workspace package has no pubspec.yaml',
          entry,
        );
      }

      paths.add(entry);
    }
  }

  return paths;
}
