import 'package:core/core.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  required AppConfig config,
  required AppLogger logger,
}) async {
  getIt
    ..registerSingleton<AppConfig>(config)
    ..registerSingleton<AppLogger>(logger);
}

Future<void> resetDependencies() => getIt.reset();
