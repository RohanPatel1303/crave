import 'package:auth_feature/src/auth_bloc.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lets the user start the hosted sign-in.
///
/// Reads the [AuthBloc] from the widget tree.
class SignInPage extends StatelessWidget {
  /// Creates the sign-in page.
  const SignInPage({super.key});

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
                  'Crave',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: Spacing.xl),
                AppButton(
                  label: 'Sign in',
                  onPressed: () =>
                      context.read<AuthBloc>().add(const AuthSignInRequested()),
                ),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => switch (state) {
                    Unauthenticated(failure: final failure?) => Padding(
                      padding: const EdgeInsets.only(top: Spacing.md),
                      child: Text(
                        failure.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    _ => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
