import 'package:flutter/material.dart';

/// A widget that provides a consistent set of app bar actions
class AppBarActions extends StatelessWidget {
  final List<Widget>? additionalActions;

  const AppBarActions({super.key, this.additionalActions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme toggle removed from AppBar as it's now only in the drawer
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }
}
