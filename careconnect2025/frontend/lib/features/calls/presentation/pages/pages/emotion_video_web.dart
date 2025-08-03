import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'dart:ui_web' as ui;

class EmotionVideoView extends StatelessWidget {
  const EmotionVideoView({super.key});

  @override
  Widget build(BuildContext context) {
    const viewId = 'emotion-video';
    // Register a view with just a container—no <video> yet

    //ignore:  undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
      final wrapper = html.DivElement()
        ..id = 'emotion-container'
        ..style.width = '480px'
        ..style.height = '360px';
      return wrapper;
    });

    return const HtmlElementView(viewType: viewId);
  }
}
