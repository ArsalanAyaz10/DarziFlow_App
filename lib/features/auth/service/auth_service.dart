import 'package:dariziflow_app/core/network/api_client.dart';

class AuthService {
  final ApiClient apiClient;
  static const route = "auth";
  static const platform = "MOBILE";

  AuthService({required this.apiClient});

  Future<dynamic> register({
    required String name,
    required String email,
    required String role,
    required String password,
  }) async {
    return apiClient.post(
      "$route/register",
      data: {
        "name": name,
        "email": email,
        "role": role,
        "password": password,
        "platform": platform,
      },
    );
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    return apiClient.post(
      "$route/login",
      data: {"email": email, "password": password, "platform": platform},
    );
  }

  Future<dynamic> getProfile() async {
    return apiClient.get("profile");
  }

  Future<dynamic> verifyEmail(String token) async {
    return apiClient.get("auth/verify/$token");
  }

  Future<dynamic> logout({String? fcmToken}) async {
    return apiClient.post("auth/logout", data: {"fcmToken": fcmToken});
  }

  Future<dynamic> me() async {
    return apiClient.get("$route/me");
  }
}
