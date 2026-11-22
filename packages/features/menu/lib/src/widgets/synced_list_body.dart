import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// The body shared by screens that show a `SyncedState`.
///
/// - A spinner before the database emits, or while a refresh runs with
///   nothing to show.
/// - With nothing to show and a failure, the failure's message and a Retry
///   button.
/// - Otherwise a pull-to-refresh list of [children], with [notice] above it
///   when [failure] is set.
class SyncedListBody extends StatelessWidget {
  /// Creates the body. [hasData] says whether there is anything to show.
  const SyncedListBody({
    required this.loaded,
    required this.hasData,
    required this.refreshing,
    required this.failure,
    required this.notice,
    required this.emptyMessage,
    required this.onRefresh,
    required this.children,
    super.key,
  });

  /// Whether the database has emitted.
  final bool loaded;

  /// Whether there is data to show.
  final bool hasData;

  /// Whether a refresh is running.
  final bool refreshing;

  /// The failure from the last refresh, if any.
  final AppFailure? failure;

  /// Shown above the data when the last refresh failed.
  final String notice;

  /// Shown when there is no data, no refresh and no failure.
  final String emptyMessage;

  /// Starts a refresh, finishing when it does.
  final Future<void> Function() onRefresh;

  /// The rows to show when there is data.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;
    if (!loaded || (!hasData && refreshing)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!hasData && failure != null) {
      return _FailureMessage(failure: failure, onRetry: onRefresh);
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        // Pull-to-refresh needs the list to scroll even when it is short.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        children: [
          if (failure != null && hasData) _Notice(text: notice),
          if (hasData)
            ...children
          else
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Text(emptyMessage, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}

class _FailureMessage extends StatelessWidget {
  const _FailureMessage({required this.failure, required this.onRetry});

  final AppFailure failure;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(failure.message, textAlign: TextAlign.center),
            const SizedBox(height: Spacing.md),
            AppButton(label: 'Retry', onPressed: () => unawaited(onRetry())),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        left: Spacing.md,
        right: Spacing.md,
        bottom: Spacing.sm,
      ),
      child: Semantics(
        liveRegion: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Text(text, style: TextStyle(color: scheme.onErrorContainer)),
          ),
        ),
      ),
    );
  }
}
