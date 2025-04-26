import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/mock_providers.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';
import 'package:chinese_odysee/ui/screens/auth/login_screen.dart';
import 'package:chinese_odysee/ui/screens/home_screen.dart';
import 'package:chinese_odysee/ui/theme/app_theme.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize the storage service
  final storageService = StorageService();
  await storageService.initialize();

  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    // Use mock providers for testing
    ProviderScope(
      overrides: [
        ...mockProviders,
        // Override the storage service provider with our initialized instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const ChineseOdyseeApp(),
    ),
  );
}

/// Main application widget
class ChineseOdyseeApp extends ConsumerWidget {
  /// Creates a new [ChineseOdyseeApp] instance
  const ChineseOdyseeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state to determine the initial screen
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Chinese Odyssey',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system, // Use system theme by default
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: child!,
            ),
            // Show connectivity banner at the bottom of the screen
            const ConnectivityBanner(),
          ],
        );
      },
      home: authState == AuthState.authenticated
          ? const HomeScreen()
          : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
