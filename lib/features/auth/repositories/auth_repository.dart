import 'package:cookie_jar/cookie_jar.dart';

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

    print("STATUS: ${response.statusCode}");
    print("DATA: ${response.data}");

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
    await TokenStorage.clearTokens();
    await cookieJar.deleteAll();
  }
}
