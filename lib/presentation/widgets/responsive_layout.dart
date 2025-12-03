import 'package:flutter/material.dart';

/// Breakpoints used in the app
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

/// A wrapper that centers and constrains content for large screens,
/// while keeping full width on small screens.
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveLayout({super.key, required this.child, this.maxWidth = 1100, this.padding});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width >= Breakpoints.tablet ? maxWidth : double.infinity),
        child: Padding(
          padding: width >= Breakpoints.tablet ? horizontalPadding : const EdgeInsets.all(0),
          child: child,
        ),
      ),
    );
  }
}

/// Utility helpers
extension ResponsiveHelpers on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < Breakpoints.mobile;
  bool get isTablet => MediaQuery.of(this).size.width >= Breakpoints.mobile && MediaQuery.of(this).size.width < Breakpoints.tablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= Breakpoints.tablet;
}
