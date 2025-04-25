/// Simple logger utility
class Logger {
  /// Log an info message
  static void info(String message) {
    // In a real app, you would use a proper logging framework
    // For now, we'll just use print in debug mode
    // ignore: avoid_print
    print('INFO: $message');
  }

  /// Log an error message
  static void error(String message, [dynamic error]) {
    // ignore: avoid_print
    print('ERROR: $message${error != null ? ' - $error' : ''}');
  }

  /// Log a warning message
  static void warning(String message) {
    // ignore: avoid_print
    print('WARNING: $message');
  }
}
