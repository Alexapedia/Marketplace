import 'package:flutter/material.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../../config/theme/typography.dart';
import '../utils/functions/responsive.dart';
import 'app_logo.dart';
import 'circle_back_button.dart';
import 'maison.dart';

/// Auth scaffold: a deep brand band with the store logo and display title,
/// and the form on a raised card. Landscape / tablets split the band and the
/// form side by side; the form never stretches past a comfortable width.
class AuthBg extends StatelessWidget {
  const AuthBg({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.belowSheet,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? belowSheet;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final canPop = Navigator.of(context).canPop();
    final split = context.isLandscape || context.isTablet || context.isDesktop;
    final onBand = m.onBand;

    final header = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + (split ? 8 : 12),
        16,
        split ? 24 : 56,
      ),
      decoration: BoxDecoration(
        color: m.band,
        borderRadius: split
            ? BorderRadius.zero
            : const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xxl),
              ),
        border: m.isDark ? Border(bottom: BorderSide(color: m.line)) : null,
      ),
      child: Column(
        mainAxisAlignment: split
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: [
          if (canPop)
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: CircleBackButton(),
            ),
          SizedBox(height: split ? 4 : 8),
          Reveal(
            child: AppLogo(
              height: split ? 56 : 52,
              onDarkSurface: onBand != Maison.inkLight,
            ),
          ),
          if (title != null) ...[
            const SizedBox(height: 18),
            Reveal(
              index: 1,
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: displayStyle(size: split ? 34 : 30, color: onBand),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const GoldRule(width: 64, draw: true),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Reveal(
              index: 2,
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onBand.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final sheet = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Reveal(
              index: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: m.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: m.line),
                  boxShadow: AppShadows.two(m.brightness),
                ),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                child: child,
              ),
            ),
            if (belowSheet != null) ...[
              const SizedBox(height: 16),
              belowSheet!,
            ],
          ],
        ),
      ),
    );

    if (split) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(flex: 9, child: header),
            Expanded(flex: 11, child: SafeArea(child: sheet)),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          header,
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -36),
              child: sheet,
            ),
          ),
        ],
      ),
    );
  }
}
