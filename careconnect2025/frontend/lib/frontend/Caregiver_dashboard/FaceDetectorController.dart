import 'package:google_ml_kit/google_ml_kit.dart';

class FaceModel {
  final double? smile;
  final double? leftEyeOpen;
  final double? rightEyeOpen;

  FaceModel({this.smile, this.leftEyeOpen, this.rightEyeOpen});
}

class FaceDetectorController {
  final FaceDetector _faceDetector = GoogleMlKit.vision.faceDetector(
    FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
    ),
  );

  Future<List<FaceModel>> detectEmotion(InputImage inputImage) async {
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    return faces.map((face) {
      return FaceModel(
        smile: face.smilingProbability,
        leftEyeOpen: face.leftEyeOpenProbability,
        rightEyeOpen: face.rightEyeOpenProbability,
      );
    }).toList();
  }

  void dispose() {
    _faceDetector.close();
  }
}
