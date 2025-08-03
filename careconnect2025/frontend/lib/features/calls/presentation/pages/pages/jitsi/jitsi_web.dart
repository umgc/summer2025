import 'dart:html' as html;
import 'dart:ui_web' as ui;

class JitsiJoiner {
  void join(String roomCode) {
    final jitsiUrl = 'https://meet.jit.si/$roomCode';
    html.window.open(jitsiUrl, '_blank');
  }
}
