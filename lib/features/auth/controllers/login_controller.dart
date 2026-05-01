import 'package:dariziflow_app/core/network/api_client.dart';
import 'package:dariziflow_app/core/utils/global.dart';
import 'package:dariziflow_app/core/utils/role_router.dart';
import 'package:dariziflow_app/data/services/notifications_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/features/notifications/controllers/notification_controller.dart';
import '../repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;

  LoginController({required this.authRepository});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;
  var rememberMe = false.obs;

  @override
  void onInit() {
    super.onInit();
    rememberMe.value = box.read('remember_me') ?? false;
  }

  var selectedRole = Rxn<UserRole>();
  final List<UserRole> roles = [UserRole.qcMember, UserRole.departmenthead];

  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleRememberMe(bool? value) => rememberMe.value = value ?? false;

  Future<void> syncFcmToken() async {
    try {
      String? token = await Get.find<NotificationService>().getDeviceToken();

      if (token != null) {
        await Get.find<ApiClient>().post(
          "/auth/update-fcm-token",
          data: {"token": token},
        );
        if (kDebugMode) {
          print("FCM Token synced with backend");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("FCM Sync Error: $e");
      }
    }
  }

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter email and password",
        isDismissible: true,
        padding: EdgeInsets.all(10),
        duration: Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final authUser = await authRepository.login(
        emailController.text.trim(),
        passwordController.value.text.trim(),
      );

      if (kDebugMode) {
        print("Authenticated User: ${authUser.name} (${authUser.role})");
      }


      // Fetch notifications after login
      Get.find<NotificationController>().fetchNotifications();

      syncFcmToken();

      // Save remember me 
      if (rememberMe.value) {
        box.write('remember_me', true);
      } else {
        box.remove('remember_me');
      }

      final pendingRoute = box.read('pending_route');
      if (pendingRoute != null) {
        box.remove('pending_route');
        Get.offAllNamed(pendingRoute);
      } else {
        RoleRouter.route(authUser.role);
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        "Invalid credentials or server error",
        isDismissible: true,
        padding: EdgeInsets.all(10),
        duration: Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // emailController.dispose();
    // passwordController.dispose();
    super.onClose();
  }
}
