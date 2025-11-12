import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Map<String, String> _memoryCache = {};
  static const int _maxCacheSize = 10;
  static const int _maxImageSizeKB = 500;

  Future<String?> imageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final sizeKB = bytes.length / 1024;
      if (sizeKB > _maxImageSizeKB) {}

      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  Image? base64ToImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    try {
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } catch (e) {
      return null;
    }
  }

  Image? getCachedImage(String userId, String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;

    if (_memoryCache.containsKey(userId)) {
      return base64ToImage(_memoryCache[userId]);
    }

    if (_memoryCache.length >= _maxCacheSize) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[userId] = base64String;

    return base64ToImage(base64String);
  }

  void clearUserCache(String userId) {
    _memoryCache.remove(userId);
  }

  void clearAllCache() {
    _memoryCache.clear();
  }

  Future<String?> saveToLocalFile(String base64String, String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/profile_$userId.jpg');

      final bytes = base64Decode(base64String);
      await file.writeAsBytes(bytes);

      return file.path;
    } catch (e) {
      return null;
    }
  }

  Future<String?> loadFromLocalFile(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/profile_$userId.jpg');

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return base64Encode(bytes);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteLocalFile(String userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/profile_$userId.jpg');

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      return;
    }
  }

  int getImageSizeKB(String base64String) {
    return base64Decode(base64String).length ~/ 1024;
  }
}
