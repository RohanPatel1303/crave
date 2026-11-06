import 'package:api_client/api_client.dart';
import 'package:auth_feature/auth_feature.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Greets the signed-in user.
///
/// Loads the user once when shown, and again on Retry after a failure.
class HomePage extends StatefulWidget {
  const HomePage({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Result<CurrentUser>> _user = widget.apiClient.me();

  void _retry() => setState(() {
    _user = widget.apiClient.me();
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'What are you craving?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: Spacing.md),
                FutureBuilder<Result<CurrentUser>>(
                  future: _user,
                  builder: (context, snapshot) => switch (snapshot.data) {
                    null => const CircularProgressIndicator(),
                    Ok(value: final user) => Text(
                      user.email,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    Err(:final failure) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          failure.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: Spacing.sm),
                        AppButton(
                          label: 'Retry',
                          variant: AppButtonVariant.secondary,
                          onPressed: _retry,
                        ),
                      ],
                    ),
                  },
                ),
                const SizedBox(height: Spacing.xl),
                AppButton(label: 'Start an order', onPressed: () {}),
                const SizedBox(height: Spacing.md),
                AppButton(
                  label: 'Sign out',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.read<AuthBloc>().add(
                    const AuthSignOutRequested(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
