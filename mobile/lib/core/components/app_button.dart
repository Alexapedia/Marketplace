import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme/tokens.dart';
import '../models/color_model.dart';
import '../utils/functions/responsive.dart';
import 'text_with_hero.dart';

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
    _controller = AnimationController(vsync: this, duration: AppDurations.fast);
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
    final primary = scheme.primary;
    final appColors = theme.extension<AppColors>()!;
    final Size btnSize = widget.size ?? const Size(double.infinity, 52);
    final gold = appColors.gold;

    final bool loading = widget.isLoading;
    final bool enabled = widget.onTap != null && !loading;
    final bool disabled = widget.onTap == null && !loading;

    final Color normalColor =
        widget.textColor ?? (widget.isOutlined ? primary : scheme.onPrimary);
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
              Text(
                widget.title ?? '',
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: context.font(widget.titleSize),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
      if (widget.tag != null && widget.tag!.isNotEmpty) {
        label = HeroText(tag: widget.tag!, child: label);
      }
    }

    final Color? fill;
    final Gradient? gradient;
    if (disabled) {
      fill = widget.isOutlined
          ? Colors.transparent
          : scheme.surfaceContainerHighest;
      gradient = null;
    } else {
      fill = widget.isOutlined
          ? Colors.transparent
          : widget.bgColor ?? (widget.isGradient ? null : primary);
      gradient =
          widget.isOutlined || widget.bgColor != null || !widget.isGradient
          ? null
          : appColors.primaryGradient;
    }

    final Border? border = widget.isOutlined
        ? Border.all(
            color: disabled
                ? scheme.onSurface.withValues(alpha: 0.12)
                : widget.bgColor ?? gold,
            width: 1.8,
          )
        : null;

    Widget button = Semantics(
      button: true,
      enabled: enabled,
      label: widget.title,
      excludeSemantics: widget.title != null && widget.child == null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: btnSize.width,
          height: btnSize.height,
          decoration: BoxDecoration(
            color: fill,
            gradient: gradient,
            borderRadius: AppRadius.button,
            border: border,
            boxShadow: !enabled || widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.button,
              onTap: enabled ? widget.onTap : null,
              onHighlightChanged: enabled
                  ? (down) =>
                        down ? _controller.forward() : _controller.reverse()
                  : null,
              child: Center(child: label),
            ),
          ),
        ),
      ),
    );

    if (!MediaQuery.disableAnimationsOf(context)) {
      button = button.animate().fadeIn(duration: 300.ms);
    }
    return button;
  }
}
