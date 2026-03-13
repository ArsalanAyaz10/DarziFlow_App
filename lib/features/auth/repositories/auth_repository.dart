import 'package:dariziflow_app/features/auth/service/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../../core/storage/storage.dart';


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

  Future<String> login(String email, String password) async {
    final response = await authService.login(email: email, password: password);
    final data = response.data;

    if (data == null || data["user"] == null) {
      throw Exception("Invalid login response structure");
    }

    final accessToken = data["accessToken"];
    final user = data["user"];
    final role = user["role"];

    await AppStorage.saveAccessToken(accessToken);
    await AppStorage.saveUser(user);

    return role;
  }

  Future<void> logout(PersistCookieJar cookieJar) async {
    try {
      await authService.logout();
    } catch (e) {
      debugPrint("Logout API error: $e");
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
        final existingUser = await AppStorage.getUser();
        final updatedUser = {...?existingUser, ...profileData['user']};
        await AppStorage.saveUser(updatedUser);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to fetch user profile: $e");
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
      if (kDebugMode) print("Failed to verify email: $e");
      throw Exception("Failed to verify email");
    }
  }
}
