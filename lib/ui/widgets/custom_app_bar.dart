import 'package:flutter/material.dart';
import 'package:chinese_odysee/ui/theme/app_theme.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppTheme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
