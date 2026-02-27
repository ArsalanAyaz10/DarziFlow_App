import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final formKey = GlobalKey<FormState>();

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // TODO: Implement actual API call to send reset link
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      Get.snackbar(
        "Success",
        "Reset link sent to your email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Optionally navigate back to login after success
      // Future.delayed(const Duration(seconds: 2), () => Get.back());
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
