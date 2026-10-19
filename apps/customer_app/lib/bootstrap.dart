import 'dart:ui';

import 'package:core/core.dart';
import 'package:customer_app/app/app.dart';
import 'package:customer_app/app/app_bloc_observer.dart';
import 'package:customer_app/app/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Throws [StateError] when the native flavor and the FLAVOR define disagree.
///
/// A null [nativeFlavor] is allowed because iOS does not yet define a native
/// flavor.
void ensureFlavorsMatch({
  required Flavor configFlavor,
  required String? nativeFlavor,
}) {
  if (nativeFlavor != null && nativeFlavor != configFlavor.name) {
    throw StateError(
      'Native flavor "$nativeFlavor" does not match '
      'FLAVOR "${configFlavor.name}".',
    );
  }
}

Future<void> bootstrap() async {
  final config = AppConfig.fromEnvironment();
  final logger = ConsoleLogger(
    minLevel: config.verboseLogging ? LogLevel.debug : LogLevel.info,
  );
  // Config and flavor errors are thrown before the error hooks exist, on
  // purpose: they can only come from a misconfigured build, so they should
  // crash loudly at launch (visible in logcat) rather than be reported.
  WidgetsFlutterBinding.ensureInitialized();
  ensureFlavorsMatch(configFlavor: config.flavor, nativeFlavor: appFlavor);
  logger.info('Starting Crave ${config.flavor.name}');
  final presentFlutterError = FlutterError.presentError;
  FlutterError.onError = (details) {
    logger.error(
      'Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
    presentFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught error', error: error, stackTrace: stack);
    return true;
  };
  Bloc.observer = AppBlocObserver(logger);
  await configureDependencies(config: config, logger: logger);
  runApp(const CraveApp());
}
