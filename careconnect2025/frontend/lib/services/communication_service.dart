import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/theme/app_theme.dart';

class CommunicationService {
  // Make a phone call
  static Future<void> makePhoneCall(
    String phoneNumber,
    BuildContext context,
  ) async {
    try {
      // Clean phone number
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Check for call permission on Android
      if (Theme.of(context).platform == TargetPlatform.android) {
        var status = await Permission.phone.status;
        if (!status.isGranted) {
          status = await Permission.phone.request();
          if (!status.isGranted) {
            _showError('Call permission denied', context);
            return;
          }
        }
      }

      // Create tel URI
      final Uri uri = Uri.parse('tel:$cleanPhone');

      // Launch phone app
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('Cannot launch phone app', context);
      }
    } catch (e) {
      print('❌ Phone call error: $e');
      _showError('Failed to make call: $e', context);
    }
  }

  // Send SMS
  static Future<void> sendSMS(
    String phoneNumber,
    BuildContext context, {
    String? message,
  }) async {
    try {
      // Clean phone number
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create SMS URI
      String smsUri = 'sms:$cleanPhone';
      if (message != null && message.isNotEmpty) {
        smsUri += '?body=${Uri.encodeComponent(message)}';
      }

      // Launch SMS app
      final Uri uri = Uri.parse(smsUri);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('Cannot launch SMS app', context);
      }
    } catch (e) {
      print('❌ SMS error: $e');
      _showError('Failed to send SMS: $e', context);
    }
  }

  // Start a video call (using a simple web-based approach for now)
  static Future<void> startVideoCall(
    String patientId,
    String patientName,
    BuildContext context,
  ) async {
    try {
      // For now, we'll use a simple web-based video call solution
      // In a real app, you'd integrate a proper video SDK like Agora, Twilio, etc.
      final String meetingId =
          'careconnect-$patientId-${DateTime.now().millisecondsSinceEpoch}';
      final Uri uri = Uri.parse('https://meet.jit.si/$meetingId');

      // Check camera permission
      var cameraStatus = await Permission.camera.status;
      var micStatus = await Permission.microphone.status;

      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();
      }

      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        _showError(
          'Camera and microphone permissions are required for video calls',
          context,
        );
        return;
      }

      // Launch video call
      if (await canLaunchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Starting video call with $patientName')),
        );
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showError('Cannot launch video call', context);
      }
    } catch (e) {
      print('❌ Video call error: $e');
      _showError('Failed to start video call: $e', context);
    }
  }

  // Show error message
  static void _showError(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.error),
    );
  }
}
