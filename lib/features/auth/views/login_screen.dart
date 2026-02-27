import 'package:dariziflow_app/core/widgets/auth_bottom_link.dart';
import 'package:dariziflow_app/core/widgets/auth_header.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/core/widgets/custom_text_field.dart';
import 'package:dariziflow_app/core/widgets/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const AuthHeader(
                  title: "Welcome Back",
                  subtitle: "Log in to manage your production flow",
                  icon: Icons.archive_outlined,
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

                const ForgotPasswordLink(),

                const SizedBox(height: 20),

                Obx(
                  () => CustomElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : _handleLoginSubmit,
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

  void _handleLoginSubmit() {
    if (controller.formKey.currentState!.validate()) {
      controller.handleLogin();
    }
  }
}
