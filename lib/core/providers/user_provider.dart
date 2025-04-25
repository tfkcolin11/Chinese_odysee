import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';
import 'package:chinese_odysee/core/services/api/user_service.dart';

/// Provider for the current user
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return CurrentUserNotifier(userService);
});

/// Notifier for the current user
class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  /// User service for API operations
  final UserService _userService;

  /// Creates a new [CurrentUserNotifier] instance
  CurrentUserNotifier(this._userService) : super(const AsyncValue.loading()) {
    // Load the current user when the notifier is created
    loadCurrentUser();
  }

  /// Loads the current user from the API
  Future<void> loadCurrentUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await _userService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Updates the user's settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      await _userService.updateUserSettings(settings);
      
      // Update the user in state with the new settings
      if (state.hasValue && state.value != null) {
        final updatedUser = state.value!.copyWith(
          settings: settings,
        );
        state = AsyncValue.data(updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clears the current user (for logout)
  void clearUser() {
    state = const AsyncValue.data(null);
  }
}
