import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Utility class for web-specific functionality
/// These functions will only be used when running on web platforms
class WebUtils {
  /// Enable viewport meta for better responsive behavior on web
  static void configureWebViewport() {
    if (!kIsWeb) return;

    // Set viewport meta tag for better responsive behavior
    final meta = html.document.querySelector('meta[name="viewport"]');
    if (meta != null) {
      meta.setAttribute(
        'content',
        'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no',
      );
    } else {
      final viewportMeta = html.MetaElement()
        ..name = 'viewport'
        ..content =
            'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      html.document.head!.append(viewportMeta);
    }
  }

  /// Apply CSS to improve touch handling on mobile web
  static void improveWebTouchHandling() {
    if (!kIsWeb) return;

    final styleElement = html.StyleElement();
    styleElement.type = 'text/css';
    styleElement.innerHtml = '''
      * {
        -webkit-tap-highlight-color: transparent;
        touch-action: manipulation;
      }
      html, body {
        height: 100%;
        overflow: hidden;
        position: fixed;
        width: 100%;
      }
    ''';
    html.document.head!.append(styleElement);
  }

  /// Enable hardware acceleration and smooth scrolling
  static void enableWebOptimizations() {
    if (!kIsWeb) return;

    final styleElement = html.StyleElement();
    styleElement.type = 'text/css';
    styleElement.innerHtml = '''
      * {
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }
      .flutter-widget {
        transform: translateZ(0);
        backface-visibility: hidden;
        perspective: 1000px;
      }
    ''';
    html.document.head!.append(styleElement);
  }

  /// Configure PWA properties for web app
  static void configurePwa() {
    if (!kIsWeb) return;

    // Set theme color
    var themeColor = html.document.querySelector('meta[name="theme-color"]');
    if (themeColor == null) {
      themeColor = html.MetaElement()
        ..name = 'theme-color'
        ..content = '#1976D2'; // Using primary color from AppTheme
      html.document.head!.append(themeColor);
    }
  }

  /// Initialize all web optimizations
  static void initializeWebOptimizations() {
    if (!kIsWeb) return;

    configureWebViewport();
    improveWebTouchHandling();
    enableWebOptimizations();
    configurePwa();
  }
}
