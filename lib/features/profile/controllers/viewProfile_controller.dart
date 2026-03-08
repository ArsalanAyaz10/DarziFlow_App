import 'package:cookie_jar/cookie_jar.dart';
import 'package:dariziflow_app/core/storage/token_storage.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/data/services/cookie_service.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ViewprofileController extends GetxController {
  final AuthRepository authRepository;
  final CookieService _cookieService = CookieService();

  ViewprofileController(this.authRepository);

  // Loading state
  var isLoading = false.obs;

  // User info
  var userName = ''.obs;
  var userRole = ''.obs;
  var userEmail = ''.obs;
  var userAvatar = ''.obs;
  var notificationsEnabled = true.obs;
  var passwordUpdatedAt = ''.obs;

  // Controllers for edit form

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final locationController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }

  String formatUserRole(String role) {
    switch (role) {
      case 'CLIENT':
        return 'Client';
      case 'DEPARTMENT_HEAD':
        return 'Department Head';
      case 'QC_MEMBER':
        return 'QC_Member';
      default:
        return 'Unknown Role';
    }
  }

  Future<void> loadUserInfo() async {
    try {
      final user = await TokenStorage.getUser();
      userName.value = user?['name'] ?? 'User';
      userRole.value = formatUserRole(user?['role']);
      userEmail.value = user?['email'] ?? 'No email found';
      passwordUpdatedAt.value = user?['passwordUpdatedAt'] ?? 'Not set';

      if (user != null && user['avatar'] != null) {
        userAvatar.value = user['avatar']['url'] ?? '';
      } else {
        userAvatar.value = '';
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user info: $e");
      }
      userName.value = 'User';
      userRole.value = 'Unknown Role';
      userEmail.value = 'No email found';
      userAvatar.value = '';
    }
  }

  Future<void> navigateToEditProfile() async {
    var result = await Get.toNamed('/editprofile');

    if (result != null) {
      if (result['name'] != null) {
        userName.value = result['name'];
      }
      if (result['email'] != null) {
        userEmail.value = result['email'];
      }
    } else {
      await loadUserInfo();
    }
  }

  String getPasswordUpdateText() {
    if (passwordUpdatedAt.value.isEmpty) {
      return "Password not changed yet";
    }

    try {
      final updatedAt = DateTime.parse(passwordUpdatedAt.value);
      final now = DateTime.now();
      final difference = now.difference(updatedAt);

      if (difference.inDays >= 365) {
        final years = (difference.inDays / 365).floor();
        return "Last changed $years year${years > 1 ? 's' : ''} ago";
      } else if (difference.inDays >= 30) {
        final months = (difference.inDays / 30).floor();
        return "Last changed $months month${months > 1 ? 's' : ''} ago";
      } else if (difference.inDays >= 7) {
        final weeks = (difference.inDays / 7).floor();
        return "Last changed $weeks week${weeks > 1 ? 's' : ''} ago";
      } else if (difference.inDays >= 1) {
        return "Last changed ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      } else if (difference.inHours >= 1) {
        return "Last changed ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
      } else if (difference.inMinutes >= 1) {
        return "Last changed ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
      } else {
        return "Last changed just now";
      }
    } catch (e) {
      // If date parsing fails, return the raw value or default
      return "Last changed ${passwordUpdatedAt.value}";
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      final cookieJar = await _cookieService.cookieJar;
      await authRepository.logout(cookieJar);

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/splash');
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to logout. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );

      if (kDebugMode) {
        print("Logout error: $e");
      }
    } finally {
      isLoading.value = false;
    }
  }
}
