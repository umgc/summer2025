import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RTCSignalingService {
  final String roomId;
  final bool isCaller;
  final Function(MediaStream) onRemoteStream;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RTCSignalingService({
    required this.roomId,
    required this.isCaller,
    required this.onRemoteStream,
  });

  Future<void> init() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    _peerConnection = await createPeerConnection(config);

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'},
    });

    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onTrack = (event) {
      onRemoteStream(event.streams[0]);
    };

    _peerConnection!.onIceCandidate = (candidate) async {
      final candidateData = {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      };
      final field = isCaller ? 'callerCandidates' : 'calleeCandidates';
      await _firestore.collection('rooms').doc(roomId).collection(field).add(candidateData);
    };

    if (isCaller) {
      await _startCall();
    } else {
      await _joinCall();
    }

    _listenForRemoteCandidates();
  }

  Future<void> _startCall() async {
    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    await _firestore.collection('rooms').doc(roomId).set({
      'offer': {
        'type': offer.type,
        'sdp': offer.sdp,
      },
    });

    _firestore.collection('rooms').doc(roomId).snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null && data['answer'] != null) {
        final answer = RTCSessionDescription(data['answer']['sdp'], data['answer']['type']);
        await _peerConnection!.setRemoteDescription(answer);
      }
    });
  }

  Future<void> _joinCall() async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    final offer = doc['offer'];
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await _firestore.collection('rooms').doc(roomId).update({
      'answer': {
        'type': answer.type,
        'sdp': answer.sdp,
      },
    });
  }

  void _listenForRemoteCandidates() {
    final oppositeField = isCaller ? 'calleeCandidates' : 'callerCandidates';
    _firestore.collection('rooms').doc(roomId).collection(oppositeField).snapshots().listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        final data = docChange.doc.data();
        _peerConnection!.addCandidate(RTCIceCandidate(
          data!['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        ));
      }
    });
  }

  MediaStream? getLocalStream() => _localStream;
  void dispose() {
    _localStream?.dispose();
    _peerConnection?.close();
  }
}
