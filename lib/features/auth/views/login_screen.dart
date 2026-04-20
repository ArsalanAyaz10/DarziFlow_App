import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/forgotpassword/widgets/auth_bottom_link.dart';
import 'package:dariziflow_app/features/auth/widgets/auth_header.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                RepaintBoundary(
                  child: const AuthHeader(
                    title: "Welcome Back",
                    subtitle: "Log in to manage your production flow",
                    icon: Icons.archive_outlined,
                  ),
                ),

                CustomTextField(
                  controller: controller.emailController,
                  hint: "name@company.com",
                  icon: Icons.email_outlined,
                  label: "EMAIL ADDRESS",
                  showLabel: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required";
                    }
                    if (!GetUtils.isEmail(value)) {
                      return "Enter a valid email address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    hint: "Enter your password",
                    icon: Icons.lock_outline,
                    label: "PASSWORD",
                    showLabel: true,
                    obscureText: !controller.isPasswordVisible.value,
                    suffixIcon: controller.isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: controller.togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Password must be at least 6 characters";
                      }
                      return null;
                    },
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: controller.rememberMe.value,
                              onChanged: controller.toggleRememberMe,
                              activeColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: BorderSide(
                                color: colors.onSurfaceVariant,
                                width: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => controller.toggleRememberMe(
                              !controller.rememberMe.value,
                            ),
                            child: Text(
                              "Remember me",
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed('/forgot-password'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Obx(
                  () => CustomElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (controller.formKey.currentState!.validate()) {
                              controller.handleLogin();
                            }
                          },
                    text: "Login",
                    icon: Icons.arrow_forward,
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 32),

                const AuthBottomLink(
                  text: "Don't have an account? ",
                  linkText: "Sign Up",
                  routeName: '/signup',
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
