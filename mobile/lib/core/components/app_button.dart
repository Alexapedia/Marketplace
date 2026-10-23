import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme/maison.dart';
import '../../config/theme/tokens.dart';
import '../models/color_model.dart';
import '../utils/functions/responsive.dart';
import 'text_with_hero.dart';

/// Maison primary action: an accent ("the light") pill with computed
/// on-accent text, press scale .97 over `instant` and a light haptic.
/// [isOutlined] gives the quiet secondary variant (hairline ink border).
/// [isGradient] is kept for API compatibility; Maison fills are flat.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onTap,
    this.title,
    this.titleSize = 15,
    this.tag,
    this.child,
    this.bgColor,
    this.textColor,
    this.size,
    this.isOutlined = false,
    this.isGradient = true,
    this.icon,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final String? title;
  final String? tag;
  final double titleSize;
  final Widget? child;
  final Color? bgColor;
  final Color? textColor;
  final Size? size;
  final bool isOutlined;
  final bool isGradient;
  final IconData? icon;
  final bool isLoading;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.instant,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final m = context.maison;
    final outline = theme.extension<AppColors>()?.inputBorder ?? m.line;
    final Size btnSize = widget.size ?? const Size(double.infinity, 52);
    final reduce = MediaQuery.disableAnimationsOf(context);

    final bool loading = widget.isLoading;
    final bool enabled = widget.onTap != null && !loading;
    final bool disabled = widget.onTap == null && !loading;

    final Color normalColor =
        widget.textColor ??
        (widget.isOutlined
            ? m.ink
            : widget.bgColor != null
            ? Maison.onColor(widget.bgColor!)
            : m.onAccent);
    final Color contentColor = disabled
        ? scheme.onSurface.withValues(alpha: 0.38)
        : normalColor;

    Widget label;
    if (loading) {
      label = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    } else {
      label =
          widget.child ??
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: contentColor, size: 18),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: contentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: context.font(widget.titleSize),
                  ),
                ),
              ),
            ],
          );
      if (widget.tag != null && widget.tag!.isNotEmpty) {
        label = HeroText(tag: widget.tag!, child: label);
      }
    }

    final Color fill;
    if (disabled) {
      fill = widget.isOutlined
          ? Colors.transparent
          : scheme.surfaceContainerHighest;
    } else {
      fill = widget.isOutlined
          ? Colors.transparent
          : widget.bgColor ?? m.accent;
    }

    final Border? border = widget.isOutlined
        ? Border.all(
            color: disabled
                ? scheme.onSurface.withValues(alpha: 0.12)
                : widget.bgColor ?? outline,
          )
        : null;

    Widget button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.title,
      excludeSemantics: widget.title != null && widget.child == null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: reduce ? 1 : _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          width: btnSize.width,
          height: btnSize.height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: AppRadius.button,
            border: border,
            boxShadow: !enabled || widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: (widget.bgColor ?? m.accent).withValues(
                        alpha: m.isDark ? 0.18 : 0.32,
                      ),
                      blurRadius: 20,
                      spreadRadius: -6,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.button,
              onTap: enabled
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onTap!();
                    }
                  : null,
              onHighlightChanged: enabled
                  ? (down) =>
                        down ? _controller.forward() : _controller.reverse()
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(child: label),
              ),
            ),
          ),
        ),
      ),
    );

    if (!reduce) {
      button = button.animate().fadeIn(
        duration: AppDurations.base,
        curve: AppCurves.easeOut,
      );
    }
    return button;
  }
}
