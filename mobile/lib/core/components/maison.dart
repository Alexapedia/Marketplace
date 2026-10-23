import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../../config/theme/typography.dart';
import '../utils/functions/motion.dart';

/// Maison building blocks shared by every screen: entrances, press feedback,
/// eyebrow labels, gold rules, section headers, cards, badges and numbers.
/// Every animated piece collapses to an instant state under reduced motion.

/// Page-enter / list entrance: fade + 16px rise over `slow`, staggered 60ms
/// by [index] (capped at 8 items).
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.index = 0, this.delay});

  final Widget child;
  final int index;
  final Duration? delay;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return child
        .animate(
          delay: (delay ?? Duration.zero) + AppDurations.staggerFor(index),
        )
        .fadeIn(duration: AppDurations.slow, curve: AppCurves.easeOut)
        .moveY(
          begin: 16,
          end: 0,
          duration: AppDurations.slow,
          curve: AppCurves.easeOut,
        );
  }
}

/// Press feedback: scales the child to .97 over `instant` while pressed and
/// gives a light haptic on tap-down. It never consumes the gesture, so the
/// child's own InkWell / button still handles the tap.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.enabled = true,
    this.haptic = true,
    this.scale = 0.97,
  });

  final Widget child;
  final bool enabled;
  final bool haptic;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (!widget.enabled || _down == v) return;
    setState(() => _down = v);
    if (v && widget.haptic) HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = context.reduceMotion;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !reduce ? widget.scale : 1,
        duration: reduce ? Duration.zero : AppDurations.instant,
        curve: AppCurves.easeOut,
        child: widget.child,
      ),
    );
  }
}

bool _isArabic(BuildContext context) {
  try {
    return context.locale.languageCode == 'ar';
  } catch (_) {
    return Directionality.of(context) == TextDirection.rtl;
  }
}

/// Small uppercase label in accent-ink above titles. Latin gets .16em
/// tracking; Arabic gets none.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic(context);
    return Text(
      ar ? text : text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: color ?? context.maison.accentInk,
        fontWeight: FontWeight.w600,
        letterSpacing: ar ? 0 : 12 * 0.16,
      ),
    );
  }
}

/// 1px accent -> transparent hairline in the reading direction. With [draw]
/// it grows from 0 to full width over `slow` (instant under reduced motion).
class GoldRule extends StatelessWidget {
  const GoldRule({super.key, this.width = 48, this.draw = false});

  final double width;
  final bool draw;

  @override
  Widget build(BuildContext context) {
    final dir = Directionality.of(context);
    final rule = SizedBox(
      width: width,
      height: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: context.maison.rule(dir)),
      ),
    );
    if (!draw || context.reduceMotion) return rule;
    return rule.animate().scaleX(
      begin: 0,
      end: 1,
      alignment: AlignmentDirectional.centerStart.resolve(dir),
      duration: AppDurations.slow,
      curve: AppCurves.easeOut,
    );
  }
}

/// Section title: optional eyebrow, display title, gold rule, "see all".
class MaisonSectionHeader extends StatelessWidget {
  const MaisonSectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.onSeeAll,
    this.trailing,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 24, 8, 14),
  });

  final String title;
  final String? eyebrow;
  final VoidCallback? onSeeAll;

  /// Replaces the "see all" action.
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null && eyebrow!.isNotEmpty) ...[
                  Eyebrow(eyebrow!),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: displayStyle(size: 22, color: m.ink),
                ),
                const SizedBox(height: 10),
                const GoldRule(width: 40),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('see_all'.tr()),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Content card: surface fill, hairline border, shadow-1, dark-mode top
/// highlight.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = 20,
    this.onTap,
    this.color,
    this.elevated = true,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final Color? color;
  final bool elevated;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final r = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, borderRadius: r, child: content),
      );
    }
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? m.surface,
        borderRadius: r,
        border: Border.all(color: m.line),
        boxShadow: elevated ? AppShadows.one(m.brightness) : null,
      ),
      child: Stack(
        children: [
          clip ? ClipRRect(borderRadius: r, child: content) : content,
          if (m.isDark)
            PositionedDirectional(
              top: 0,
              start: radius,
              end: radius,
              height: 1,
              child: ColoredBox(color: m.highlight),
            ),
        ],
      ),
    );
    return onTap == null ? card : Pressable(child: card);
  }
}

/// Count badge that bumps (spring) whenever [count] changes.
class BumpBadge extends StatelessWidget {
  const BumpBadge({super.key, required this.count, required this.child});

  final int count;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    final label = count > 99 ? '99+' : '$count';
    Widget badge = Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: m.accent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: m.canvas, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: m.onAccent,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ).tabular,
      ),
    );
    if (!context.reduceMotion) {
      badge = badge
          .animate(key: ValueKey(count))
          .scaleXY(
            begin: 0.6,
            end: 1,
            duration: AppDurations.base,
            curve: AppCurves.spring,
          );
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          PositionedDirectional(
            top: 4,
            end: 2,
            child: ExcludeSemantics(child: badge),
          ),
      ],
    );
  }
}

/// Number that counts to its new value (prices, totals, counts) over
/// `base`; instant under reduced motion. Tabular figures.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.textAlign,
  });

  final double value;
  final String Function(double v) format;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final s = (style ?? DefaultTextStyle.of(context).style).tabular;
    if (context.reduceMotion) {
      return Text(format(value), style: s, textAlign: textAlign);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value),
      duration: AppDurations.base,
      curve: AppCurves.easeOut,
      builder: (context, v, _) => Text(
        format(v),
        style: s,
        textAlign: textAlign,
        semanticsLabel: format(value),
      ),
    );
  }
}

/// Round chrome button: 40px glass disc with a hairline, inside a 48dp
/// target. Used over imagery and in app bars (back, share, favourite).
class GlassCircleButton extends StatelessWidget {
  const GlassCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.size = 18,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final m = context.maison;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.zero,
      ),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: m.surface.withValues(alpha: 0.86),
          shape: BoxShape.circle,
          border: Border.all(color: m.line.withValues(alpha: 0.8)),
          boxShadow: AppShadows.one(m.brightness),
        ),
        child: Icon(icon, size: size, color: color ?? m.ink),
      ),
    );
  }
}
