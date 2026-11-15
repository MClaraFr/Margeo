import 'package:flutter/foundation.dart';

abstract final class ApiConstants {
  static String get baseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8183/api';
    }

    return 'http://localhost:8183/api';
  }
}
