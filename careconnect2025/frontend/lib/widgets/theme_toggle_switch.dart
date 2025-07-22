import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// A widget that displays a switch to toggle between light and dark themes
class ThemeToggleSwitch extends StatelessWidget {
  final bool showIcon;
  final bool showLabel;

  const ThemeToggleSwitch({
    super.key,
    this.showIcon = true,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Text(
            themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (showLabel && showIcon) const SizedBox(width: 8),
        if (showIcon)
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            tooltip: themeProvider.isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
          ),
        if (!showIcon)
          Switch(
            value: themeProvider.isDarkMode,
            onChanged: (_) {
              themeProvider.toggleTheme();
            },
          ),
      ],
    );
  }
}
