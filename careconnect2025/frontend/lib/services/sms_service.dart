import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
// import 'package:telephony/telephony.dart'; // Temporarily disabled due to namespace issue

class SMSService {
  // static final Telephony _telephony = Telephony.instance; // Temporarily disabled

  /// Send SMS on different platforms
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      if (kIsWeb) {
        // Web platform - open SMS app
        return await _sendSMSWeb(phoneNumber, message);
      } else {
        // Mobile platforms (iOS/Android)
        return await _sendSMSMobile(phoneNumber, message);
      }
    } catch (e) {
      print('❌ Error sending SMS: $e');
      return false;
    }
  }

  /// Send SMS on mobile platforms (iOS/Android)
  static Future<bool> _sendSMSMobile(String phoneNumber, String message) async {
    try {
      // Temporarily disabled - use URL launcher instead
      print('📱 Using URL launcher for SMS (telephony package disabled)');
      return await _sendSMSWeb(phoneNumber, message);

      // Original telephony code (disabled):
      // bool? permissionsGranted = await _telephony.requestPhoneAndSmsPermissions;
      // if (permissionsGranted != true) {
      //   print('❌ SMS permissions not granted');
      //   return await _sendSMSWeb(phoneNumber, message);
      // }
      // await _telephony.sendSms(to: phoneNumber, message: message);
      // print('✅ SMS sent successfully to $phoneNumber');
      // return true;
    } catch (e) {
      print('❌ Error sending SMS on mobile: $e');
      // Fallback to URL launcher
      return await _sendSMSWeb(phoneNumber, message);
    }
  }

  /// Send SMS via URL launcher (works on all platforms)
  static Future<bool> _sendSMSWeb(String phoneNumber, String message) async {
    try {
      // Clean phone number
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create SMS URL
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        print('✅ SMS app opened successfully');
        return true;
      } else {
        // Fallback: Try to open email client on web
        if (kIsWeb) {
          return await _sendEmailFallback(phoneNumber, message);
        }
        print('❌ Cannot launch SMS app');
        return false;
      }
    } catch (e) {
      print('❌ Error launching SMS app: $e');
      // Try email fallback on web
      if (kIsWeb) {
        return await _sendEmailFallback(phoneNumber, message);
      }
      return false;
    }
  }

  /// Email fallback for web when SMS is not available
  static Future<bool> _sendEmailFallback(
    String phoneNumber,
    String message,
  ) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: '', // No specific email
        queryParameters: {
          'subject': 'Message for $phoneNumber',
          'body': 'Phone: $phoneNumber\n\nMessage:\n$message',
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        print('✅ Email client opened as SMS fallback');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error opening email fallback: $e');
      return false;
    }
  }

  /// Check if SMS functionality is available
  static Future<bool> isSMSAvailable() async {
    try {
      if (kIsWeb) {
        // On web, we can always try to open SMS app
        return true;
      } else {
        // Temporarily disabled - assume SMS capability
        print('📱 SMS capability check disabled (telephony package disabled)');
        return true; // Assume SMS is available

        // Original telephony code (disabled):
        // bool? canSendSms = await _telephony.isSmsCapable;
        // return canSendSms ?? false;
      }
    } catch (e) {
      print('❌ Error checking SMS availability: $e');
      return false;
    }
  }

  /// Format phone number for SMS
  static String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters except +
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Add country code if not present
    if (!cleaned.startsWith('+')) {
      // Assume US number if no country code
      cleaned = '+1$cleaned';
    }

    return cleaned;
  }

  /// Send emergency SMS with location (if available)
  static Future<bool> sendEmergencySMS({
    required String phoneNumber,
    required String patientName,
    String? location,
  }) async {
    String message = '🚨 EMERGENCY ALERT 🚨\n';
    message += 'Patient: $patientName\n';
    message += 'Time: ${DateTime.now().toString()}\n';

    if (location != null && location.isNotEmpty) {
      message += 'Location: $location\n';
    }

    message += 'Please respond immediately.';

    return await sendSMS(phoneNumber: phoneNumber, message: message);
  }

  /// Send appointment reminder SMS
  static Future<bool> sendAppointmentReminder({
    required String phoneNumber,
    required String patientName,
    required DateTime appointmentTime,
    required String doctorName,
  }) async {
    String message = '📅 Appointment Reminder\n';
    message += 'Hi $patientName,\n';
    message += 'You have an appointment with $doctorName\n';
    message += 'on ${_formatDateTime(appointmentTime)}.\n';
    message += 'Please arrive 15 minutes early.';

    return await sendSMS(phoneNumber: phoneNumber, message: message);
  }

  /// Send medication reminder SMS
  static Future<bool> sendMedicationReminder({
    required String phoneNumber,
    required String patientName,
    required String medicationName,
    required String dosage,
  }) async {
    String message = '💊 Medication Reminder\n';
    message += 'Hi $patientName,\n';
    message += 'Time to take your $medicationName\n';
    message += 'Dosage: $dosage\n';
    message += 'Take with food if required.';

    return await sendSMS(phoneNumber: phoneNumber, message: message);
  }

  /// Format DateTime for display
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
