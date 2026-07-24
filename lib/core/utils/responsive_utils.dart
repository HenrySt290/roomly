import 'package:flutter/material.dart';

/// Detects screen type and provides scaling factors
enum ScreenType { mobile, tablet, desktop }

class ResponsiveUtils {
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 600) {
      return ScreenType.mobile;
    } else if (width < 1024) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  static bool isMobile(BuildContext context) => 
      getScreenType(context) == ScreenType.mobile;
  
  static bool isTablet(BuildContext context) => 
      getScreenType(context) == ScreenType.tablet;
  
  static bool isDesktop(BuildContext context) => 
      getScreenType(context) == ScreenType.desktop;

  /// Returns adaptive padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 16.0;
      case ScreenType.tablet:
        return 32.0;
      case ScreenType.desktop:
        return 64.0;
    }
  }

  /// Returns adaptive font size
  static double getFontSize(BuildContext context, {double mobile = 14, double tablet = 16, double desktop = 18}) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet;
      case ScreenType.desktop:
        return desktop;
    }
  }

  /// Returns number of grid columns for listings
  static int getGridCrossAxisCount(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 1;
      case ScreenType.tablet:
        return 2;
      case ScreenType.desktop:
        return 3;
    }
  }
}
