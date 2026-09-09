import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
}

enum DeviceType { mobile, tablet, desktop }

class ResponsiveInfo {
  final Size size;
  final Orientation orientation;
  final TextScaler textScaler;

  const ResponsiveInfo({
    required this.size,
    required this.orientation,
    required this.textScaler,
  });

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  DeviceType get deviceType {
    if (shortestSide >= Breakpoints.desktop) return DeviceType.desktop;
    if (shortestSide >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;

  double scaleText(double fontSize) => textScaler.scale(fontSize);
}

class ResponsiveUtils {
  static ResponsiveInfo of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return ResponsiveInfo(
      size: mq.size,
      orientation: mq.orientation,
      textScaler: mq.textScaler,
    );
  }

  static T byDevice<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final info = of(context);
    switch (info.deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  static double font(BuildContext context, double size) {
    final info = of(context);
    final multiplier = byDevice(
      context: context,
      mobile: 1.0,
      tablet: 1.25,
      desktop: 1.4,
    );
    return info.scaleText(size * multiplier);
  }

  static EdgeInsets padding(BuildContext context) {
    return byDevice(
      context: context,
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tablet: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      desktop: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
    );
  }

  static int gridColumns(BuildContext context) {
    return byDevice(
      context: context,
      mobile: of(context).isLandscape ? 3 : 2,
      tablet: 3,
      desktop: 4,
    );
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveInfo get responsive => ResponsiveUtils.of(this);
  bool get isMobile => responsive.isMobile;
  bool get isTablet => responsive.isTablet;
  bool get isDesktop => responsive.isDesktop;
  bool get isPortrait => responsive.isPortrait;
  bool get isLandscape => responsive.isLandscape;
  double font(double size) => ResponsiveUtils.font(this, size);
  EdgeInsets get adaptivePadding => ResponsiveUtils.padding(this);
  int get gridColumns => ResponsiveUtils.gridColumns(this);

  T byDevice<T>({required T mobile, T? tablet, T? desktop}) =>
      ResponsiveUtils.byDevice(
        context: this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}

Widget screenUtilHandler({required Widget child}) {
  return Builder(
    builder: (context) {
      final info = ResponsiveUtils.of(context);
      final Size designSize = info.isMobile
          ? info.isPortrait
                ? const Size(390, 844)
                : const Size(844, 390)
          : info.isTablet
          ? const Size(1024, 768)
          : const Size(1440, 900);

      return ScreenUtilInit(
        designSize: designSize,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => child,
      );
    },
  );
}

extension SizeExtension on num {
  double get width => ScreenUtil().setWidth(this);
  double get height => ScreenUtil().setHeight(this);
  double get fontSize => ScreenUtil().setSp(this);
  double get radius => ScreenUtil().radius(this);
}
