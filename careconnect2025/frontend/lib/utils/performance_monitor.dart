import 'dart:async';
import 'dart:developer' as developer;

class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  static final Map<String, List<int>> _metrics = {};
  static bool _isEnabled = false;

  // Enable performance monitoring
  static void enable() {
    _isEnabled = true;
    developer.log('Performance monitoring enabled', name: 'PerformanceMonitor');
  }

  // Disable performance monitoring
  static void disable() {
    _isEnabled = false;
    _stopwatches.clear();
    _metrics.clear();
    developer.log(
      'Performance monitoring disabled',
      name: 'PerformanceMonitor',
    );
  }

  // Start timing an operation
  static void startTimer(String operation) {
    if (!_isEnabled) return;

    _stopwatches[operation] = Stopwatch()..start();
  }

  // Stop timing an operation and record the result
  static void stopTimer(String operation) {
    if (!_isEnabled) return;

    final stopwatch = _stopwatches[operation];
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      if (!_metrics.containsKey(operation)) {
        _metrics[operation] = [];
      }
      _metrics[operation]!.add(duration);

      developer.log(
        'Operation "$operation" took ${duration}ms',
        name: 'PerformanceMonitor',
      );

      _stopwatches.remove(operation);
    }
  }

  // Get average time for an operation
  static double getAverageTime(String operation) {
    if (!_metrics.containsKey(operation)) return 0.0;

    final times = _metrics[operation]!;
    if (times.isEmpty) return 0.0;

    return times.reduce((a, b) => a + b) / times.length;
  }

  // Get performance summary
  static Map<String, dynamic> getSummary() {
    if (!_isEnabled) return {};

    final summary = <String, dynamic>{};

    for (final operation in _metrics.keys) {
      final times = _metrics[operation]!;
      if (times.isNotEmpty) {
        summary[operation] = {
          'count': times.length,
          'average': getAverageTime(operation),
          'min': times.reduce((a, b) => a < b ? a : b),
          'max': times.reduce((a, b) => a > b ? a : b),
          'total': times.reduce((a, b) => a + b),
        };
      }
    }

    return summary;
  }

  // Print performance report
  static void printReport() {
    if (!_isEnabled) return;

    final summary = getSummary();
    developer.log('=== Performance Report ===', name: 'PerformanceMonitor');

    for (final operation in summary.keys) {
      final stats = summary[operation];
      developer.log(
        '$operation: ${stats['count']} calls, avg: ${stats['average'].toStringAsFixed(2)}ms, min: ${stats['min']}ms, max: ${stats['max']}ms',
        name: 'PerformanceMonitor',
      );
    }

    developer.log('=== End Report ===', name: 'PerformanceMonitor');
  }

  // Clear all metrics
  static void clearMetrics() {
    _metrics.clear();
    _stopwatches.clear();
    developer.log('Performance metrics cleared', name: 'PerformanceMonitor');
  }

  // Measure execution time of a function
  static Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    if (!_isEnabled) return await function();

    startTimer(operation);
    try {
      final result = await function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      rethrow;
    }
  }

  // Measure execution time of a synchronous function
  static T measureSync<T>(String operation, T Function() function) {
    if (!_isEnabled) return function();

    startTimer(operation);
    try {
      final result = function();
      stopTimer(operation);
      return result;
    } catch (e) {
      stopTimer(operation);
      rethrow;
    }
  }
}
