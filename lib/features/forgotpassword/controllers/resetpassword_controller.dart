import 'package:dariziflow_app/features/forgotpassword/repositories/password_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final ForgotPasswordRepository repository;
  late String resetToken;

  // dependency injection
  ResetPasswordController(this.repository);

  // Text Editing Controllers
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // UI State Observables
  var isLoading = false.obs;
  var isNewPasswordObscured = true.obs;
  var isConfirmPasswordObscured = true.obs;

  // Password Visibility Toggles
  void toggleNewPasswordVisibility() => isNewPasswordObscured.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordObscured.toggle();

  @override
  void onInit() {
    super.onInit();
    resetToken = Get.arguments ?? "";

    if (resetToken.isEmpty) {
      debugPrint("Warning: No reset token found in arguments");
    }
  }

  Future<void> resetPassword() async {
    final String password = newPasswordController.text.trim();
    final String confirmPassword = confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        "Error",
        "All fields are required",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Error",
        "Passwords do not match",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        "Error",
        "Password must be at least 8 characters",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final String token = resetToken;

      if (token.isEmpty) {
        throw "Invalid or expired session. Please try again.";
      }

      final response = await repository.resetPassword(token, password);

      if (response['success'] == true) {
        Get.snackbar(
          "Success",
          "Password reset successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/login');
      } else {
        throw response['message'] ?? "Failed to reset password";
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
