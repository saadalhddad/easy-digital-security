import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

class CustomAssetLoader {
  static Future<String?> getAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      debugPrint('Error loading asset $path: $e');
      return null;
    }
  }
}