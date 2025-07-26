import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_links/app_links.dart';
import 'dart:async';
import '../config/env_constant.dart';
import 'api_service.dart';
import 'oauth_service.dart';
import '../providers/user_provider.dart';
import 'auth_token_manager.dart';

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/v1/api/auth';
  static final String caregivers = '$_host/v1/api/caregivers';
  static final String users = '$_host/v1/api/users';
  static final String webBaseUrl = getWebBaseUrl();
  static String get baseUrl => _host;
}

class AuthService {
  // Stream for listening to deep links (OAuth callbacks)
  static StreamSubscription<Uri>? _linkSubscription;
  static late AppLinks _appLinks;

  // ✅ Handle OAuth callback from deep link
  static Future<void> handleOAuthCallback(String code, String state) async {
    try {
      // This method can be used for additional callback handling if needed
      // For now, the main logic is in loginWithGoogle()
      print('OAuth callback received: code=$code, state=$state');
    } catch (e) {
      print('Error handling OAuth callback: $e');
    }
  }

  // ✅ GOOGLE OAUTH2 LOGIN - Backend-first OAuth2 flow
  static Future<UserSession> loginWithGoogle() async {
    try {
      // Initialize app links if not already done
      _appLinks = AppLinks();

      // Clear any existing OAuth session
      OAuthService.clearSession();

      // Launch the OAuth2 flow (redirects to backend, then Google, then back)
      await OAuthService.launchGoogleOAuth();

      // Listen for the deep link callback from the backend
      final completer = Completer<UserSession>();

      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) async {
          try {
            // Check if this is our OAuth callback
            if (uri.scheme == 'careconnect' &&
                uri.host == 'oauth' &&
                uri.path == '/callback') {
              // Extract the JWT token and user data from the callback URL
              final token = uri.queryParameters['token'];
              final error = uri.queryParameters['error'];

              if (error != null) {
                completer.completeError(Exception('OAuth error: $error'));
                return;
              }

              if (token == null) {
                completer.completeError(
                  Exception('No JWT token received from backend'),
                );
                return;
              }

              // The backend has already validated the Google token and generated JWT
              // Now we just need to parse the user session and save the token
              final userDataString = uri.queryParameters['user'];
              if (userDataString == null) {
                completer.completeError(
                  Exception('No user data received from backend'),
                );
                return;
              }

              // Decode the user data
              final userData = jsonDecode(Uri.decodeComponent(userDataString));

              // Create user session
              final userSession = UserSession.fromJson(userData);

              // Force update JWT token and session using the new token manager
              // This ensures fresh tokens are always used after OAuth login
              await AuthTokenManager.saveAuthData(
                jwtToken: token,
                userSession: userSession.toJson(),
              );

              // Update last activity time to track session freshness
              await AuthTokenManager.updateLastActivity();

              print('✅ Google OAuth login successful: JWT token force-updated');

              // Create and return the user session
              completer.complete(userSession);
            }
          } catch (e) {
            completer.completeError(e);
          } finally {
            _linkSubscription?.cancel();
            _linkSubscription = null;
            OAuthService.clearSession();
          }
        },
        onError: (err) {
          completer.completeError(err);
          _linkSubscription?.cancel();
          _linkSubscription = null;
          OAuthService.clearSession();
        },
      );

      // Set a timeout for the OAuth flow
      Timer(const Duration(minutes: 5), () {
        if (!completer.isCompleted) {
          _linkSubscription?.cancel();
          _linkSubscription = null;
          OAuthService.clearSession();
          completer.completeError(Exception('OAuth flow timed out'));
        }
      });

