import 'package:repo_tools/layers.dart';
import 'package:test/test.dart';

void main() {
  test('allows dependencies on lower layers and external packages', () {
    final packages = [
      const PackageInfo(
        name: 'core',
        path: 'packages/core',
        dependencies: <String>{},
      ),
      const PackageInfo(
        name: 'design_system',
        path: 'packages/design_system',
        dependencies: {'core'},
      ),
      const PackageInfo(
        name: 'customer_app',
        path: 'apps/customer_app',
        dependencies: {'design_system', 'go_router'},
      ),
    ];

    expect(findViolations(packages), isEmpty);
  });

  test('reports a layer 0 package depending on layer 1', () {
    final packages = [
      const PackageInfo(
        name: 'core',
        path: 'packages/core',
        dependencies: {'design_system'},
      ),
      const PackageInfo(
        name: 'design_system',
        path: 'packages/design_system',
        dependencies: <String>{},
      ),
    ];

    final violations = findViolations(packages);

    expect(violations, hasLength(1));
    expect(
      violations.single,
      allOf(
        contains('core'),
        contains('layer 0'),
        contains('design_system'),
        contains('layer 1'),
      ),
    );
  });

  test('reports dependencies between packages in the same layer', () {
    final packages = [
      const PackageInfo(
        name: 'design_system',
        path: 'packages/design_system',
        dependencies: {'catalog'},
      ),
      const PackageInfo(
        name: 'catalog',
        path: 'packages/data/catalog',
        dependencies: <String>{},
      ),
    ];

    expect(findViolations(packages), hasLength(1));
  });

  test('reports layer 0 depending on Flutter', () {
    const packages = [
      PackageInfo(
        name: 'core',
        path: 'packages/core',
        dependencies: {'flutter'},
      ),
    ];

    expect(findViolations(packages), hasLength(1));
  });

  test('reports packages whose paths are not assigned a layer', () {
    const packages = [
      PackageInfo(
        name: 'misc',
        path: 'packages/misc',
        dependencies: <String>{},
      ),
    ];

    expect(findViolations(packages), hasLength(1));
    expect(findViolations(packages).single, contains('not assigned a layer'));
  });

  test('ignores external dependencies', () {
    const packages = [
      PackageInfo(
        name: 'customer_app',
        path: 'apps/customer_app',
        dependencies: {'go_router'},
      ),
    ];

    expect(findViolations(packages), isEmpty);
  });
}
