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

  /// Disable text selection on web
  static void disableTextSelection() {
    if (!kIsWeb) return;

    final styleElement = html.StyleElement();
    styleElement.type = 'text/css';
    styleElement.innerHtml = '''
      * {
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }
      input, textarea {
        -webkit-user-select: text;
        -moz-user-select: text;
        -ms-user-select: text;
        user-select: text;
      }
    ''';
    html.document.head!.append(styleElement);
  }

  /// Enable scrollbar customization on web
  static void customizeScrollbars() {
    if (!kIsWeb) return;

    final styleElement = html.StyleElement();
    styleElement.type = 'text/css';
    styleElement.innerHtml = '''
      ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }
      ::-webkit-scrollbar-track {
        background: #f1f1f1;
        border-radius: 4px;
      }
      ::-webkit-scrollbar-thumb {
        background: #c1c1c1;
        border-radius: 4px;
      }
      ::-webkit-scrollbar-thumb:hover {
        background: #a8a8a8;
      }
    ''';
    html.document.head!.append(styleElement);
  }

  /// Set theme color for browser UI
  static void setThemeColor(String color) {
    if (!kIsWeb) return;

    var themeColor = html.document.querySelector('meta[name="theme-color"]');
    if (themeColor == null) {
      themeColor = html.MetaElement()
        ..name = 'theme-color'
        ..content = color;
      html.document.head!.append(themeColor);
    } else {
      themeColor.setAttribute('content', color);
    }
  }

  /// Add web-specific CSS styles
  static void addWebStyles() {
    if (!kIsWeb) return;

    final styleElement = html.StyleElement();
    styleElement.type = 'text/css';
    styleElement.innerHtml = '''
      body {
        margin: 0;
        padding: 0;
        overflow: hidden;
      }
      * {
        -webkit-tap-highlight-color: transparent;
        touch-action: manipulation;
      }
      .flutter-widget {
        transform: translateZ(0);
        backface-visibility: hidden;
        perspective: 1000px;
      }
    ''';
    html.document.head!.append(styleElement);
  }

  /// Configure web app manifest properties
  static void configureWebApp() {
    if (!kIsWeb) return;

    configureWebViewport();
    addWebStyles();
    customizeScrollbars();
    setThemeColor('#1976D2');
  }

  /// Initialize all web optimizations
  static void initializeWebOptimizations() {
    if (!kIsWeb) return;

    configureWebViewport();
    addWebStyles();
    customizeScrollbars();
    setThemeColor('#1976D2');
  }
}
