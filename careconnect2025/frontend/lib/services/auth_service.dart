import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_constant.dart';

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/api/auth';
  static final String caregivers = '$_host/v1/api/caregivers';
}

class AuthService {
  // ✅ LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    required String role,
  }) async {
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // Return full user object
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
      // Try to extract error details
      throw Exception(
        data['error'] ?? data.toString() ?? 'Registration failed',
      );
    }
  }

  // ✅ CAREGIVER REGISTRATION using proper API endpoint
  static Future<String> registerCaregiver({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? dob,
    String? phone,
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
        return 'Caregiver registration successful!';
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

  // ✅ LOGOUT
  static Future<void> logout() async {
    final headers = {'Content-Type': 'application/json'};

    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/logout'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      print("✅ Logout successful");
    } else {
      print("❌ Logout failed: ${response.statusCode} - ${response.body}");
    }
  }
}
