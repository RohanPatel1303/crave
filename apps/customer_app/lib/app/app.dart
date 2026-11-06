import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// The app root. Its dependencies come from the composition root in
/// `bootstrap`, so no widget reads the service locator.
class CraveApp extends StatelessWidget {
  const CraveApp({
    required this.config,
    required this.authBloc,
    required this.router,
    super.key,
  });

  final AppConfig config;
  final AuthBloc authBloc;
  final GoRouter router;

  @override
  Widget build(BuildContext context) => BlocProvider<AuthBloc>.value(
    value: authBloc,
    child: MaterialApp.router(
      title: config.isProduction ? 'Crave' : 'Crave ${config.flavor.name}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (config.isProduction) return content;
        return Banner(
          message: config.flavor.name,
          location: BannerLocation.topEnd,
          child: content,
        );
      },
    ),
  );
}
