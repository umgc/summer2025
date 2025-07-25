class EnvironmentConfig {
  // Agora Configuration for REAL video calls - YOUR ACTUAL APP ID
  static const String agoraAppId =
      '6dd0e8e31625434e8dd185bcb075cd79'; // Your actual Agora App ID
  static const String agoraAppCertificate = ''; // Optional for development

  // ZEGOCLOUD Configuration (keeping for reference)
  static const String zegoAppId = '2105161523';
  static const String zegoAppSign =
      '5d73c86a6c4a87100e6e7de2c753f2306c16454001e4543cc6db511e1bbc3a15';
  static const String zegoCallbackSecret = '5d73c86a6c4a87100e6e7de2c753f230';
  static const String zegoServerSecret = '9af0e457cc6a1991c3ee71e4ac56b7bb';
  static const String zegoServerUrl =
      'wss://webliveroom2105161523-api.coolzcloud.com/ws';

  // Firebase Configuration - Updated with actual project values
  static const String firebaseProjectId = 'careconnectptdemo';
  static const String firebaseApiKeyIOS =
      'AIzaSyDSZfDwvL4ZYRkEddUyP4adRyvnEMvRvvQ';
  static const String firebaseApiKeyAndroid =
      'AIzaSyBN7XCaESMDhKwjHQQt8UKQ4-wm4jgP2Sg';
  static const String firebaseMessagingSenderId = '1070028273529';
  static const String firebaseAppIdIOS =
      '1:1070028273529:ios:d88c7e7069e88454ffa1a8';
  static const String firebaseAppIdAndroid =
      '1:1070028273529:android:8ecaa6c5160ab941ffa1a8';
  static const String firebaseStorageBucket =
      'careconnectptdemo.firebasestorage.app';
  static const String firebaseSenderId = '1070028273529';
  static const String firebaseServiceAccount =
      'firebase-adminsdk-fbsvc@careconnectptdemo.iam.gserviceaccount.com';

  // Firebase Service Account JSON Key - Updated for careconnectptdemo
  static const Map<String, dynamic> firebaseServiceAccountKey = {
    "type": "service_account",
    "project_id": "careconnectptdemo",
    "private_key_id": "demo_key_id_for_careconnectptdemo",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\n[Replace with your actual private key from Firebase service account]\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-fbsvc@careconnectptdemo.iam.gserviceaccount.com",
    "client_id": "1070028273529",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40careconnectptdemo.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };
}
