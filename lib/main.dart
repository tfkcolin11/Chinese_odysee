import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/mock_providers.dart';
import 'package:chinese_odysee/ui/screens/home_screen.dart';
import 'package:chinese_odysee/ui/theme/app_theme.dart';

void main() {
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    // Use mock providers for testing
    ProviderScope(
      overrides: mockProviders,
      child: const ChineseOdyseeApp(),
    ),
  );
}

/// Main application widget
class ChineseOdyseeApp extends StatelessWidget {
  /// Creates a new [ChineseOdyseeApp] instance
  const ChineseOdyseeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinese Odyssey',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // Use system theme by default
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
