import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    return 'http://127.0.0.1:5000/api/v1';
  }
  static const Duration timeout = Duration(seconds: 30);
}
