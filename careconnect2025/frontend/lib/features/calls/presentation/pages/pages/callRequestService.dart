import 'package:firebase_database/firebase_database.dart';

Future<void> sendCallRequest({
  required String fromUserId,
  required String toUserId,
  required String roomId,
}) async {
  final ref = FirebaseDatabase.instance.ref('calls/$toUserId');  // Reference to the 'calls' node
  await ref.set({
    'from': fromUserId,
    'roomId': roomId,
    'status': 'ringing',
    'timestamp': ServerValue.timestamp,  // Firebase server timestamp
  });
}

