import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/data/models/auth_model.dart';
import 'package:dariziflow_app/features/profile/services/profile_service.dart';

class ProfileRepository {
  final ProfileService service;

  ProfileRepository(this.service);

  // Update profile information
  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    try {
      await service.updateProfile(name: name, email: email);

      final user = await AppStorage.getAuthUser();
      if (user != null) {
        await AppStorage.saveAuthUser(user.copyWith(
          name: name,
          email: email,
        ));
      }
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception("Failed to change password: $e");
    }
  }

  // Toggle notifications
  Future<void> updateNotificationPreferences(bool enabled) async {
    try {
      await service.updateNotificationPreferences(enabled);
    } catch (e) {
      throw Exception("Failed to update notification preferences: $e");
    }
  }

  // Refresh user profile from server
  Future<Map<String, dynamic>?> refreshUserProfile() async {
    try {
      final data = await service.getUserProfile();
      if (data != null && data['user'] != null) {
        final freshUser = AuthModel.fromJson(
          Map<String, dynamic>.from(data['user']),
        );
        await AppStorage.saveAuthUser(freshUser);
        return data['user'];
      }
      return null;
    } catch (e) {
      throw Exception("Failed to refresh profile: $e");
    }
  }
}
