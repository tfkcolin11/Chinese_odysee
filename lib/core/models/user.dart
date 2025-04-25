import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// User model representing a user in the application
@JsonSerializable()
class User extends Equatable {
  /// Unique identifier for the user
  final String userId;
  
  /// User's email address
  final String email;
  
  /// User's display name (optional)
  final String? displayName;
  
  /// When the user account was created
  final DateTime createdAt;
  
  /// Last time the user logged in
  final DateTime? lastLoginAt;
  
  /// User settings as a JSON map
  final Map<String, dynamic>? settings;

  /// Creates a new [User] instance
  const User({
    required this.userId,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.lastLoginAt,
    this.settings,
  });

  /// Creates a [User] from a JSON map
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Converts this [User] to a JSON map
  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Creates a copy of this [User] with the given fields replaced
  User copyWith({
    String? userId,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        displayName,
        createdAt,
        lastLoginAt,
        settings,
      ];
}
