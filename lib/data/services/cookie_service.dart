// lib/core/services/cookie_service.dart
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CookieService {
  static final CookieService _instance = CookieService._internal();
  factory CookieService() => _instance;
  CookieService._internal();

  PersistCookieJar? _cookieJar;

  Future<PersistCookieJar> get cookieJar async {
    if (_cookieJar == null) {
      await _initCookieJar();
    }
    return _cookieJar!;
  }

  Future<void> _initCookieJar() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _cookieJar = PersistCookieJar(
        storage: FileStorage("${dir.path}/cookies"),
        ignoreExpires: true,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing cookie jar: $e");
      }
      // Fallback to in-memory cookie jar
      _cookieJar = PersistCookieJar();
    }
  }

  Future<void> deleteAllCookies() async {
    try {
      if (_cookieJar != null) {
        await _cookieJar!.deleteAll();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting cookies: $e");
      }
    }
  }
}
