import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/services/theme/theme_service.dart';

/// Provider for the theme service
final themeServiceProvider = Provider<ThemeService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ThemeService(storageService);
});

/// Provider for the current theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final themeService = ref.watch(themeServiceProvider);
  return ThemeModeNotifier(themeService);
});

/// Notifier for the theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  /// Theme service for managing theme preferences
  final ThemeService _themeService;

  /// Creates a new [ThemeModeNotifier] instance
  ThemeModeNotifier(this._themeService) : super(_themeService.getThemeMode());

  /// Sets the theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _themeService.setThemeMode(themeMode);
    state = themeMode;
  }

  /// Toggles between light and dark mode
  Future<void> toggleThemeMode() async {
    final newThemeMode = await _themeService.toggleThemeMode();
    state = newThemeMode;
  }
}
