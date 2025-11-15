// ignore_for_file: deprecated_member_use

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SosService {
  static const platform = MethodChannel('com.example.hopin/sos');

  Future<bool> checkPermissions() async {
    try {
      final nativePermissions = await platform.invokeMethod('checkPermissions');

      final locationPermission = await Permission.location.isGranted;

      return nativePermissions && locationPermission;
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      final locationStatus = await Permission.location.request();

      await platform.invokeMethod('requestPermissions');

      await Future.delayed(const Duration(milliseconds: 500));

      return await checkPermissions();
    } catch (e) {
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await Permission.location.isGranted;

      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      await platform.invokeMethod('sendSMS', {
        'number': phoneNumber,
        'message': message,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendBulkSMS({
    required List<Map<String, dynamic>> contacts,
    required String message,
  }) async {
    try {
      await platform.invokeMethod('sendBulkSMS', {
        'contacts': contacts,
        'message': message,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> makeCall(String phoneNumber) async {
    try {
      await platform.invokeMethod('makeCall', {'number': phoneNumber});
      return true;
    } catch (e) {
      return false;
    }
  }

  String createSosMessage({
    required String userName,
    Position? location,
    String? additionalInfo,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('🚨 EMERGENCY ALERT - HopIn SOS 🚨');
    buffer.writeln('');
    buffer.writeln('$userName needs immediate help!');
    buffer.writeln('');

    if (location != null) {
      buffer.writeln('📍 Current Location:');
      buffer.writeln('Latitude: ${location.latitude.toStringAsFixed(6)}');
      buffer.writeln('Longitude: ${location.longitude.toStringAsFixed(6)}');
      buffer.writeln('');
      buffer.writeln('Google Maps Link:');
      buffer.writeln(
        'https://maps.google.com/?q=${location.latitude},${location.longitude}',
      );
      buffer.writeln('');
      buffer.writeln('Accuracy: ${location.accuracy.toStringAsFixed(1)}m');
      buffer.writeln('Time: ${DateTime.now().toString()}');
    } else {
      buffer.writeln('⚠️ Location unavailable');
    }

    if (additionalInfo != null && additionalInfo.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Additional Info: $additionalInfo');
    }

    buffer.writeln('');
    buffer.writeln('Please respond immediately!');

    return buffer.toString();
  }

  Future<Map<String, dynamic>> triggerSOS({
    required String userName,
    required List<Map<String, dynamic>> emergencyContacts,
    bool includeLocation = true,
    String? additionalInfo,
  }) async {
    try {
      final hasPermissions = await checkPermissions();
      if (!hasPermissions) {
        return {'success': false, 'error': 'Required permissions not granted'};
      }

      Position? location;
      if (includeLocation) {
        location = await getCurrentLocation();
      }

      final message = createSosMessage(
        userName: userName,
        location: location,
        additionalInfo: additionalInfo,
      );

      final smsSuccess = await sendBulkSMS(
        contacts: emergencyContacts,
        message: message,
      );

      return {
        'success': smsSuccess,
        'location': location != null
            ? {
                'latitude': location.latitude,
                'longitude': location.longitude,
                'accuracy': location.accuracy,
              }
            : null,
        'contactsNotified': emergencyContacts.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
