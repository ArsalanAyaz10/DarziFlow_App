import 'package:dariziflow_app/features/forgotpassword/repositories/password_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();
  final ForgotPasswordRepository repository;

  PasswordController({required this.repository});

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final data = await repository.sendResetLink(emailController.text.trim());
      if (data['success'] == false) {
        Get.snackbar(
          "Error",
          data['message'] ?? 'Failed to send reset link. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
      final message = data['message'] ?? 'Reset link sent successfully';

      Get.snackbar(
        "Success",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        isDismissible: true,
      );
      //Get.toNamed('/resetpassword');
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send reset link. Please try again.",
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
    emailController.dispose();
    super.onClose();
  }
}
