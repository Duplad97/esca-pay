class DebugLogService {
  static final DebugLogService _instance = DebugLogService._internal();
  factory DebugLogService() => _instance;
  DebugLogService._internal();

  static const int _maxLogs = 500;
  final List<String> _logs = [];

  /// Capture a log message
  void log(String message) {
    final timestamp = DateTime.now();
    final formattedTime =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    final logEntry = '[$formattedTime] $message';

    _logs.add(logEntry);

    // Keep only the most recent logs
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
  }

  /// Get all captured logs
  List<String> getLogs() => List.from(_logs);

  /// Get the last N logs
  List<String> getRecentLogs({int count = 100}) {
    final start = (_logs.length - count).clamp(0, _logs.length);
    return _logs.sublist(start);
  }

  /// Clear all logs
  void clear() {
    _logs.clear();
  }
}

final debugLog = DebugLogService();
