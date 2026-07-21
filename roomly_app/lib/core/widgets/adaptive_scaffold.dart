import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/responsive_utils.dart';

/// A responsive scaffold that adapts layout based on screen size
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? appBar;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final double mobilePadding;
  final double tabletPadding;
  final double desktopPadding;

  const AdaptiveScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.mobilePadding = 16.0,
    this.tabletPadding = 32.0,
    this.desktopPadding = 64.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    
    double horizontalPadding;
    int maxContentWidth;
    
    switch (screenType) {
      case ScreenType.mobile:
        horizontalPadding = mobilePadding.w;
        maxContentWidth = double.infinity;
        break;
      case ScreenType.tablet:
        horizontalPadding = tabletPadding.w;
        maxContentWidth = 800.w;
        break;
      case ScreenType.desktop:
        horizontalPadding = desktopPadding.w;
        maxContentWidth = 1200.w;
        break;
    }

    return Scaffold(
      appBar: appBar != null ? PreferredSize(preferredSize: Size(double.infinity, kToolbarHeight.h), child: appBar!) : null,
      drawer: drawer,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.h),
              child: body,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
