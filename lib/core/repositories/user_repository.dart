import 'package:chinese_odysee/core/models/models.dart';
import 'package:chinese_odysee/core/repositories/base_repository.dart';
import 'package:chinese_odysee/core/services/api/api_service.dart';
import 'package:chinese_odysee/core/services/api/user_service.dart';
import 'package:chinese_odysee/core/services/storage/storage_service.dart';

/// Repository for user-related operations
class UserRepository extends BaseRepository<User> {
  /// User service for API operations
  final UserService _userService;

  /// Creates a new [UserRepository] instance
  UserRepository({
    required ApiService apiService,
    required StorageService storageService,
    required UserService userService,
  }) : _userService = userService,
       super(
         apiService: apiService,
         storageService: storageService,
         tableName: 'User',
       );

  @override
  Map<String, dynamic> toMap(User model) {
    return {
      'userId': model.userId,
      'email': model.email,
      'displayName': model.displayName,
      'createdAt': model.createdAt.toIso8601String(),
      'lastLoginAt': model.lastLoginAt?.toIso8601String(),
      'settings': model.settings != null ? model.settings.toString() : null,
    };
  }

  @override
  User fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      settings: map['settings'] != null
          ? Map<String, dynamic>.from(map['settings'] as Map)
          : null,
    );
  }

  @override
  String get idField => 'userId';

  @override
  String getIdValue(User model) => model.userId;

  @override
  Future<List<User>> _getAllRemote() async {
    // This doesn't make sense for users, but we need to implement it
    // In a real app, this might return all users in an organization
    throw UnimplementedError('Getting all users is not supported');
  }

  @override
  Future<User?> _getByIdRemote(String id) async {
    // In a real app, this would call an API to get a user by ID
    // For now, we'll only support getting the current user
    if (id == 'current') {
      return await _userService.getCurrentUser();
    }
    throw UnimplementedError('Getting a user by ID is not supported');
  }

  @override
  Future<User> _createRemote(User item) async {
    // In a real app, this would call an API to create a user
    // For now, we'll throw an error since user creation is handled by auth
    throw UnimplementedError('Creating a user is not supported');
  }

  @override
  Future<User> _updateRemote(User item) async {
    // In a real app, this would call an API to update a user
    // For now, we'll only support updating settings
    if (item.settings != null) {
      await _userService.updateUserSettings(item.settings!);
      return item;
    }
    throw UnimplementedError('Updating a user is not supported');
  }

  @override
  Future<bool> _deleteRemote(String id) async {
    // In a real app, this would call an API to delete a user
    // For now, we'll throw an error since user deletion is not supported
    throw UnimplementedError('Deleting a user is not supported');
  }

  /// Gets the current user
  Future<User?> getCurrentUser() async {
    try {
      if (isOfflineMode) {
        // In offline mode, get the user from local storage
        final maps = await storageService.query(
          tableName,
          limit: 1,
        );
        if (maps.isEmpty) return null;
        return fromMap(maps.first);
      } else {
        try {
          // Try to get the user from the API
          final user = await _userService.getCurrentUser();

          // Save the user to local storage
          await saveLocal(user);

          return user;
        } catch (e) {
          // If API call fails, fall back to local storage
          final maps = await storageService.query(
            tableName,
            limit: 1,
          );
          if (maps.isEmpty) return null;
          return fromMap(maps.first);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Updates the user's settings
  Future<User> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      // Get the current user
      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception('No user found');
      }

      // Create an updated user with the new settings
      final updatedUser = currentUser.copyWith(settings: settings);

      // Update the user
      return await update(updatedUser);
    } catch (e) {
      rethrow;
    }
  }
}
