/// Log levels ordered from least to most severe.
enum LogLevel {
  /// Diagnostic details useful during development.
  debug,

  /// General information about application behavior.
  info,

  /// An unexpected condition that does not stop the operation.
  warning,

  /// A failure that prevented an operation from completing.
  error,
}

/// Receives formatted log lines.
typedef LogSink = void Function(String line);

/// Logging contract shared by application logger implementations.
// An interface leaves room for methods like flush() later.
// ignore: one_member_abstracts
abstract interface class AppLogger {
  /// Writes a message and any associated error details.
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Convenience methods for writing messages at specific levels.
extension AppLoggerShorthands on AppLogger {
  /// Writes a debug message.
  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  /// Writes an informational message.
  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  /// Writes a warning message.
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  /// Writes an error message.
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);
}

/// Logs formatted messages to a configurable sink.
class ConsoleLogger implements AppLogger {
  /// Creates a logger that emits [minLevel] and more severe messages.
  ConsoleLogger({required this.minLevel, LogSink? sink})
    : _sink = sink ?? _defaultSink;

  /// The least severe level this logger emits.
  final LogLevel minLevel;

  final LogSink _sink;

  @override
  void log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Enum order represents severity, so changing it also changes filtering.
    if (level.index < minLevel.index) return;

    final line = StringBuffer()
      ..write('[${level.name.toUpperCase()}] ')
      ..write(message);

    if (error != null) {
      line
        ..write(' | ')
        ..write(error);
    }
    if (stackTrace != null) {
      line
        ..write('\n')
        ..write(stackTrace);
    }

    _sink(line.toString());
  }
}

void _defaultSink(String line) {
  // print works on Flutter web, where dart:io is unavailable.
  // ignore: avoid_print
  print(line);
}
