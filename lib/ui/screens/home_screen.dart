import 'package:flutter/material.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Chinese Odyssey',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your interactive Mandarin Chinese learning journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to HSK level selection screen
              },
              child: const Text('Start Learning'),
            ),
          ],
        ),
      ),
    );
  }
}
