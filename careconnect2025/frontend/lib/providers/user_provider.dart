import 'package:flutter/material.dart';
import '../services/auth_token_manager.dart';
import '../services/auth_service.dart';

class UserSession {
  final int id;
  final String email;
  final String role;
  final String token;
  final int? patientId;
  final int? caregiverId;
  final String? name;

  UserSession({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    this.patientId,
    this.caregiverId,
    this.name,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json; // Support both wrapped and flat

    return UserSession(
      id: user['id'],
      email: user['email'],
      role: user['role'],
      name: user['name'],
      token: json['token'] ?? '',
      patientId: json['patientId'],
      caregiverId: json['caregiverId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
      'patientId': patientId,
      'caregiverId': caregiverId,
      'name': name,
    };
  }

  bool get isFamilyMember => role == 'FAMILY_MEMBER';
  bool get isCaregiver => role == 'CAREGIVER';
  bool get isPatient => role == 'PATIENT';
  bool get hasWriteAccess => role == 'CAREGIVER';
}

class UserProvider extends ChangeNotifier {
  UserSession? _user;
  UserSession? get user => _user;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Initialize user from stored data on app start
  Future<void> initializeUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use new JWT authentication system to restore session
      final userSession = await AuthTokenManager.restoreSession();
      if (userSession != null) {
        _user = UserSession.fromJson(userSession);

        // Update last activity time
        await AuthTokenManager.updateLastActivity();

        // Check if session is stale due to inactivity
        final isStale = await AuthTokenManager.isSessionStale();
        if (isStale) {
          // Session is stale, clear it and force re-login
          await AuthTokenManager.clearAuthData();
          _user = null;
        }
      }
    } catch (e) {
      // If there's an error, clear any stored auth data
      await AuthTokenManager.clearAuthData();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void setUser(UserSession user) {
    _user = user;
    // Update activity when user is set (e.g., after login)
    AuthTokenManager.updateLastActivity();
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    await AuthTokenManager.clearAuthData();
    notifyListeners();
  }

  // Update user activity for session tracking
  Future<void> updateActivity() async {
    if (_user != null) {
      await AuthTokenManager.updateLastActivity();
    }
  }

  // Check if current session is still valid
  Future<bool> validateSession() async {
    if (_user == null) return false;

    final isValid = await AuthTokenManager.validateCurrentSession();
    if (!isValid) {
      _user = null;
      notifyListeners();
    }
    return isValid;
  }

  // Force refresh the JWT token
  Future<bool> refreshToken() async {
    if (_user == null) return false;

    try {
      final refreshedUser = await AuthService.forceRefreshToken();

      if (refreshedUser != null) {
        _user = refreshedUser;
        notifyListeners();
        return true;
      } else {
        // Refresh failed, clear user
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Token refresh failed in UserProvider: $e');
      _user = null;
      notifyListeners();
      return false;
    }
  }

  bool get isLoggedIn => _user != null;
  bool get isCaregiver => _user?.role.toUpperCase() == 'CAREGIVER';
  bool get isPatient => _user?.role.toUpperCase() == 'PATIENT';
}
