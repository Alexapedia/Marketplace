import 'package:flutter/widgets.dart';

extension MotionContext on BuildContext {
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  Duration motion(Duration d) => reduceMotion ? Duration.zero : d;
}
