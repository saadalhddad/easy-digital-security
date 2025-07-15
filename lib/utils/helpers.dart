import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class CustomAssetLoader {
  static Future<String?> getAsset(String path) async {
    try {
      return await DefaultAssetBundle.of(rootBundle as BuildContext).loadString(path);
    } catch (e) {
      debugPrint('Error loading asset $path: $e');
      return null;
    }
  }
}