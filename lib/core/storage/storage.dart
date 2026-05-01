import 'dart:async';
import 'dart:convert';
import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: "accessToken", value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "accessToken");
  }

  static Future<void> saveUser(Map<dynamic, dynamic> user) async {
    final userJson = jsonEncode(user);
    await _storage.write(key: "user", value: userJson);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userString = await _storage.read(key: "user");
    if (userString == null) return null;
    return jsonDecode(userString);
  }

  static Future<void> saveAuthUser(AuthModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: "user", value: userJson);
  }

  static Future<AuthModel?> getAuthUser() async {
    final userString = await _storage.read(key: "user");
    if (userString == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(userString);
      return AuthModel.fromJson(json);
    } catch (_) {
      return null;
    }
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
