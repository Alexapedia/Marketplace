import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SplashBrand extends StatelessWidget {
  const SplashBrand({
    super.key,
    required this.logoController,
    required this.textController,
  });

  final AnimationController logoController;
  final AnimationController textController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: logoController,
          builder: (context, child) {
            final curve = CurvedAnimation(
              parent: logoController,
              curve: Curves.elasticOut,
            );
            return Transform.scale(
              scale: curve.value.clamp(0.0, 1.0),
              child: child,
            );
          },
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC9A45C), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC9A45C).withValues(alpha: 0.18),
                  blurRadius: 24,
                  spreadRadius: 8,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Z',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC9A45C),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeTransition(
          opacity: textController,
          child: Column(
            children: [
              Text(
                'app_name'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'app_tagline'.tr(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