      return await completer.future;
    } catch (e) {
      _linkSubscription?.cancel();
      _linkSubscription = null;
      OAuthService.clearSession();
      rethrow;
    }
  }

  // ✅ LOGIN - Updated to return UserSession and handle JWT
  static Future<UserSession> login(
    String email,
    String password, {
    required String role,
  }) async {
    final response = await ApiService.login(email, password, role: role);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userSession = UserSession.fromJson(data);

      // Force update JWT token and session using the new token manager
      // This ensures fresh tokens are always used after login
      await AuthTokenManager.saveAuthData(
        jwtToken: userSession.token,
        userSession: userSession.toJson(),
      );

      // Update last activity time to track session freshness
      await AuthTokenManager.updateLastActivity();

      print('✅ Login successful: JWT token force-updated');

      return userSession;
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<String> register({
    required String name,
    required String email,
    required String password,
    String role = 'patient',
    required String verificationBaseUrl,
  }) async {
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/register'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'verificationBaseUrl': verificationBaseUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("✅ Registration: $data");
      // If backend returns a string: just return it
      if (data is String) return data;
      // If backend returns JSON: extract a message
      return data['message'] ??
          'Registration successful! Please check your email to verify your account.';
    } else {
      print("❌ Registration Error: $data");
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  static Future<Map<String, dynamic>> registerCaregiver({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? dob,
    String? phone,
    String? gender,
    String? licenseNumber,
    String? issuingState,
    int? yearsExperience,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
  }) async {
    final headers = {'Content-Type': 'application/json'};

    // Build registration data with null safety
    final Map<String, dynamic> registrationData = {
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob ?? "01/01/1990",
      'email': email,
      'phone': phone ?? "000-000-0000",
      'gender': gender ?? "",
    };

    print('🔍 Debug: Basic data added successfully');

    // Only add professional info if at least license number is provided
    if (licenseNumber != null && licenseNumber.isNotEmpty) {
      print('🔍 Debug: Adding professional info...');
      registrationData['professional'] = {
        'licenseNumber': licenseNumber,
        'issuingState': issuingState ?? "VA",
        'yearsExperience': yearsExperience ?? 1,
      };
      print('🔍 Debug: Professional info added successfully');
    }

    // Only add address if at least line1 is provided
    if (addressLine1 != null && addressLine1.isNotEmpty) {
      print('🔍 Debug: Adding address info...');
      registrationData['address'] = {
        'line1': addressLine1,
        'line2': addressLine2 ?? "",
        'city': city ?? "City",
        'state': state ?? "VA",
        'zip': zip ?? "00000",
        'phone': phone ?? "000-000-0000",
      };
      print('🔍 Debug: Address info added successfully');
    }

    // Always add credentials
    registrationData['credentials'] = {'email': email, 'password': password};

    print('🔍 Debug: About to encode registration data...');
    print('🔍 Registration data keys: ${registrationData.keys}');

    try {
      final jsonString = jsonEncode(registrationData);
      print('🚀 Registering caregiver with data: $jsonString');
    } catch (jsonError) {
      print('❌ JSON encoding failed: $jsonError');
      throw Exception('Data serialization error: $jsonError');
    }

    try {
      print('🔍 Debug: About to make HTTP POST request...');
      print('🔍 Debug: getBackendBaseUrl(): ${getBackendBaseUrl()}');
      print('🔍 Debug: ApiConstants.caregivers: ${ApiConstants.caregivers}');
      print('🔍 Debug: URL: ${ApiConstants.caregivers}');
      print('🔍 Debug: Headers: $headers');

      final response = await http.post(
        Uri.parse(ApiConstants.caregivers),
        headers: headers,
        body: jsonEncode(registrationData),
      );

      print('✅ Debug: HTTP request completed successfully');
      print('📡 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("✅ Caregiver Registration: $data");

        // Extract user ID and stripeCustomerId from the nested user object
        String userId = '0';
        String stripeCustomerId = '';
        if (data.containsKey('user') && data['user'] is Map<String, dynamic>) {
          final userObj = data['user'] as Map<String, dynamic>;
          userId = userObj['id']?.toString() ?? '0';
          stripeCustomerId = userObj['stripeCustomerId'] ?? '';
          print("✅ Extracted User ID: $userId from nested user object");
          print(
            "✅ Extracted Stripe Customer ID: $stripeCustomerId from nested user object",
          );
        } else {
          print("⚠️ Warning: User object not found in registration response");
        }

        // Return both the success message and the user info
        return {
          'message': 'Caregiver registration successful!',
          'userId': userId, // Use the user ID from the nested user object
          'caregiverId':
              data['id']?.toString() ?? '0', // Also store the caregiver ID
          'stripeCustomerId': stripeCustomerId, // Include Stripe customer ID
        };
      } else {
        final data = jsonDecode(response.body);
        print(
          "❌ Caregiver Registration failed: ${response.statusCode} - ${response.body}",
        );
        throw Exception(data['error'] ?? 'Caregiver registration failed');
      }
    } catch (e) {
      print('🚨 Exception during caregiver registration: $e');
      rethrow;
    }
  }

  static Future<String> verifyEmail(String token) async {
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/verify'),
      headers: headers,
      body: jsonEncode({'token': token}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("✅ Email verification: $data");
      return data['message'] ?? 'Email verified successfully!';
    } else {
      print("❌ Email verification error: $data");
      throw Exception(data['error'] ?? 'Email verification failed');
    }
  }

  static Future<String> requestPasswordReset({required String email}) async {
    try {
      // Fix: Use ApiConstants.auth which includes the full path
      final fullUrl = '${ApiConstants.auth}/password/forgot';
      print('🔍 Request password reset URL: $fullUrl');

      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['message'] ??
            'Password reset link sent to your email';
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send reset link');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<String> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.users}/reset-password'), // Correct endpoint
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': email, // Use email as username
          'resetToken': resetToken, // 48-character token from email
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print("✅ Password reset successful: $data");
        return data['message'] ?? 'Password reset successfully!';
      } else {
        print(
          "❌ Password reset error: ${response.statusCode} - ${response.body}",
        );
        final errorMessage =
            data['error'] ?? data['message'] ?? 'Password reset failed';

        // Handle specific error cases
        if (errorMessage.toLowerCase().contains('expired')) {
          throw Exception(
            'Password reset link has expired. Please request a new one.',
          );
        } else if (errorMessage.toLowerCase().contains('invalid')) {
          throw Exception(
            'Invalid reset token. Please request a new password reset.',
          );
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print("❌ Password reset exception: $e");
      rethrow;
    }
  }

  static Future<void> logout() async {
    final headers = await AuthTokenManager.getAuthHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/logout'),
      headers: headers,
    );

    // Clear all auth data using the new token manager
    await AuthTokenManager.clearAuthData();

    if (response.statusCode == 200) {
      print("✅ Logout successful");
    } else {
      print("Logout failed: ${response.statusCode} - ${response.body}");
    }
  }

  // ✅ PROCESS OAUTH CALLBACK - For web-based callbacks
  static Future<UserSession> processOAuthCallback({
    required String token,
    required String userDataString,
  }) async {
    try {
      // Parse user data (it's URL encoded)
      final userData = jsonDecode(Uri.decodeComponent(userDataString));

      // Create user session
      final userSession = UserSession.fromJson(userData);

      // Force update JWT token and session using the new token manager
      // This ensures fresh tokens are always used after OAuth callback
      await AuthTokenManager.saveAuthData(
        jwtToken: token,
        userSession: userSession.toJson(),
      );

      // Update last activity time to track session freshness
      await AuthTokenManager.updateLastActivity();

      print('✅ OAuth callback processed: JWT token force-updated');

      // Create and return the user session
      return userSession;
    } catch (e) {
      throw Exception('Failed to process OAuth callback: $e');
    }
  }

  // ✅ FORCE REFRESH JWT TOKEN - For scenarios where token needs to be refreshed
  static Future<UserSession?> forceRefreshToken() async {
    try {
      final currentToken = await AuthTokenManager.getJwtToken();
      if (currentToken == null) {
        print('❌ No existing token to refresh');
        return null;
      }

      // Make a call to backend to refresh the token
      final headers = await AuthTokenManager.getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.auth}/refresh-token'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userSession = UserSession.fromJson(data);

        // Force update with new JWT token
        await AuthTokenManager.saveAuthData(
          jwtToken: userSession.token,
          userSession: userSession.toJson(),
        );

        // Update last activity time
        await AuthTokenManager.updateLastActivity();

        print('✅ JWT token force-refreshed successfully');
        return userSession;
      } else {
        print('❌ Token refresh failed: ${response.statusCode}');
        // If refresh fails, clear auth data to force re-login
        await AuthTokenManager.clearAuthData();
        return null;
      }
    } catch (e) {
      print('❌ Error during token refresh: $e');
      // Clear auth data on error to force re-login
      await AuthTokenManager.clearAuthData();
      return null;
    }
  }

  // ✅ UPDATE USER ACTIVITY - For tracking session activity
  static Future<void> updateUserActivity() async {
    await AuthTokenManager.updateLastActivity();
  }

  // static Future<String> setupPassword({
  //   required String email,
  //   required String resetToken,
  //   required String newPassword,
  // }) async {
  //   try {
  //     final fullUrl = '${ApiConstants.users}/reset-password';
  //     final requestBody = {
  //       'username': email,
  //       'resetToken': resetToken,
  //       'newPassword': newPassword,
  //     };

  //     final response = await http.post(
  //       Uri.parse(fullUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       return responseData['message'] ?? 'Password updated successfully';
  //     } else {
  //       final errorData = jsonDecode(response.body);
  //       throw Exception(
  //         errorData['message'] ??
  //         errorData['error'] ??
  //         'Failed to update password',
  //       );
  //     }
  //   } catch (e)
  //     throw Exception('Network error: ${e.toString()}');
  //   }
}
