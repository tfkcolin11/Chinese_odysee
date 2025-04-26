import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service for managing connectivity status
class ConnectivityService {
  /// Stream controller for connectivity status
  final _connectivityController = StreamController<bool>.broadcast();
  
  /// Timer for periodic connectivity checks
  Timer? _connectivityTimer;
  
  /// Whether the device is currently connected to the internet
  bool _isConnected = true;
  
  /// Stream of connectivity status changes
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  /// Whether the device is currently connected to the internet
  bool get isConnected => _isConnected;

  /// Creates a new [ConnectivityService] instance
  ConnectivityService() {
    // Start monitoring connectivity
    _startMonitoring();
  }

  /// Starts monitoring connectivity
  void _startMonitoring() {
    // Check connectivity immediately
    _checkConnectivity();
    
    // Set up periodic checks
    _connectivityTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnectivity(),
    );
  }

  /// Checks the current connectivity status
  Future<void> _checkConnectivity() async {
    try {
      final result = await _isInternetAvailable();
      
      // Only notify listeners if the status has changed
      if (result != _isConnected) {
        _isConnected = result;
        _connectivityController.add(_isConnected);
      }
    } catch (e) {
      // If there's an error checking connectivity, assume we're offline
      if (_isConnected) {
        _isConnected = false;
        _connectivityController.add(false);
      }
    }
  }

  /// Checks if the internet is available
  Future<bool> _isInternetAvailable() async {
    try {
      // Try to connect to a reliable server
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Forces a connectivity check
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return _isConnected;
  }

  /// Disposes of the service
  void dispose() {
    _connectivityTimer?.cancel();
    _connectivityController.close();
  }
}
