import 'package:flutter/material.dart';

import 'tokens.dart';

/// Maison route transition: the incoming page fades in while rising 16px
/// (expo-out over `base`); the outgoing page dims slightly. Under reduced
/// motion only a short opacity cross-fade (<= `fast`) remains.
class MaisonPageTransitionsBuilder extends PageTransitionsBuilder {
  const MaisonPageTransitionsBuilder();

  static const double rise = 16;

  @override
  Duration get transitionDuration => AppDurations.base;

  @override
  Duration get reverseTransitionDuration => AppDurations.fast;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return MaisonPageTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class MaisonPageTransition extends StatelessWidget {
  const MaisonPageTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      // base (320ms) * 0.6 ~= 190ms: an opacity-only cross-fade <= fast.
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.6, curve: Curves.linear),
        ),
        child: child,
      );
    }
    final enter = CurvedAnimation(
      parent: animation,
      curve: AppCurves.easeOut,
      reverseCurve: AppCurves.easeOut.flipped,
    );
    final dim = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: secondaryAnimation, curve: AppCurves.easeOut),
    );
    return FadeTransition(
      opacity: dim,
      child: FadeTransition(
        opacity: enter,
        child: AnimatedBuilder(
          animation: enter,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, MaisonPageTransitionsBuilder.rise * (1 - enter.value)),
            child: child,
          ),
          child: child,
        ),
      ),
    );
  }
}
