import 'package:cookie_jar/cookie_jar.dart';
import 'package:dariziflow_app/core/storage/token_storage.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ViewprofileController extends GetxController {
  final AuthRepository authRepository;
  final cookieJar = PersistCookieJar();

  ViewprofileController(this.authRepository);

  // Loading state
  var isLoading = false.obs;
  
  // User info
  var userName = ''.obs;
  var userRole = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }

  String FormatUserRole(String role) {
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
      userRole.value = FormatUserRole(user?['role']);
      userEmail.value = user?['email'] ?? 'No email found';
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user info: $e");
      }
      userName.value = 'User';
      userRole.value = 'Unknown Role';
      userEmail.value = 'No email found';
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call logout API and clear local data
      await authRepository.logout(cookieJar);

      // Show success message
      Get.snackbar(
        "Success",
        "Logged out successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryGreen,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );

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
