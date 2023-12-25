import 'package:flutter/material.dart';

class EmergingZoomFadeRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  EmergingZoomFadeRoute({required this.page, this.duration = const Duration(milliseconds: 700)})
      : super(
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
      var scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(animation);
      var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animation);

      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      );
    },
    transitionDuration: duration,
  );
}
