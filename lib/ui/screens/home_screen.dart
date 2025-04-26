import 'package:flutter/material.dart';
import 'package:chinese_odysee/ui/animations/animations.dart';
import 'package:chinese_odysee/ui/screens/hsk_level_selection_screen.dart';
import 'package:chinese_odysee/ui/screens/mastery/mastery_dashboard_screen.dart';
import 'package:chinese_odysee/ui/screens/profile/profile_screen.dart';
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
                  context.navigateWithTransition(
                    const HskLevelSelectionScreen(),
                    type: PageTransitionType.fadeAndScale,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.navigateWithTransition(
                        const MasteryDashboardScreen(),
                        type: PageTransitionType.slideBottom,
                      );
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('My Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.navigateWithTransition(
                        const ProfileScreen(),
                        type: PageTransitionType.slideRight,
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('My Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
