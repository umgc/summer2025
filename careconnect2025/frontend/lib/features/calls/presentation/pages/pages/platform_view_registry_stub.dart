// Stub fallback for non-web platforms
class FakePlatformViewRegistry {
  void registerViewFactory(String viewTypeId, dynamic Function(int) viewFactory) {
    throw UnsupportedError("platformViewRegistry is not available on this platform.");
  }
}

final platformViewRegistry = FakePlatformViewRegistry();
