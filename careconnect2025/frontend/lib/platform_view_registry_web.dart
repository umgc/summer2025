// Web-specific stub for platformViewRegistry compatibility
// This file provides a mock platformViewRegistry for web builds
// to prevent compilation errors with Agora packages

// Mock platformViewRegistry for web builds
class _MockPlatformViewRegistry {
  void registerViewFactory(String viewType, dynamic viewFactory) {
    // No-op for web - Agora won't actually work on web
    print(
      'Mock platformViewRegistry: Ignoring registerViewFactory for $viewType',
    );
  }
}

// Export the mock registry
final platformViewRegistry = _MockPlatformViewRegistry();
