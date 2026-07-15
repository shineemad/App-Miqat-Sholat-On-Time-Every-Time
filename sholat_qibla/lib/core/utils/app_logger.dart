import 'dart:developer' as developer;

/// Tingkat keparahan log.
enum LogLevel { debug, info, warning, error }

/// Logger global aplikasi.
///
/// PRIVASI: log hanya ke konsol lokal (dev tools). Tidak ada data yang
/// dikirim ke server mana pun — aplikasi bersifat offline-first.
class AppLogger {
  AppLogger({this.minLevel = LogLevel.debug, List<LogRecord>? sink})
      : _records = sink ?? <LogRecord>[];

  /// Level minimum yang dicatat.
  final LogLevel minLevel;

  final List<LogRecord> _records;

  /// Riwayat log dalam memori (untuk diagnosa/tampilan debug, tidak dikirim).
  List<LogRecord> get records => List.unmodifiable(_records);

  void debug(String message, {String? tag}) =>
      _log(LogLevel.debug, message, tag: tag);

  void info(String message, {String? tag}) =>
      _log(LogLevel.info, message, tag: tag);

  void warning(String message, {String? tag}) =>
      _log(LogLevel.warning, message, tag: tag);

  /// Mencatat error beserta stack trace (lokal saja).
  void error(String message,
          {Object? error, StackTrace? stackTrace, String? tag}) =>
      _log(LogLevel.error, message,
          tag: tag, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < minLevel.index) return;
    final record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      time: DateTime.now(),
    );
    _records.add(record);
    developer.log(
      message,
      name: tag ?? 'MU-Qibla',
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _severity(LogLevel level) => switch (level) {
        LogLevel.debug => 500,
        LogLevel.info => 800,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      };
}

/// Satu entri log.
class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    required this.time,
    this.tag,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String message;
  final DateTime time;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
}
