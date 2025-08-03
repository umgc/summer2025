import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiJoiner {
  void join(String roomCode, {required String displayName}) {
    final jitsiMeet = JitsiMeet();

    final options = JitsiMeetConferenceOptions(
      serverURL: "https://meet.jit.si",
      room: roomCode,
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": false,
        "subject": "Telepresence Session",
      },
      featureFlags: {
        "unsaferoomwarning.enabled": false,
        "chat.enabled": false,
        "invite.enabled": false,
        "pip.enabled": true,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        email: "$displayName@example.com", // Optional placeholder
      ),
    );

    jitsiMeet.join(options);
  }
}
