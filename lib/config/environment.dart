import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static bool get isProduction => kReleaseMode;
  static bool get isDevelopment => kDebugMode;
  static bool get isProfile => kProfileMode;

  static List<String> get backendBaseUrls {
    final urls = <String>{};
    final envList = dotenv.env['BACKEND_BASE_URLS'];
    if (envList != null && envList.isNotEmpty) {
      urls.addAll(
        envList
            .split(',')
            .map((url) => url.trim())
            .where((url) => url.isNotEmpty),
      );
    }

    final single = dotenv.env['BACKEND_BASE_URL'];
    if (single != null && single.isNotEmpty) {
      urls.add(single.trim());
    }

    if (urls.isEmpty) {
      if (kIsWeb) {
        urls.add('http://localhost:4000');
      } else if (Platform.isAndroid) {
        urls
          ..add('http://10.0.2.2:4000')
          ..add('http://127.0.0.1:4000');
      } else {
        urls.add('http://localhost:4000');
      }
    }

    urls.addAll({
      'http://10.0.2.2:4000',
      'http://127.0.0.1:4000',
      'http://localhost:4000',
    });

    return urls.toList();
  }

  static String get backendBaseUrl => backendBaseUrls.first;

  static Future<void> load() async {
    try {
      print('🔧 Environment: Loading .env file...');
      await dotenv.load(fileName: '.env');
      print('✅ Environment: .env loaded successfully');
      print('📄 Environment: BACKEND_BASE_URLS from .env: ${dotenv.env['BACKEND_BASE_URLS']}');
    } catch (e) {
      print('⚠️ Environment: .env file not found, using defaults');
    }
    print('📡 Build Mode: ${isProduction ? 'PRODUCTION' : isDevelopment ? 'DEVELOPMENT' : 'PROFILE'}');
    print('🔗 Backend URL candidates: ${backendBaseUrls.join(', ')}');
  }
}
