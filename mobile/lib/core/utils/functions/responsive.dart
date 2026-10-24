import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 1024;
}

enum DeviceType { mobile, tablet, desktop, mobileLandscape }

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
  bool get isWide => width >= 700;
  bool get isCompactHeight => height < 520;
  bool get useNavRail => isTablet || isDesktop || isLandscape;
  double get navRailWidth {
    if (isCompactHeight) return 92;
    if (isTablet || isDesktop) return 208;
    if (isLandscape) return 168;
    return 88;
  }

  double get contentMaxWidth {
    if (isDesktop) return 1120;
    if (isTablet) return isLandscape ? 1080 : 860;
    if (isLandscape) return 920;
    return width;
  }

  double get formMaxWidth => isMobile && isPortrait ? width : 520;

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
    required T mobileLandscape,
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
      case DeviceType.mobileLandscape:
        return mobileLandscape;
    }
  }

  static T byOrientation<T>({
    required BuildContext context,
    required T portrait,
    required T landscape,
  }) {
    return of(context).isPortrait ? portrait : landscape;
  }

  static double font(BuildContext context, double size) {
    final info = of(context);
    final multiplier = byDevice(
      context: context,
      mobileLandscape: 1.0,
      mobile: 1.0,
      tablet: 1.15,
      desktop: 1.28,
    );
    return info.scaleText(size * multiplier).fontSize;
  }

  static EdgeInsets padding(BuildContext context) {
    return byDevice(
      context: context,
      mobileLandscape: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tablet: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      desktop: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
    );
  }

  static int catalogColumns(BuildContext context) {
    final info = of(context);
    if (info.isDesktop) return 4;
    if (info.isTablet) return info.isLandscape ? 4 : 3;
    return info.isLandscape ? 3 : 2;
  }

  static double productCardWidth(BuildContext context) {
    return byDevice(
      context: context,
      mobileLandscape: 160,
      mobile: 160,
      tablet: 190,
      desktop: 210,
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
  bool get isWide => responsive.isWide;
  bool get isCompactHeight => responsive.isCompactHeight;
  bool get useNavRail => responsive.useNavRail;
  double get navRailWidth => responsive.navRailWidth;
  double get contentMaxWidth => responsive.contentMaxWidth;
  double get formMaxWidth => responsive.formMaxWidth;
  double font(double size) => ResponsiveUtils.font(this, size);
  EdgeInsets get adaptivePadding => ResponsiveUtils.padding(this);
  int get catalogColumns => ResponsiveUtils.catalogColumns(this);
  double get productCardWidth => ResponsiveUtils.productCardWidth(this);

  T byDevice<T>({
    required T mobile,
    required T mobileLandscape,
    T? tablet,
    T? desktop,
  }) => ResponsiveUtils.byDevice(
    context: this,
    mobileLandscape: mobileLandscape,
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

Future<void> initScreenUtilsFunctions() async {
  await ScreenUtil.ensureScreenSize();
}

extension SizeExtension on num {
  double get width => ScreenUtil().setWidth(this);
  double get height => ScreenUtil().setHeight(this);
  double get fontSize => ScreenUtil().setSp(this);
  double get radius => ScreenUtil().radius(this);
}
