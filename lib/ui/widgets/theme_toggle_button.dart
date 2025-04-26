import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/providers.dart';

/// Widget for toggling between light and dark theme
class ThemeToggleButton extends ConsumerWidget {
  /// Whether to show a label next to the icon
  final bool showLabel;
  
  /// Whether to use a smaller size
  final bool small;

  /// Creates a new [ThemeToggleButton] instance
  const ThemeToggleButton({
    super.key,
    this.showLabel = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && 
         MediaQuery.of(context).platformBrightness == Brightness.dark);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationTransition(
          turns: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      child: _buildButton(context, ref, isDarkMode),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, bool isDarkMode) {
    if (small) {
      return IconButton(
        key: ValueKey<bool>(isDarkMode),
        icon: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
          size: 20,
        ),
        onPressed: () => _toggleTheme(ref),
        tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      );
    }
    
    if (showLabel) {
      return TextButton.icon(
        key: ValueKey<bool>(isDarkMode),
        icon: Icon(
          isDarkMode ? Icons.light_mode : Icons.dark_mode,
        ),
        label: Text(
          isDarkMode ? 'Light Mode' : 'Dark Mode',
        ),
        onPressed: () => _toggleTheme(ref),
      );
    }
    
    return IconButton(
      key: ValueKey<bool>(isDarkMode),
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () => _toggleTheme(ref),
      tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }

  void _toggleTheme(WidgetRef ref) {
    ref.read(themeModeProvider.notifier).toggleThemeMode();
  }
}
