/*// Emoji mapping for various emotions
const emojiMap = {
  happy: "😄",
  sad: "☹️",
  neutral: "😐",
  angry: "😠",
  surprised: "😲",
  disgusted: "🤢",
  fearful: "😨"
};

// Function to load face-api.js models
async function loadModels() {
  console.log("Loading models...");
  try {
    // Load face detection and expression models from CDN
    await faceapi.nets.tinyFaceDetector.loadFromUri("https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/");
    await faceapi.nets.faceExpressionNet.loadFromUri("https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/");
    console.log("Models loaded.");
  } catch (err) {
    console.error("Error loading models:", err);
  }
}

// Function to start emotion detection loop
async function startEmotionLoop(video) {
  console.log("Starting emotion detection loop...");

  // Remove any previous canvas to avoid drawing over
  const oldCanvas = document.querySelector("canvas");
  if (oldCanvas) oldCanvas.remove();

  // Create a new canvas and append it to the body
  const canvas = faceapi.createCanvasFromMedia(video);
  document.body.appendChild(canvas);

  const displaySize = { width: video.width, height: video.height };
  faceapi.matchDimensions(canvas, displaySize);

  // Ensure the canvas is continuously updated with each frame
  setInterval(async () => {
    // Check if the video is ready for processing
    if (video.readyState !== 4) return;

    // Detect face and expressions from the video frame
    const result = await faceapi
      .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions())
      .withFaceExpressions();

    // If no face detected, return
    if (!result) return;

    // Get the sorted expressions and the most probable emotion
    const sorted = result.expressions.asSortedArray();
    const emotion = sorted[0]?.expression;
    const emoji = emojiMap[emotion] || "😐"; // Default emoji if emotion is not found

    // Clear the previous canvas drawing
    canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);

    // Draw face detections and expressions on the canvas
    faceapi.draw.drawDetections(canvas, [result]);
    faceapi.draw.drawFaceExpressions(canvas, [result]);

    // Display the detected emotion and emoji on the page
    displayEmotionOnScreen(emotion, emoji);

    // Send emotion data (expression and emoji) back to Flutter
    window.postMessage({ emotion, emoji });
  }, 100); // Run every 100ms to process the next frame
}

// Function to display detected emotion and emoji on the screen
function displayEmotionOnScreen(emotion, emoji) {
  // Find or create the element to display the emotion and emoji
  let emotionElement = document.getElementById('emotion-display');
  if (!emotionElement) {
    emotionElement = document.createElement('div');
    emotionElement.id = 'emotion-display';
    emotionElement.style.position = 'absolute';
    emotionElement.style.bottom = '20px';
    emotionElement.style.left = '20px';
    emotionElement.style.fontSize = '30px';
    emotionElement.style.fontWeight = 'bold';
    emotionElement.style.color = '#fff';
    emotionElement.style.backgroundColor = 'rgba(0, 0, 0, 0.6)';
    emotionElement.style.padding = '10px';
    emotionElement.style.borderRadius = '10px';
    document.body.appendChild(emotionElement);
  }

  // Update the emotion display
  emotionElement.innerText = `${emoji} ${emotion.charAt(0).toUpperCase() + emotion.slice(1)}`;
}

// Function to rebind emotion detection when the Jitsi video element is available
window.rebindEmotionDetection = function() {
  const jitsiVideo = document.querySelector('#jitsi-container video');
  if (jitsiVideo) {
    startEmotionLoop(jitsiVideo); // Start the emotion loop on the Jitsi video
  } else {
    console.warn("No Jitsi video found for rebinding.");
  }
};

// Start the video stream and emotion detection when the window is loaded
window.addEventListener('load', async () => {
  // Load models before starting video feed
  await loadModels();

  const video = document.getElementById("emotion-video");
  if (video) {
    console.log("Starting video feed...");

    // Get the user's webcam stream and set it as the video source
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    video.srcObject = stream;

    // Play the video once the metadata is loaded
    video.onloadedmetadata = () => {
      video.play();
      startEmotionLoop(video); // Start emotion loop with the video
    };
  } else {
    console.error("Video element not found!");
  }
});
*/

// Emoji mapping for various emotions
const emojiMap = {
  happy: "😄",
  sad: "☹️",
  neutral: "😐",
  angry: "😠",
  surprised: "😲",
  disgusted: "🤢",
  fearful: "😨"
};

// Function to load face-api.js models
async function loadModels() {
  console.log("Loading models...");
  try {
    // Load face detection and expression models from CDN
    await faceapi.nets.tinyFaceDetector.loadFromUri("https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/");
    await faceapi.nets.faceExpressionNet.loadFromUri("https://cdn.jsdelivr.net/npm/@vladmandic/face-api/model/");
    console.log("Models loaded.");
  } catch (err) {
    console.error("Error loading models:", err);
  }
}

// Function to start emotion detection loop
async function startEmotionLoop(video) {
  console.log("Starting emotion detection loop...");

  // Remove any previous canvas to avoid drawing over
  const oldCanvas = document.querySelector("canvas");
  if (oldCanvas) oldCanvas.remove();

  // Create a new canvas and append it to the body
  const canvas = faceapi.createCanvasFromMedia(video);
  document.body.appendChild(canvas);

  const displaySize = { width: video.width, height: video.height };
  faceapi.matchDimensions(canvas, displaySize);

  setInterval(async () => {
    // Check if the video is ready for processing
    if (video.readyState !== 4) return;

    // Detect face and expressions from the video frame
    const result = await faceapi
      .detectSingleFace(video, new faceapi.TinyFaceDetectorOptions())
      .withFaceExpressions();

    // If no face detected, return
    if (!result) return;

    // Get the sorted expressions and the most probable emotion
    const sorted = result.expressions.asSortedArray();
    const emotion = sorted[0]?.expression;
    const emoji = emojiMap[emotion] || "😐"; // Default emoji if emotion is not found

    // Clear the previous canvas drawing (so we don't draw the bounding box)
    canvas.getContext('2d').clearRect(0, 0, canvas.width, canvas.height);

    // Don't draw the face detections and expressions (remove bounding box and score)
    // faceapi.draw.drawDetections(canvas, [result]);
    // faceapi.draw.drawFaceExpressions(canvas, [result]);

    // Send emotion data (expression and emoji) back to Flutter
    window.postMessage({ emotion, emoji });
  }, 100); // Run every 100ms to process the next frame
}

// Function to rebind emotion detection when the Jitsi video element is available
window.rebindEmotionDetection = function() {
  const jitsiVideo = document.querySelector('#jitsi-container video');
  if (jitsiVideo) {
    startEmotionLoop(jitsiVideo); // Start the emotion loop on the Jitsi video
  } else {
    console.warn("No Jitsi video found for rebinding.");
  }
};

// Start the video stream and emotion detection when the window is loaded
window.addEventListener('load', async () => {
  // Load models before starting video feed
  await loadModels();

  const video = document.getElementById("emotion-video");
  if (video) {
    console.log("Starting video feed...");

    // Get the user's webcam stream and set it as the video source
    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
    video.srcObject = stream;

    // Play the video once the metadata is loaded
    video.onloadedmetadata = () => {
      video.play();
      startEmotionLoop(video); // Start emotion loop with the video
    };
  } else {
    console.error("Video element not found!");
  }
});
