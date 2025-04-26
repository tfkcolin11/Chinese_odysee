import 'package:flutter/material.dart';
import 'package:chinese_odysee/ui/theme/app_theme.dart';
import 'package:chinese_odysee/ui/widgets/theme_toggle_button.dart';

/// Custom app bar widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title of the app bar
  final String title;

  /// Leading widget
  final Widget? leading;

  /// Actions to display
  final List<Widget>? actions;

  /// Whether to center the title
  final bool centerTitle;

  /// Background color
  final Color? backgroundColor;

  /// Foreground color
  final Color? foregroundColor;

  /// Elevation
  final double elevation;

  /// Bottom widget (usually a TabBar)
  final PreferredSizeWidget? bottom;

  /// Creates a new [CustomAppBar] widget
  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of actions that includes the theme toggle button
    final List<Widget> allActions = [
      const ThemeToggleButton(small: true),
      if (actions != null) ...actions!,
    ];

    return AppBar(
      title: Text(title),
      leading: leading,
      actions: allActions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
    );
  }
}
