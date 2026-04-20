import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../../core/storage/storage.dart';
import 'dart:developer' as dev;

enum UserRole { qcMember, client, departmenthead }

String getRoleString(UserRole role) {
  switch (role) {
    case UserRole.qcMember:
      return "QC_MEMBER";
    case UserRole.client:
      return "CLIENT";
    case UserRole.departmenthead:
      return "DEPARTMENT_HEAD";
  }
}

class AuthRepository {
  final AuthService authService;

  AuthRepository({required this.authService});

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await authService.register(
      name: name,
      email: email,
      password: password,
      role: getRoleString(role),
    );
  }

  Future<AuthModel> login(String email, String password) async {
    try {
      final response = await authService.login(email: email, password: password);
      final data = response.data;
      if (kDebugMode) {
        dev.log("Login API Response: $data");
      }

      if (data == null || data["user"] == null) {
        throw Exception("Invalid login response structure");
      }

      final accessToken = data["accessToken"];
      final authUser =
          AuthModel.fromJson(Map<String, dynamic>.from(data["user"]));

      await AppStorage.saveAccessToken(accessToken);
      await AppStorage.saveAuthUser(authUser);
      await AppStorage.saveUserRole(authUser.role);

      return authUser;
    } on DioException catch (e) {
      if (kDebugMode) {
        dev.log("Login Error (Dio): ${e.response?.statusCode} - ${e.response?.data}");
        print("LOGIN ERROR: ${e.response?.data}");
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        dev.log("Login Error: $e");
      }
      rethrow;
    }
  }

  Future<void> logout(PersistCookieJar cookieJar) async {
    try {
      await authService.logout();
    } catch (e) {
      dev.log("Logout API error: $e");
    } finally {
      await AppStorage.clearTokens();
      await cookieJar.deleteAll();
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await authService.getProfile();
      final profileData = response.data;

      if (profileData != null && profileData['user'] != null) {
        final freshUser = AuthModel.fromJson(
          Map<String, dynamic>.from(profileData['user']),
        );
        final existing = await AppStorage.getAuthUser();
        if (existing != null) {
          await AppStorage.saveAuthUser(freshUser.copyWith(
            department: freshUser.department ?? existing.department,
          ));
        } else {
          await AppStorage.saveAuthUser(freshUser);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        dev.log("Failed to fetch user profile: $e");
      }
    }
  }

  Future<String> verifyEmail(String token) async {
    try {
      final response = await authService.verifyEmail(token);

      if (response.statusCode == 200) {
        return response.data['message'] ?? "Email verified successfully";
      }
      throw Exception(
        "Verification failed with status: ${response.statusCode}",
      );
    } catch (e) {
      if (kDebugMode) dev.log("Failed to verify email: $e");
      throw Exception("Failed to verify email");
    }
  }
}
