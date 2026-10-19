import 'dart:ui';

import 'package:core/core.dart';
import 'package:customer_app/app.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  ensureFlavorsMatch(configFlavor: config.flavor, nativeFlavor: appFlavor);
  final logger = ConsoleLogger(
    minLevel: config.verboseLogging ? LogLevel.debug : LogLevel.info,
  );
  final logInfo = logger.info;
  final logError = logger.error;
  logInfo('Starting Crave ${config.flavor.name}');
  final presentFlutterError = FlutterError.presentError;
  FlutterError.onError = (details) {
    logError(
      'Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
    presentFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logError('Uncaught error', error: error, stackTrace: stack);
    return true;
  };
  Bloc.observer = AppBlocObserver(logger);
  await configureDependencies(config: config, logger: logger);
  runApp(const CraveApp());
}
