import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

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
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<bool> restoreSession() async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) return false;

    try {
      await apiClient.get("/auth/me");
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String platform,
  }) async {
    await apiClient.post(
      "/auth/register",
      data: {
        "name": name,
        "email": email,
        "password": password,
        "role": getRoleString(role),
        "platform": platform,
      },
    );
  }

  Future<String> login(String email, String password) async {
    final response = await apiClient.post(
      "/auth/login",
      data: {"email": email, "password": password, "platform": "MOBILE"},
    );

    final data = response.data;

    if (data == null || data["user"] == null) {
      throw Exception("Invalid login response structure");
    }

    final accessToken = data["accessToken"];
    final user = data["user"];
    final role = user["role"];
    await TokenStorage.saveAccessToken(accessToken);
    await TokenStorage.saveUser(user);

    return role;
  }

  Future<void> logout(PersistCookieJar cookieJar) async {
    try {
      await apiClient.post("/auth/logout");
    } catch (e) {
      debugPrint("Logout API error: $e");
    } finally {
      await TokenStorage.clearTokens();
      await cookieJar.deleteAll();
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await apiClient.get("/profile");
      final profileData = response.data;

      if (profileData != null && profileData['user'] != null) {
        final existingUser = await TokenStorage.getUser();
        final updatedUser = {...?existingUser, ...profileData['user']};
        await TokenStorage.saveUser(updatedUser);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch user profile: $e");
      }
    }
  }

  Future<String> VerifyEmail(String token) async {
    try {
      final response = await apiClient.get("/auth/verify/$token");
      final result;

      if (response.statusCode == 200) {
        result = response.data['message'] ?? "Email verified successfully";
        return result;
      }
      throw Exception(
        "Verification failed with status: ${response.statusCode}",
      );
    } catch (e) {
      if (kDebugMode) {
        print("Failed to verify email: $e");
      }
      throw Exception("Failed to verify email");
    }
  }
}
