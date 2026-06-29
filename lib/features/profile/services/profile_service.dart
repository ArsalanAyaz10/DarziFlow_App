import 'package:dariziflow_app/core/network/api_client.dart';

class ProfileService {
  final ApiClient apiClient;

  ProfileService(this.apiClient);

  Future<dynamic> updateProfile({
    required String name,
    required String email,
  }) async {
    final response = await apiClient.put(
      "/profile/updateProfile",
      data: {"name": name, "email": email},
    );
    return response.data;
  }

  // Change password
  Future<dynamic> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await apiClient.put(
      "/profile/password",
      data: {"oldPassword": currentPassword, "newPassword": newPassword},
    );
    return response.data;
  }

  // Update email
  Future<dynamic> updateEmail(String newEmail) async {
    final response = await apiClient.put(
      "/profile/email",
      data: {"email": newEmail},
    );
    return response.data;
  }

  // Update notification preferences
  Future<dynamic> updateNotificationPreferences(bool enabled) async {
    final response = await apiClient.put(
      "/notifications",
      data: {"orderNotifications": enabled},
    );
    return response.data;
  }

  // Get user profile
  Future<dynamic> getUserProfile() async {
    final response = await apiClient.get("/profile/");
    return response.data;
  }

  // Get user by ID (for public profile view)
  Future<dynamic> getUserById(String id) async {
    final response = await apiClient.get("/users/$id");
    return response.data;
  }
}
