// Custom Flutter bootstrap configuration for CareConnect
// Template variables are replaced during Flutter build process
{{flutter_js}}
{{flutter_build_config}}

// Enhanced Flutter initialization with proper error handling
window.addEventListener('load', function(ev) {
  // Ensure Flutter loader is available
  if (typeof _flutter === 'undefined' || !_flutter.loader) {
    console.error('❌ Flutter loader not available');
    showLoadingError('Flutter loader not found. Please refresh the page.');
    return;
  }

  // Load Flutter entrypoint with optimized configuration
  _flutter.loader.loadEntrypoint({
    serviceWorker: {
      serviceWorkerVersion: "{{flutter_service_worker_version}}",
      timeoutMillis: 3000
    },
    onEntrypointLoaded: function(engineInitializer) {
      // Initialize Flutter engine with auto renderer selection
      engineInitializer.initializeEngine({
        renderer: "auto",
        hostElement: document.querySelector('#flutter-app') || document.body
      }).then(function(appRunner) {
        // Hide loading indicators
        hideLoadingIndicator();
        
        // Start the Flutter application
        appRunner.runApp();
        
        console.log('🎉 CareConnect Flutter app loaded successfully');
      }).catch(function(error) {
        console.error('❌ Flutter engine initialization failed:', error);
        showLoadingError('Failed to initialize application. Please refresh the page.');
      });
    }
  }).catch(function(error) {
    console.error('❌ Failed to load Flutter entrypoint:', error);
    showLoadingError('Failed to load application. Please check your connection and refresh.');
  });
});

// Utility function to hide loading indicators
function hideLoadingIndicator() {
  var loadingSelectors = ['#loading', '#flutter-loading', '.loading', '[data-loading="true"]'];
  
  for (var i = 0; i < loadingSelectors.length; i++) {
    var element = document.querySelector(loadingSelectors[i]);
    if (element) {
      element.style.display = 'none';
      element.style.opacity = '0';
    }
  }
}

// Utility function to display loading errors with CareConnect branding
function showLoadingError(message) {
  var container = document.getElementById('loading') || 
                  document.getElementById('flutter-loading') || 
                  document.body;
  
  if (container) {
    container.innerHTML = 
      '<div style="display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; padding: 20px; background: #f5f5f5; font-family: -apple-system, BlinkMacSystemFont, \'Segoe UI\', Roboto, Arial, sans-serif;">' +
        '<div style="background: white; padding: 40px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); text-align: center; max-width: 400px;">' +
          '<div style="width: 64px; height: 64px; background: #14366E; border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px;">⚠️</div>' +
          '<h2 style="color: #14366E; margin: 0 0 16px 0; font-size: 24px; font-weight: 600;">CareConnect Loading Error</h2>' +
          '<p style="color: #666; margin: 0 0 24px 0; line-height: 1.5; font-size: 16px;">' + message + '</p>' +
          '<button onclick="window.location.reload()" style="background: #14366E; color: white; border: none; padding: 12px 24px; border-radius: 6px; font-size: 16px; font-weight: 500; cursor: pointer; transition: background-color 0.2s;" onmouseover="this.style.backgroundColor=\'#0f2a54\'" onmouseout="this.style.backgroundColor=\'#14366E\'">🔄 Refresh Page</button>' +
        '</div>' +
      '</div>';
  }
}

// Network status monitoring for better user experience
window.addEventListener('offline', function() {
  console.warn('⚠️ Application is offline');
});

window.addEventListener('online', function() {
  console.log('✅ Application is back online');
});
