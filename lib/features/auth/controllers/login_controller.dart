import 'package:dariziflow_app/core/utils/role_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;

  LoginController({required this.authRepository});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
   final formKey = GlobalKey<FormState>();
  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  var selectedRole = Rxn<UserRole>();
  final List<UserRole> roles = [UserRole.qcMember, UserRole.departmenthead];

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  Future<void> handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter email and password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final String role = await authRepository.login(
        emailController.text.trim(),
        passwordController.value.text.trim(),
      );
      RoleRouter.route(role);
    } catch (e) {
      Get.snackbar("Login Failed", "Invalid credentials or server error");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
