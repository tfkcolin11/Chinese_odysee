import 'package:flutter/material.dart';

/// Types of page transitions
enum PageTransitionType {
  /// Fade transition
  fade,

  /// Slide from right transition
  slideRight,

  /// Slide from left transition
  slideLeft,

  /// Slide from top transition
  slideTop,

  /// Slide from bottom transition
  slideBottom,

  /// Scale transition
  scale,

  /// Rotation transition
  rotate,

  /// Size transition
  size,

  /// Fade and scale transition
  fadeAndScale,
}

/// Custom page route for animated transitions
class PageTransition<T> extends PageRouteBuilder<T> {
  /// Widget to navigate to
  final Widget page;

  /// Type of transition animation
  final PageTransitionType type;

  /// Duration of the transition
  final Duration duration;

  /// Curve of the transition
  final Curve curve;

  /// Alignment for scale transitions
  final Alignment? alignment;

  /// Whether the route is fullscreen dialog
  final bool fullscreenDialog;

  /// Creates a new [PageTransition] instance
  PageTransition({
    required this.page,
    this.type = PageTransitionType.slideRight,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.alignment,
    this.fullscreenDialog = false,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: child,
                );
              case PageTransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case PageTransitionType.slideLeft:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case PageTransitionType.slideTop:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case PageTransitionType.slideBottom:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              case PageTransitionType.scale:
                return ScaleTransition(
                  scale: curvedAnimation,
                  alignment: alignment ?? Alignment.center,
                  child: child,
                );
              case PageTransitionType.rotate:
                return RotationTransition(
                  turns: curvedAnimation,
                  alignment: alignment ?? Alignment.center,
                  child: child,
                );
              case PageTransitionType.size:
                return SizeTransition(
                  sizeFactor: curvedAnimation,
                  axisAlignment: 0.0,
                  child: child,
                );
              case PageTransitionType.fadeAndScale:
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.8,
                      end: 1.0,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
            }
          },
          transitionDuration: duration,
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );
}

/// Extension methods for Navigator
extension NavigatorExtension on BuildContext {
  /// Navigate to a new screen with a custom transition
  Future<T?> navigateWithTransition<T extends Object?>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideRight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Alignment? alignment,
    bool fullscreenDialog = false,
    RouteSettings? settings,
  }) {
    return Navigator.of(this).push<T>(
      PageTransition<T>(
        page: page,
        type: type,
        duration: duration,
        curve: curve,
        alignment: alignment,
        fullscreenDialog: fullscreenDialog,
        settings: settings,
      ),
    );
  }

  /// Replace the current screen with a new one with a custom transition
  Future<T?> navigateWithTransitionReplacement<T extends Object?, TO extends Object?>(
    Widget page, {
    PageTransitionType type = PageTransitionType.slideRight,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Alignment? alignment,
    bool fullscreenDialog = false,
    RouteSettings? settings,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageTransition<T>(
        page: page,
        type: type,
        duration: duration,
        curve: curve,
        alignment: alignment,
        fullscreenDialog: fullscreenDialog,
        settings: settings,
      ),
      result: result,
    );
  }
}
