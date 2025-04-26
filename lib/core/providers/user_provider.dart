import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/providers/api_providers.dart';
import 'package:chinese_odysee/core/services/api/user_service.dart';
import 'package:uuid/uuid.dart';

/// Provider for the current user
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>((ref) {
  final userService = ref.watch(userServiceProvider);
  return CurrentUserNotifier(userService);
});

/// Provider for the authentication state
final authStateProvider = Provider<AuthState>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  if (userAsync is AsyncLoading) {
    return AuthState.loading;
  } else if (userAsync is AsyncError) {
    return AuthState.error;
  } else if (userAsync.value != null) {
    return AuthState.authenticated;
  } else {
    return AuthState.unauthenticated;
  }
});

/// Authentication state
enum AuthState {
  /// Loading authentication state
  loading,

  /// User is authenticated
  authenticated,

  /// User is not authenticated
  unauthenticated,

  /// Error occurred during authentication
  error
}

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

      // In a real app, this would check for a stored auth token
      // and then call the API to get the current user
      // For now, we'll just set the state to null (not logged in)
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Logs in with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();

      // In a real app, this would call the API to authenticate
      // For now, we'll simulate a successful login
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock user
      final user = User(
        userId: const Uuid().v4(),
        email: email,
        displayName: email.split('@')[0],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
        settings: {
          'ttsEnabled': true,
          'preferredInputMode': 'text',
          'darkModeEnabled': false,
          'notificationsEnabled': true,
          'selectedLanguage': 'English',
        },
      );

      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Registers a new user
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      state = const AsyncValue.loading();

      // In a real app, this would call the API to register
      // For now, we'll simulate a successful registration
      await Future.delayed(const Duration(seconds: 1));

      // Create a mock user
      final user = User(
        userId: const Uuid().v4(),
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        settings: {
          'ttsEnabled': true,
          'preferredInputMode': 'text',
          'darkModeEnabled': false,
          'notificationsEnabled': true,
          'selectedLanguage': 'English',
        },
      );

      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Mock login for testing
  Future<void> mockLogin({
    required String email,
    String? displayName,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Create a mock user
      final user = User(
        userId: const Uuid().v4(),
        email: email,
        displayName: displayName ?? email.split('@')[0],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now(),
        settings: {
          'ttsEnabled': true,
          'preferredInputMode': 'text',
          'darkModeEnabled': false,
          'notificationsEnabled': true,
          'selectedLanguage': 'English',
        },
      );

      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Updates the user's settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      // In a real app, this would call the API to update settings
      await Future.delayed(const Duration(milliseconds: 500));

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

  /// Updates the user's profile
  Future<void> updateProfile({
    String? displayName,
  }) async {
    try {
      // In a real app, this would call the API to update the profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Update the user in state with the new profile info
      if (state.hasValue && state.value != null) {
        final updatedUser = state.value!.copyWith(
          displayName: displayName ?? state.value!.displayName,
        );
        state = AsyncValue.data(updatedUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logs out the current user
  void logout() {
    // In a real app, this would call the API to logout
    // and clear any stored auth tokens
    state = const AsyncValue.data(null);
  }
}
