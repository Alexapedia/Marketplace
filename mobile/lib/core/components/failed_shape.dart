import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../../config/theme/typography.dart';
import 'maison.dart' show GoldRule;

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
    final kind = this.kind ?? classifyFailure(msg);
    final (icon, title) = switch (kind) {
      FailureKind.offline => (Icons.wifi_off_rounded, 'error_offline_title'),
      FailureKind.server => (Icons.cloud_off_rounded, 'error_server_title'),
      FailureKind.generic => (
        Icons.error_outline_rounded,
        'error_generic_title',
      ),
    };
    return _StateLayout(
      icon: icon,
      title: title.tr(),
      subtitle: msg.isEmpty ? null : msg.tr(),
      action: FilledButton.icon(
        onPressed: onTapRefresh,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text('try_again'.tr()),
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
  Widget build(BuildContext context) => _StateLayout(
    icon: icon,
    title: title,
    subtitle: subtitle,
    action: action,
  );
}

/// Shared Maison empty / error composition: a ringed medallion, display
/// title, gold rule, muted copy and an optional action. Centred, calm.
class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: m.accent.withValues(alpha: 0.45)),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: m.accentSoft,
                  ),
                  child: Icon(icon, size: 36, color: m.accentInk),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: displayStyle(size: 24, color: m.ink),
              ),
              const SizedBox(height: 12),
              const GoldRule(width: 40),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: m.inkMuted),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
