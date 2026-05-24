import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps a page so the system back button never closes the app:
/// pops the current route if possible, otherwise routes to [fallbackLocation].
///
/// Use on pages that may be reached as the only route on the stack (e.g. via
/// `context.go(...)`), where the default PopScope would let the back gesture
/// exit the app.
class SafeBackScope extends StatelessWidget {
  const SafeBackScope({
    super.key,
    required this.fallbackLocation,
    required this.child,
  });

  final String fallbackLocation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(fallbackLocation);
        }
      },
      child: child,
    );
  }
}
