import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class EnhancedSMSService {
  static const String _baseUrl = 'http://localhost:8080'; // Your backend URL

  /// Send SMS through backend (production approach)
  /// This replaces opening the SMS app and actually sends the message
  static Future<bool> sendSMSViaBackend({
    required String toPhone,
    required String message,
    required String fromUserId,
    required String fromUserName,
    String? authToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/api/sms/send'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'toPhone': toPhone,
          'message': message,
          'fromUserId': fromUserId,
          'fromUserName': fromUserName,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SMS sent via backend: ${data['message']}');
        return data['success'] ?? false;
      } else {
        print('❌ Backend SMS failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ SMS backend error: $e');
      return false;
    }
  }

  /// Send emergency SMS to all caregivers/family
  static Future<bool> sendEmergencySMS({
    required String patientId,
    required String message,
    String? location,
    String? authToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/api/sms/emergency'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'patientId': patientId,
          'message': message,
          'location': location ?? 'Unknown location',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🚨 Emergency SMS sent to ${data['sentCount']} contacts');
        return data['success'] ?? false;
      } else {
        print('❌ Emergency SMS failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Emergency SMS error: $e');
      return false;
    }
  }

  /// Fallback: Open SMS app (when backend is not available)
  static Future<bool> sendSMSFallback({
    required String toPhone,
    required String message,
  }) async {
    try {
      // Clean phone number
      String cleanNumber = toPhone.replaceAll(RegExp(r'[^\d+]'), '');

      // Create SMS URL
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print('✅ SMS app opened (fallback mode)');
        return true;
      } else {
        print('❌ Cannot open SMS app');
        return false;
      }
    } catch (e) {
      print('❌ SMS fallback error: $e');
      return false;
    }
  }

  /// Smart SMS sending: Try backend first, fallback to SMS app
  static Future<bool> sendSMS({
    required String toPhone,
    required String message,
    required String fromUserId,
    required String fromUserName,
    String? authToken,
    BuildContext? context,
  }) async {
    // Try backend first (preferred method)
    if (!kIsWeb) {
      // Backend SMS works better on mobile
      bool backendSuccess = await sendSMSViaBackend(
        toPhone: toPhone,
        message: message,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        authToken: authToken,
      );

      if (backendSuccess) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ SMS sent successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      }

      print('⚠️ Backend SMS failed, trying fallback...');
    }

    // Fallback to opening SMS app
    bool fallbackSuccess = await sendSMSFallback(
      toPhone: toPhone,
      message: message,
    );

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            fallbackSuccess ? '📱 SMS app opened' : '❌ Failed to send SMS',
          ),
          backgroundColor: fallbackSuccess ? Colors.orange : Colors.red,
        ),
      );
    }

    return fallbackSuccess;
  }
}

/// Usage examples for integration with your dashboard
class SMSIntegrationExamples {
  /// Send SMS from caregiver to patient
  static Future<void> sendCaregiverToPatientSMS({
    required String patientPhone,
    required String message,
    required String caregiverUserId,
    required String caregiverName,
    String? authToken,
    BuildContext? context,
  }) async {
    await EnhancedSMSService.sendSMS(
      toPhone: patientPhone,
      message: message,
      fromUserId: caregiverUserId,
      fromUserName: caregiverName,
      authToken: authToken,
      context: context,
    );
  }

  /// Send SMS from patient to caregiver
  static Future<void> sendPatientToCaregiverSMS({
    required String caregiverPhone,
    required String message,
    required String patientUserId,
    required String patientName,
    String? authToken,
    BuildContext? context,
  }) async {
    await EnhancedSMSService.sendSMS(
      toPhone: caregiverPhone,
      message: message,
      fromUserId: patientUserId,
      fromUserName: patientName,
      authToken: authToken,
      context: context,
    );
  }

  /// Emergency SMS for critical situations
  static Future<void> sendPatientEmergency({
    required String patientUserId,
    required String emergencyMessage,
    String? location,
    String? authToken,
    BuildContext? context,
  }) async {
    bool success = await EnhancedSMSService.sendEmergencySMS(
      patientId: patientUserId,
      message: emergencyMessage,
      location: location,
      authToken: authToken,
    );

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '🚨 Emergency alert sent to all contacts'
                : '❌ Failed to send emergency alert',
          ),
          backgroundColor: success ? Colors.red : Colors.grey,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
