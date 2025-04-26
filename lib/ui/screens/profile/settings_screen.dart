import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/providers/providers.dart';
import 'package:chinese_odysee/ui/widgets/widgets.dart';

/// Screen for app settings
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates a new [SettingsScreen] instance
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _ttsEnabled = true;
  String _preferredInputMode = 'text';
  bool _darkModeEnabled = false;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would load settings from the user's profile
      // For now, we'll use default values
      final user = ref.read(currentUserProvider);
      if (user.hasValue && user.value != null && user.value!.settings != null) {
        final settings = user.value!.settings!;
        setState(() {
          _ttsEnabled = settings['ttsEnabled'] ?? true;
          _preferredInputMode = settings['preferredInputMode'] ?? 'text';
          _darkModeEnabled = settings['darkModeEnabled'] ?? false;
          _notificationsEnabled = settings['notificationsEnabled'] ?? true;
          _selectedLanguage = settings['selectedLanguage'] ?? 'English';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a settings map
      final settings = {
        'ttsEnabled': _ttsEnabled,
        'preferredInputMode': _preferredInputMode,
        'darkModeEnabled': _darkModeEnabled,
        'notificationsEnabled': _notificationsEnabled,
        'selectedLanguage': _selectedLanguage,
      };

      // In a real app, this would save settings to the user's profile
      // For now, we'll just update the local state
      final userNotifier = ref.read(currentUserProvider.notifier);
      await userNotifier.updateUserSettings(settings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
      ),
      body: _isLoading
          ? const LoadingIndicator(showText: true, text: 'Loading settings...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App preferences section
                  _buildSectionHeader(context, 'App Preferences'),
                  const SizedBox(height: 8),

                  // Theme mode selector
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.color_lens),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'App Theme',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Choose between light and dark theme',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Consumer(
                                builder: (context, ref, _) {
                                  final themeMode = ref.watch(themeModeProvider);
                                  return DropdownButton<ThemeMode>(
                                    value: themeMode,
                                    onChanged: (ThemeMode? newValue) {
                                      if (newValue != null) {
                                        ref.read(themeModeProvider.notifier).setThemeMode(newValue);
                                        setState(() {
                                          _darkModeEnabled = newValue == ThemeMode.dark;
                                        });
                                      }
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: ThemeMode.system,
                                        child: Text('System'),
                                      ),
                                      DropdownMenuItem(
                                        value: ThemeMode.light,
                                        child: Text('Light'),
                                      ),
                                      DropdownMenuItem(
                                        value: ThemeMode.dark,
                                        child: Text('Dark'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: ThemeToggleButton(showLabel: true),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Language selector
                  _buildDropdownTile(
                    title: 'App Language',
                    subtitle: 'Select the language for the app interface',
                    value: _selectedLanguage,
                    items: const ['English', 'Chinese', 'Spanish', 'French'],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                    icon: Icons.language,
                  ),

                  // Notifications toggle
                  _buildSwitchTile(
                    title: 'Notifications',
                    subtitle: 'Enable push notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    icon: Icons.notifications,
                  ),

                  const Divider(height: 32),

                  // Learning preferences section
                  _buildSectionHeader(context, 'Learning Preferences'),
                  const SizedBox(height: 8),

                  // Text-to-speech toggle
                  _buildSwitchTile(
                    title: 'Text-to-Speech',
                    subtitle: 'Enable AI voice output',
                    value: _ttsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _ttsEnabled = value;
                      });
                    },
                    icon: Icons.record_voice_over,
                  ),

                  // Input mode selector
                  _buildRadioTile(
                    title: 'Preferred Input Mode',
                    subtitle: 'Choose your default input method',
                    groupValue: _preferredInputMode,
                    values: const {
                      'text': 'Text Input',
                      'voice': 'Voice Input',
                    },
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _preferredInputMode = value;
                        });
                      }
                    },
                    icon: Icons.keyboard_voice,
                  ),

                  const Divider(height: 32),

                  // Account section
                  _buildSectionHeader(context, 'Account'),
                  const SizedBox(height: 8),

                  // Edit profile button
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profile'),
                    subtitle: const Text('Change your name and profile picture'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to edit profile screen
                    },
                  ),

                  // Change password button
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    subtitle: const Text('Update your account password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to change password screen
                    },
                  ),

                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon),
      ),
    );
  }

  Widget _buildDropdownTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 8),
            DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T groupValue,
    required Map<T, String> values,
    required ValueChanged<T?> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        initiallyExpanded: true,
        children: values.entries.map((entry) {
          return RadioListTile<T>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: groupValue,
            onChanged: onChanged,
          );
        }).toList(),
      ),
    );
  }
}
