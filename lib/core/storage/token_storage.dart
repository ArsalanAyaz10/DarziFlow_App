import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: "accessToken", value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "accessToken");
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final userJson = jsonEncode(user);
    await _storage.write(key: "user", value: userJson);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userString = await _storage.read(key: "user");
    if (userString == null) return null;
    return jsonDecode(userString);
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: "role", value: role);
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: "role");
  }

  static Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
