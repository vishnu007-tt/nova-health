import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Backend Keep-Alive Service
/// Periodically pings the ML backend to prevent it from sleeping (Render free tier)
class BackendKeepAliveService {
  static final BackendKeepAliveService _instance = BackendKeepAliveService._internal();
  factory BackendKeepAliveService() => _instance;
  BackendKeepAliveService._internal();

  static const String _backendUrl = 'https://novahealth-backend.onrender.com';
  static const Duration _pingInterval = Duration(minutes: 10); // Ping every 10 minutes

  Timer? _keepAliveTimer;
  bool _isRunning = false;
  DateTime? _lastPingTime;
  bool _backendAwake = false;

  /// Start the keep-alive service
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    debugPrint('🔄 Backend Keep-Alive Service started');

    // Initial ping to wake up the backend
    _pingBackend();

    // Set up periodic pings
    _keepAliveTimer = Timer.periodic(_pingInterval, (_) {
      _pingBackend();
    });
  }

  /// Stop the keep-alive service
  void stop() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
    _isRunning = false;
    debugPrint('⏹️ Backend Keep-Alive Service stopped');
  }

  /// Check if service is running
  bool get isRunning => _isRunning;

  /// Check if backend is awake
  bool get isBackendAwake => _backendAwake;

  /// Get last ping time
  DateTime? get lastPingTime => _lastPingTime;

  /// Manually ping the backend (useful for checking status)
  Future<bool> pingNow() async {
    return await _pingBackend();
  }

  /// Internal ping method
  Future<bool> _pingBackend() async {
    try {
      debugPrint('🏓 Pinging ML backend to keep alive...');

      final response = await http.get(
        Uri.parse('$_backendUrl/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      _lastPingTime = DateTime.now();

      if (response.statusCode == 200) {
        _backendAwake = true;
        debugPrint('✅ ML Backend is awake (${response.statusCode})');
        return true;
      } else {
        _backendAwake = false;
        debugPrint('⚠️ ML Backend responded with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _backendAwake = false;
      debugPrint('❌ Failed to ping ML backend: $e');
      return false;
    }
  }

  /// Get service status as a map
  Map<String, dynamic> getStatus() {
    return {
      'isRunning': _isRunning,
      'isBackendAwake': _backendAwake,
      'lastPingTime': _lastPingTime?.toIso8601String(),
      'pingInterval': '${_pingInterval.inMinutes} minutes',
      'backendUrl': _backendUrl,
    };
  }
}
