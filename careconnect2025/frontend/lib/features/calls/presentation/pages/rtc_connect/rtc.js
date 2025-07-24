// 👉 Make sure config.js is loaded before this script in HTML
firebase.initializeApp(window.firebaseConfig);
const firestore = firebase.firestore();

const servers = {
  iceServers: [{ urls: "stun:stun.l.google.com:19302" }]
};

let pc = new RTCPeerConnection(servers);
let localStream = null;
let remoteStream = new MediaStream();

// 🎥 Elements
const localVideo = document.getElementById("localVideo");
const remoteVideo = document.getElementById("remoteVideo");
const startCallBtn = document.getElementById("startCall");
const joinCallBtn = document.getElementById("joinCall");
const roomIdInput = document.getElementById("roomIdInput");

remoteVideo.srcObject = remoteStream;

// 🎙️ Get camera & microphone
navigator.mediaDevices.getUserMedia({ video: true, audio: true }).then(stream => {
  localStream = stream;
  localVideo.srcObject = stream;
  stream.getTracks().forEach(track => pc.addTrack(track, stream));
});

pc.ontrack = event => {
  event.streams[0].getTracks().forEach(track => remoteStream.addTrack(track));
};

startCallBtn.onclick = async () => {
  const roomRef = firestore.collection("rooms").doc();
  roomIdInput.value = roomRef.id;

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);
  await roomRef.set({ offer: { type: offer.type, sdp: offer.sdp } });

  pc.onicecandidate = event => {
    if (event.candidate) {
      roomRef.collection("callerCandidates").add(event.candidate.toJSON());
    }
  };

  roomRef.onSnapshot(snapshot => {
    const data = snapshot.data();
    if (data?.answer && !pc.currentRemoteDescription) {
      pc.setRemoteDescription(new RTCSessionDescription(data.answer));
    }
  });

  roomRef.collection("calleeCandidates").onSnapshot(snapshot => {
    snapshot.docChanges().forEach(change => {
      if (change.type === "added") {
        const candidate = new RTCIceCandidate(change.doc.data());
        pc.addIceCandidate(candidate);
      }
    });
  });
};

joinCallBtn.onclick = async () => {
  const roomId = roomIdInput.value.trim();
  const roomRef = firestore.collection("rooms").doc(roomId);
  const roomSnapshot = await roomRef.get();

  if (!roomSnapshot.exists) {
    alert("❌ Room not found.");
    return;
  }

  const offer = roomSnapshot.data().offer;
  await pc.setRemoteDescription(new RTCSessionDescription(offer));

  const answer = await pc.createAnswer();
  await pc.setLocalDescription(answer);
  await roomRef.update({ answer: { type: answer.type, sdp: answer.sdp } });

  pc.onicecandidate = event => {
    if (event.candidate) {
      roomRef.collection("calleeCandidates").add(event.candidate.toJSON());
    }
  };

  roomRef.collection("callerCandidates").onSnapshot(snapshot => {
    snapshot.docChanges().forEach(change => {
      if (change.type === "added") {
        const candidate = new RTCIceCandidate(change.doc.data());
        pc.addIceCandidate(candidate);
      }
    });
  });
};
