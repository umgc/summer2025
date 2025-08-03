import 'dart:html';
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:ui_web' as ui;

// Variable to track if the view is already registered
bool _isViewRegistered = false;

void registerJitsiView() {
  if (_isViewRegistered) return;

  // Default to Public Jitsi server URL for production
  String jitsiBaseUrl = 'https://meet.jit.si/';  // Public Jitsi URL for production

  // If running locally, dynamically generate the URL based on current port
  if (window.location.host.contains('localhost')) {
    final currentPort = window.location.port; // Dynamically get current port
    jitsiBaseUrl = 'http://localhost:$currentPort/index.html'; // Construct URL with the correct port
  }

  // Register the Jitsi iframe view using platformViewRegistry
  ui.platformViewRegistry.registerViewFactory('jitsi-view', (int viewId) {
    final iframe = IFrameElement()
      ..width = '100%'
      ..height = '100%'
      ..src = jitsiBaseUrl // Use dynamically generated URL
      ..style.border = 'none';  // Remove the iframe border

    return iframe;
  });

  _isViewRegistered = true;
}
