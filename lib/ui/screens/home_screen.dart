import 'package:flutter/material.dart';
import 'package:chinese_odysee/ui/screens/hsk_level_selection_screen.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Home screen of the application
class HomeScreen extends StatelessWidget {
  /// Creates a new [HomeScreen] instance
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Chinese Odyssey',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Chinese Odyssey',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Your interactive Mandarin Chinese learning journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/placeholder_logo.png',
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.language,
                    size: 150,
                    color: Colors.redAccent,
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HskLevelSelectionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Start Learning',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to user profile or settings
                },
                child: const Text('My Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
