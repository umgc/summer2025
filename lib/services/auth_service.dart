import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:focused_ai_ui/services/moodle_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/google_constants.dart';
import '../models/user.dart';
import 'google_classroom_service.dart';

class AuthService with ChangeNotifier {
  static User? _currentUser;
  static String? _jwt;

  final MoodleService _moodleService = MoodleService();

  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final GoogleClassroomService _googleClassroomService =
      GoogleClassroomService();

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String? get jwt => _jwt;
  bool _isRoleDetermining = false;
  bool get isRoleDetermining => _isRoleDetermining;

  // IMPORTANT: Must be called before Google sign-in is attempted
  Future<void> initializeAuth() async {
    print('AuthService: Initializing authentication...');
    try {
      await _googleSignIn.initialize(clientId: GoogleConstants.clientId);
      print('AuthService: GoogleSignIn initialized.');

      // Listen to authentication events from the GoogleSignIn instance.
      // This stream provides updates when a user signs in, signs out, or an error occurs.
      _googleSignIn.authenticationEvents
          .listen(_handleAuthenticationEvent)
          .onError(_handleAuthenticationError);
      print('AuthService: Listening to authentication events...');

      // Attempt to silently sign in if a previous session exists.
      unawaited(_googleSignIn.attemptLightweightAuthentication());
      print('AuthService: Attempting silent sign-in...');
    } catch (e) {
      print('AuthService: Error during authentication initialization: $e');
      _currentUser = null;
      _jwt = null;
    } finally {
      notifyListeners();
      print('AuthService: Authentication initialization complete.');
    }
  }

  // Handles incoming authentication events from GoogleSignIn.
  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    GoogleSignInAccount? googleUser;
    if (event is GoogleSignInAuthenticationEventSignIn) {
      googleUser = event.user;
    } else if (event is GoogleSignInAuthenticationEventSignOut) {
      googleUser = null;
    } else if (event is GoogleSignInException) {
      print('AuthService: Authentication event exception: ${event.toString()}');
      googleUser = null;
    }

    if (googleUser != null) {
      print(
        'AuthService: Google user authenticated: ${googleUser.email}. Initiating login...',
      );
      _isRoleDetermining = true;
      notifyListeners();

      try {
        final GoogleSignInAuthorizationClient googleAuthClient =
            googleUser.authorizationClient;
        final GoogleSignInServerAuthorization? serverAuth =
            await googleAuthClient.authorizeServer(GoogleConstants.scopes);

        if (serverAuth?.serverAuthCode == null) {
          throw Exception('Google server auth code is null.');
        }

        // GoogleClassroomService to handle the backend call and role determination
        final Map<String, dynamic>? loginResult = await _googleClassroomService
            .login(serverAuth!.serverAuthCode, googleUser);

        if (loginResult != null &&
            loginResult.containsKey('user') &&
            loginResult.containsKey('jwt')) {
          _currentUser = loginResult['user'] as User; // Extract User object
          _jwt = loginResult['jwt'] as String; // Extract JWT token

          print(
            'AuthService: Google login successful via backend. Role: ${_currentUser!.role.name}',
          );
        } else {
          throw Exception(
            'Google login failed: Invalid response from GoogleClassroomService.',
          );
        }
      } catch (e) {
        print('AuthService: Error during Google login via backend: $e');
        _currentUser = null;
        _jwt = null;
      } finally {
        _isRoleDetermining = false;
        notifyListeners();
      }
    } else {
      _currentUser = null;
      _jwt = null;
      _isRoleDetermining = false;
      print('AuthService: Google user signed out or not available.');
      notifyListeners();
    }
  }

  // Handles errors specifically from the GoogleSignIn authentication stream.
  void _handleAuthenticationError(Object e) {
    print('AuthService: Google Sign-in authentication stream error: $e');
    _currentUser = null;
    _jwt = null;
    _isRoleDetermining = false;
    notifyListeners();
  }

  Future<void> signInWithMoodle({
    required String moodleUrl,
    required String username,
    required String password,
  }) async {
    print('AuthService: Attempting Moodle login to $moodleUrl with username $username ...');
    _isRoleDetermining = true;
    notifyListeners();

    try {
      final Map<String, dynamic> loginResult = await _moodleService.login(
        moodleUrl,
        username,
        password,
      );

      if (loginResult.containsKey('user') &&
          loginResult.containsKey('jwt')) {
        _currentUser = loginResult['user'] as User;
        _jwt = loginResult['jwt'] as String;

        print(
          'AuthService: Moodle login successful via backend. Role: ${_currentUser!.role.name}',
        );
      } else {
        throw Exception(
          'Moodle login failed: Invalid response from MoodleService.',
        );
      }
    } catch (e) {
      print('AuthService: Error during Moodle login via backend: $e');
      _currentUser = null;
      _jwt = null;
      throw Exception('Moodle login failed: ${e.toString()}');
    } finally {
      _isRoleDetermining = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    print('AuthService: Attempting logout...');
    // `disconnect()` signs out the user from Google and revokes app access.
    await _googleSignIn.disconnect();
    print(
      'AuthService: Disconnected Google account (if previously connected).',
    );
    _currentUser = null;
    _jwt = null;
    _isRoleDetermining = false;
    notifyListeners();
    print('AuthService: Logged out from app.');
  }

  Future<void> handleUnauthorized() async {
    print('AuthService: Handling unauthorized access');
    _jwt = null;
    _currentUser = null;
    notifyListeners();
    await logout();
  }

  Map<String, String> get authHeaders {
    return {
      'Content-Type': 'application/json',
      if (_jwt != null) 'Authorization': 'Bearer $_jwt',
    };
  }
}

class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

// Global singleton instance of AuthService
final authService = AuthService();
