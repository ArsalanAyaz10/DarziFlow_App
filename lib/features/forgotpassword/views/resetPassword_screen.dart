import 'package:dariziflow_app/features/forgotpassword/controllers/resetpassword_controller.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart'; // Adjust path
import 'package:dariziflow_app/core/widgets/custom_text_field.dart'; // Adjust path
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Reset Password',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Create New Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please enter your new password below to secure your DarziFlow account.',
              style: TextStyle(
                fontSize: 15,
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // New Password Field
            Obx(
              () => CustomTextField(
                controller: controller.newPasswordController,
                hint: 'Enter new password',
                icon: Icons.lock_outline,
                label: 'NEW PASSWORD',
                showLabel: true,
                obscureText: controller.isNewPasswordObscured.value,
                suffixIcon: controller.isNewPasswordObscured.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixTap: () => controller.toggleNewPasswordVisibility(),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm New Password Field
            Obx(
              () => CustomTextField(
                controller: controller.confirmPasswordController,
                hint: 'Confirm new password',
                icon: Icons.lock_reset_outlined,
                label: 'CONFIRM PASSWORD',
                showLabel: true,
                obscureText: controller.isConfirmPasswordObscured.value,
                suffixIcon: controller.isConfirmPasswordObscured.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                onSuffixTap: () => controller.toggleConfirmPasswordVisibility(),
              ),
            ),

            const SizedBox(height: 16),

            // PasswordHint
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your password must be at least 8 characters long.',
                    style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Reset Button
            Obx(
              () => CustomElevatedButton(
                onPressed: () => controller.resetPassword(),
                text: 'Reset Password',
                isLoading: controller.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
