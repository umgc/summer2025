import 'user_role.dart';
import 'lms.dart';

class User {
  final String id;
  final String? email;
  final String? username;
  final UserRole role;
  final LMS lmsType;

  const User({
    required this.id,
    this.email,
    this.username,
    required this.role,
    required this.lmsType,
  });

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? username,
    UserRole? role,
    LMS? lmsType,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      lmsType: lmsType ?? this.lmsType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role.toString().split('.').last,
      'lmsType': lmsType.toString().split('.').last,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.unknown,
      ),
      lmsType: LMS.values.firstWhere(
        (e) => e.toString().split('.').last == json['lms'],
        orElse: () => LMS.unknown,
      ),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username, role: $role, lmsType: $lmsType)';
  }
}