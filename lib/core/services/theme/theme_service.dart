import 'package:flutter/material.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';

/// Service for managing app theme
class ThemeService {
  /// Storage service for persisting theme preferences
  final StorageService _storageService;
  
  /// Key for storing theme mode in preferences
  static const String _themeModeKey = 'theme_mode';

  /// Creates a new [ThemeService] instance
  ThemeService(this._storageService);

  /// Gets the current theme mode
  ThemeMode getThemeMode() {
    final themeModeString = _storageService.getString(_themeModeKey);
    
    if (themeModeString == null) {
      return ThemeMode.system;
    }
    
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Sets the theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    String themeModeString;
    
    switch (themeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    
    await _storageService.setString(_themeModeKey, themeModeString);
  }

  /// Toggles between light and dark mode
  Future<ThemeMode> toggleThemeMode() async {
    final currentThemeMode = getThemeMode();
    ThemeMode newThemeMode;
    
    switch (currentThemeMode) {
      case ThemeMode.light:
        newThemeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newThemeMode = ThemeMode.light;
        break;
      case ThemeMode.system:
        // If system, check the current brightness and toggle to the opposite
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        newThemeMode = brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;
        break;
    }
    
    await setThemeMode(newThemeMode);
    return newThemeMode;
  }
}
