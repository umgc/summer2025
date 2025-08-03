import 'package:flutter/foundation.dart';
import 'jitsi_mobile.dart' as mobile;
import 'jitsi_web.dart' as web;

class JitsiLauncher {
  static void join(String roomCode, {required String displayName}) {
    if (kIsWeb) {
      web.JitsiJoiner().join(roomCode);
    } else {
      mobile.JitsiJoiner().join(roomCode, displayName: '');
    }
  }
}
