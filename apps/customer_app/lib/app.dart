import 'package:core/core.dart';
import 'package:customer_app/app/di.dart';
import 'package:flutter/material.dart';

class CraveApp extends StatelessWidget {
  const CraveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = getIt<AppConfig>();
    return MaterialApp(
      title: 'Crave ${config.flavor.name}',
      home: const Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
