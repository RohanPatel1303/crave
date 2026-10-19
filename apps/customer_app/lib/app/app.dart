import 'package:core/core.dart';
import 'package:customer_app/app/di.dart';
import 'package:customer_app/app/router.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CraveApp extends StatefulWidget {
  const CraveApp({this.router, super.key});

  final GoRouter? router;

  @override
  State<CraveApp> createState() => _CraveAppState();
}

class _CraveAppState extends State<CraveApp> {
  late final GoRouter _router = widget.router ?? createRouter();
  late final bool _ownsRouter = widget.router == null;

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    final app = MaterialApp.router(
      title: config.isProduction ? 'Crave' : 'Crave ${config.flavor.name}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (config.isProduction) return content;
        return Banner(
          message: config.flavor.name,
          location: BannerLocation.topEnd,
          child: content,
        );
      },
    );
    return app;
  }

  @override
  void dispose() {
    if (_ownsRouter) _router.dispose();
    super.dispose();
  }
}
