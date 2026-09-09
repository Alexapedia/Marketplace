import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final appColors = theme.extension<AppColors>()!;
    const radius = 16.0;
    final Size btnSize = widget.size ?? const Size(double.infinity, 54);
    final gold = appColors.gold;

    Widget label = widget.child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: widget.textColor ??
                    (widget.isOutlined ? primary : theme.colorScheme.onPrimary),
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.title ?? '',
              style: TextStyle(
                color: widget.textColor ??
                    (widget.isOutlined ? primary : theme.colorScheme.onPrimary),
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

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: Container(
          width: btnSize.width,
          height: btnSize.height,
          decoration: BoxDecoration(
            color: widget.isOutlined
                ? Colors.transparent
                : widget.bgColor ?? (widget.isGradient ? null : primary),
            gradient: widget.isOutlined || widget.bgColor != null || !widget.isGradient
                ? null
                : LinearGradient(
                    colors: [primary, gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(radius),
            border: widget.isOutlined
                ? Border.all(color: widget.bgColor ?? gold, width: 1.8)
                : null,
            boxShadow: widget.onTap == null || widget.isOutlined
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
              borderRadius: BorderRadius.circular(radius),
              onTap: widget.onTap,
              child: Center(child: label),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
