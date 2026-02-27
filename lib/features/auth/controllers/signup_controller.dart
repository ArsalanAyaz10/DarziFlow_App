import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/auth_repository.dart';

class SignupController extends GetxController {
  final AuthRepository authRepository = Get.find<AuthRepository>();

  // Form Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Role selection for QC and Supervisor
  final List<String> roles = ["QC Member", "Department Head"];
  var selectedRole = Rxn<UserRole>();

  void setRole(String? value) {
    if (value != null) {
      selectedRole.value = value as UserRole?;
    }
  }

  var isPasswordVisible = false.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> handleSignUp() async {
    final name = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (selectedRole.value != UserRole.client && password.isEmpty) {
      Get.snackbar("Error", "Password is required for QC and Supervisor");
      return;
    }

    if (email.isEmpty) {
      Get.snackbar("Error", "Email is required");
      return;
    }

    if (selectedRole.value == null) {
      Get.snackbar("Error", "Please select a role");
      return;
    }

    try {
      isLoading.value = true;

      await authRepository.register(
        name: name,
        email: email,
        password: password,
        role: selectedRole.value!,
        platform: "MOBILE",
      );

      Get.snackbar(
        "Success",
        "Account created. Please check email for verification link.",
      );

      Get.offNamed("/login");
    } catch (e) {
      Get.snackbar("Signup Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
