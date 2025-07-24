const emojiMap = {
  happy: "😄", sad: "☹️", neutral: "😐",
  angry: "😠", surprised: "😲", disgusted: "🤢", fearful: "😨"
};

// Load face-api.js models
async function loadModels() {
  console.log("Loading models...");
  try {
    await faceapi.nets.tinyFaceDetector.loadFromUri("https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/");
    await faceapi.nets.faceExpressionNet.loadFromUri("https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/");
    console.log("Models loaded.");
  } catch (err) {
    console.error("Error loading models:", err);
  }
}

// Start the emotion detection loop
async function startEmotionLoop(video) {
  console.log("Starting emotion detection loop...");

  const canvas = faceapi.createCanvasFromMedia(video);
  document.body.appendChild(canvas);

  const displaySize = { width: video.width, height: video.height };
  faceapi.matchDimensions(canvas, displaySize);

  setInterval(async () => {
    if (video.readyState !== 4) return;

    const result = await faceapi
      .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions())
      .withFaceExpressions();

    if (!result) {
      console.log("No face detected!");
      return;
    }

    const sortedExpressions = result.expressions.asSortedArray();
    const emotion = sortedExpressions[0];
    const detectedEmotion = emotion.expression;
    const emoji = emojiMap[detectedEmotion] || "😐";

    console.log(`Detected Emotion: ${detectedEmotion}, Emoji: ${emoji}`);

    // Send emotion data back to Flutter
    window.postMessage({
      emotion: detectedEmotion,
      emoji: emoji
    });
  }, 100);
}

// Start the video stream and emotion detection
window.addEventListener('load', async () => {
  await loadModels();

  const video = document.getElementById("emotion-video");
  if (video) {
    console.log("Starting video feed...");
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    video.srcObject = stream;
    video.onloadedmetadata = () => {
      video.play();
      startEmotionLoop(video);
    };
  } else {
    console.error("Video element not found!");
  }
});
