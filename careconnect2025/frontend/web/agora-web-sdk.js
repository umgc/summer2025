// Agora Web SDK integration for CareConnect video calls
// This script should be loaded in the HTML head section

// Initialize Agora Web SDK
let agoraClient = null;
let localTracks = {
  videoTrack: null,
  audioTrack: null
};
let remoteUsers = {};

// Agora configuration
const AGORA_CONFIG = {
  appId: "6dd0e8e31625434e8dd185bcb075cd79", // Your Agora App ID
  mode: "rtc",
  codec: "vp8"
};

// Initialize Agora client
function initializeAgoraWeb() {
  if (typeof AgoraRTC !== 'undefined') {
    agoraClient = AgoraRTC.createClient(AGORA_CONFIG);
    
    // Handle remote user events
    agoraClient.on("user-published", handleUserPublished);
    agoraClient.on("user-unpublished", handleUserUnpublished);
    agoraClient.on("user-left", handleUserLeft);
    
    console.log("✅ Agora Web SDK initialized");
    return true;
  } else {
    console.error("❌ Agora Web SDK not loaded");
    return false;
  }
}

// Join a video call channel
async function joinAgoraChannel(channelName, userId, token = null) {
  try {
    if (!agoraClient) {
      if (!initializeAgoraWeb()) {
        throw new Error("Failed to initialize Agora");
      }
    }
    
    // Join the channel
    await agoraClient.join(AGORA_CONFIG.appId, channelName, token, userId);
    console.log(`✅ Joined channel: ${channelName} as user: ${userId}`);
    
    // Create and publish local tracks
    await createAndPublishLocalTracks(true, true); // video=true, audio=true
    
    return true;
  } catch (error) {
    console.error("❌ Failed to join channel:", error);
    throw error;
  }
}

// Create and publish local video/audio tracks
async function createAndPublishLocalTracks(enableVideo = true, enableAudio = true) {
  try {
    const tracks = [];
    
    if (enableVideo) {
      localTracks.videoTrack = await AgoraRTC.createCameraVideoTrack();
      tracks.push(localTracks.videoTrack);
    }
    
    if (enableAudio) {
      localTracks.audioTrack = await AgoraRTC.createMicrophoneAudioTrack();
      tracks.push(localTracks.audioTrack);
    }
    
    // Publish tracks to the channel
    if (tracks.length > 0) {
      await agoraClient.publish(tracks);
      console.log("✅ Published local tracks");
    }
    
    // Play local video track
    if (localTracks.videoTrack) {
      playLocalVideo();
    }
    
    return true;
  } catch (error) {
    console.error("❌ Failed to create local tracks:", error);
    throw error;
  }
}

// Play local video in the specified container
function playLocalVideo(containerId = 'local-video') {
  if (localTracks.videoTrack) {
    const container = document.getElementById(containerId);
    if (container) {
      localTracks.videoTrack.play(container);
      console.log("✅ Playing local video");
    }
  }
}

// Handle when a remote user publishes their tracks
async function handleUserPublished(user, mediaType) {
  const userId = user.uid;
  
  // Subscribe to the remote user
  await agoraClient.subscribe(user, mediaType);
  console.log(`✅ Subscribed to user ${userId} for ${mediaType}`);
  
  if (!remoteUsers[userId]) {
    remoteUsers[userId] = user;
  }
  
  if (mediaType === 'video') {
    // Play remote video
    const remoteVideoContainer = document.getElementById(`remote-video-${userId}`) || 
                                 document.getElementById('remote-video');
    if (remoteVideoContainer && user.videoTrack) {
      user.videoTrack.play(remoteVideoContainer);
      console.log(`✅ Playing remote video for user ${userId}`);
    }
  }
  
  if (mediaType === 'audio' && user.audioTrack) {
    user.audioTrack.play();
    console.log(`✅ Playing remote audio for user ${userId}`);
  }
}

// Handle when a remote user unpublishes their tracks
function handleUserUnpublished(user, mediaType) {
  console.log(`User ${user.uid} unpublished ${mediaType}`);
}

// Handle when a remote user leaves
function handleUserLeft(user) {
  const userId = user.uid;
  console.log(`User ${userId} left the channel`);
  
  // Clean up remote user
  if (remoteUsers[userId]) {
    delete remoteUsers[userId];
  }
  
  // Remove remote video container
  const remoteContainer = document.getElementById(`remote-video-${userId}`);
  if (remoteContainer) {
    remoteContainer.innerHTML = '';
  }
}

// Toggle local video on/off
async function toggleLocalVideo() {
  if (localTracks.videoTrack) {
    const enabled = localTracks.videoTrack.enabled;
    await localTracks.videoTrack.setEnabled(!enabled);
    console.log(`📹 Video ${!enabled ? 'enabled' : 'disabled'}`);
    return !enabled;
  }
  return false;
}

// Toggle local audio on/off
async function toggleLocalAudio() {
  if (localTracks.audioTrack) {
    const enabled = localTracks.audioTrack.enabled;
    await localTracks.audioTrack.setEnabled(!enabled);
    console.log(`🎤 Audio ${!enabled ? 'enabled' : 'disabled'}`);
    return !enabled;
  }
  return false;
}

// Leave the channel and clean up
async function leaveAgoraChannel() {
  try {
    // Stop and close local tracks
    if (localTracks.videoTrack) {
      localTracks.videoTrack.stop();
      localTracks.videoTrack.close();
      localTracks.videoTrack = null;
    }
    
    if (localTracks.audioTrack) {
      localTracks.audioTrack.stop();
      localTracks.audioTrack.close();
      localTracks.audioTrack = null;
    }
    
    // Clear remote users
    remoteUsers = {};
    
    // Leave the channel
    if (agoraClient) {
      await agoraClient.leave();
      console.log("✅ Left the channel");
    }
    
    return true;
  } catch (error) {
    console.error("❌ Failed to leave channel:", error);
    throw error;
  }
}

// Check if Agora Web SDK is available
function isAgoraWebAvailable() {
  return typeof AgoraRTC !== 'undefined';
}

// Expose functions to Flutter web
window.AgoraCareConnect = {
  initialize: initializeAgoraWeb,
  join: joinAgoraChannel,
  leave: leaveAgoraChannel,
  toggleVideo: toggleLocalVideo,
  toggleAudio: toggleLocalAudio,
  isAvailable: isAgoraWebAvailable
};

console.log("🌐 Agora CareConnect Web SDK loaded");
