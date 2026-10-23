import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/theme/tokens.dart';

enum FailureKind { offline, server, generic }

/// Classifies the message the cubits store in `state.error`
/// (`handleDioError(e).toString()`): no-internet and timeouts are offline,
/// internal server errors are server, everything else is generic.
FailureKind classifyFailure(String msg) {
  const offlineKeys = [
    'no_internet',
    'error_communication',
    'connection_error',
  ];
  const serverKeys = ['server_failed'];
  bool matches(List<String> keys) =>
      keys.any((k) => msg == k || (msg.isNotEmpty && msg.contains(k.tr())));
  if (matches(offlineKeys)) return FailureKind.offline;
  if (matches(serverKeys)) return FailureKind.server;
  return FailureKind.generic;
}

class FailedShape extends StatelessWidget {
  const FailedShape({
    super.key,
    required this.msg,
    required this.onTapRefresh,
    this.kind,
  });
  final String msg;
  final VoidCallback onTapRefresh;
  final FailureKind? kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = this.kind ?? classifyFailure(msg);
    final (icon, title) = switch (kind) {
      FailureKind.offline => (Icons.wifi_off_rounded, 'error_offline_title'),
      FailureKind.server => (Icons.cloud_off_rounded, 'error_server_title'),
      FailureKind.generic => (
        Icons.error_outline_rounded,
        'error_generic_title',
      ),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 40, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (msg.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                msg.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: onTapRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('try_again'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 40, color: theme.colorScheme.secondary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
