import 'package:flutter/material.dart';
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
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.bottomNavigationBar,
    this.mobilePadding = 16.0,
    this.tabletPadding = 32.0,
    this.desktopPadding = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final screenType = ResponsiveUtils.getScreenType(context);
    
    double horizontalPadding;
    double maxContentWidth;
    
    switch (screenType) {
      case ScreenType.mobile:
        horizontalPadding = mobilePadding;
        maxContentWidth = double.infinity;
        break;
      case ScreenType.tablet:
        horizontalPadding = tabletPadding;
        maxContentWidth = 800.0;
        break;
      case ScreenType.desktop:
        horizontalPadding = desktopPadding;
        maxContentWidth = 1200.0;
        break;
    }

    return Scaffold(
      appBar: appBar != null ? PreferredSize(preferredSize: const Size(double.infinity, kToolbarHeight), child: appBar!) : null,
      drawer: drawer,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16.0),
              child: body,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
