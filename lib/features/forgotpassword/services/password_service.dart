import 'package:dariziflow_app/core/network/api_client.dart';

class ForgotPasswordService {
  final ApiClient apiClient;

  ForgotPasswordService(this.apiClient);

  Future<dynamic> forgotPassword(String email) async {
    final response = await apiClient.post(
      "/auth/forgot-password",
      data: {"email": email},
    );
    return response.data;
  }

  Future<dynamic> resetPassword(String token, String newPassword) async {
    final response = await apiClient.put(
      "/auth/reset-password/$token",
      data: {"password": newPassword},
    );
    return response.data;
  }

  Future<dynamic> verifyToken(String token) async {
    final response = await apiClient.get("/auth/reset-password/$token");
    return response.data;
  }
}
