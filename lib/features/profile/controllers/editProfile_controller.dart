import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dariziflow_app/core/storage/storage.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/services/upload_service.dart';
import 'package:dariziflow_app/features/profile/repositories/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final ProfileRepository profileRepository;
  final UploadService uploadService;
  final cookieJar = PersistCookieJar();

  EditProfileController({
    required this.profileRepository,
    required this.uploadService,
  });

  // Loading states
  var isLoading = false.obs;
  var isUploading = false.obs;

  // User info
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userAvatar = ''.obs;
  var userRole = ''.obs;
  var notificationsEnabled = true.obs;
  var isCurrentPasswordVisible = false.obs;
  var isNewPasswordVisible = false.obs;

  // Controllers for edit form
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Password controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();

    refreshUserProfile();
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.toggle();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.toggle();
  }

  Future<void> refreshUserProfile() async {
    try {
      final updatedUser = await profileRepository.refreshUserProfile();
      if (updatedUser != null) {
        userName.value = updatedUser['name'] ?? userName.value;
        userEmail.value = updatedUser['email'] ?? userEmail.value;
        userAvatar.value = updatedUser['avatar']?['url'] ?? userAvatar.value;
        userRole.value = _formatUserRole(updatedUser['role'] ?? '');

        // Update controllers with api data
        nameController.text = userName.value;
        emailController.text = userEmail.value;
      }
    } catch (e) {
      if (kDebugMode) print("Error refreshing user profile: $e");
    }
  }

  Future<void> loadUserInfo() async {
    try {
      final user = await AppStorage.getUser();
      userName.value = user?['name'] ?? 'User';
      userEmail.value = user?['email'] ?? 'No email found';
      userAvatar.value = user?['avatar']?['url'] ?? '';
      userRole.value = _formatUserRole(user?['role'] ?? '');

      nameController.text = userName.value;
      emailController.text = userEmail.value;
    } catch (e) {
      if (kDebugMode) print("Error loading user info: $e");
    }
  }

  String _formatUserRole(String role) {
    switch (role) {
      case 'CLIENT':
        return 'Client';
      case 'DEPARTMENT_HEAD':
        return 'Department Head';
      case 'QC_MEMBER':
        return 'QC Member';
      default:
        return 'Production Manager';
    }
  }

  // Profile picture
  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        isUploading.value = true;

        final file = File(pickedFile.path);

        // Check file size (max 2MB as per UI)
        final fileSize = await file.length();
        if (fileSize > 2 * 1024 * 1024) {
          Get.snackbar(
            "Error",
            "File size must be less than 2MB",
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
            isDismissible: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            colorText: AppColors.white,
          );
          return;
        }

        // Upload to Cloudinary via service
        final imageUrl = await uploadService.uploadProfileAvatar(file);

        // Update the local observable
        userAvatar.value = imageUrl;

        Get.snackbar(
          "Success",
          "Profile photo updated successfully",
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
          isDismissible: true,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload image: $e",
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }

  // Save profile
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      await profileRepository.updateProfile(
        name: nameController.text,
        email: emailController.text,
      );

      final updatedUser = await AppStorage.getUser();
      final avatarUrl = updatedUser?['avatar']?['url'] ?? userAvatar.value;
      await AppStorage.saveUser({
        ...?updatedUser,
        'name': nameController.text,
        'email': emailController.text,
        'avatar': {'url': avatarUrl},
      });

      Get.back(
        result: {'name': nameController.text, 'email': emailController.text},
      );

      Get.snackbar(
        "Success",
        "Profile updated successfully",
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        backgroundColor: AppColors.primaryGreen,
        colorText: AppColors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile: $e",
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        colorText: AppColors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Change password
  Future<void> changePassword() async {
    if (newPasswordController.text.length < 8) {
      Get.snackbar(
        "Error",
        "Password must be at least 8 characters",
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        colorText: AppColors.white,
      );
      return;
    }

    if (!newPasswordController.value.text.contains(RegExp(r'[A-Z]')) ||
        !newPasswordController.value.text.contains(RegExp(r'[a-z]')) ||
        !newPasswordController.value.text.contains(RegExp(r'[0-9]'))) {
      Get.snackbar(
        "Error",
        "Passwords do not meet requirements (uppercase, lowercase, number, special character)",
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        colorText: AppColors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await profileRepository.changePassword(
        currentPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      // Clear password fields
      currentPasswordController.clear();
      newPasswordController.clear();

      Get.snackbar(
        "Success",
        "Password changed successfully",
        backgroundColor: AppColors.primaryGreen,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to change password: $e",
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
      if (kDebugMode) {
        print("Change password error: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    try {
      await profileRepository.updateNotificationPreferences(value);
      notificationsEnabled.value = value;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update notification preferences",
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        colorText: AppColors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();

    super.onClose();
  }
}
