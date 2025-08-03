
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// Registers a custom HTML view with Flutter Web under the 'emotion-video-view' viewType.
void registerEmotionViewFactory() {
  ui_web.platformViewRegistry.registerViewFactory(
    'emotion-video-view',
        (int viewId) {
      final html.VideoElement videoElement = html.VideoElement()
        ..id = 'emotion-video-element'
        ..style.width = '100%'
        ..style.height = '100%'
        ..autoplay = true
        ..muted = true
        ..src = 'your_video_source_url_here'; // replace with actual URL

      return videoElement;
    },
  );
}
