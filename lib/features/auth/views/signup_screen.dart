import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/widgets/custom_text_field.dart';
import 'package:dariziflow_app/core/widgets/custom_dropdown.dart';
import 'package:dariziflow_app/features/auth/widgets/auth_header.dart';
import 'package:dariziflow_app/features/ForgotPassword/widgets/auth_bottom_link.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/app/routes/app_pages.dart';
import 'package:flutter/gestures.dart';
import '../controllers/signup_controller.dart';

class SignupScreen extends GetView<SignupController> {
  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthHeader(
                  title: "Create Account",
                  subtitle:
                      "Join DarziFlow to streamline your production today.",
                  icon: Icons.keyboard,
                ),

                CustomTextField(
                  controller: controller.fullNameController,
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                  label: "FULL NAME",
                  showLabel: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Name is required";
                    }
                    if (value.length < 3) return "Name too short";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                CustomTextField(
                  controller: controller.emailController,
                  hint: "name@company.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  label: "EMAIL ADDRESS",
                  showLabel: true,
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
                const SizedBox(height: 15),

                Obx(
                  () => CustomDropdown<UserRole>(
                    value: controller.selectedRole.value,
                    hint: "Select your role",
                    prefixIcon: Icons.badge_outlined,
                    label: "ROLE",
                    showLabel: true,
                    items: [UserRole.qcMember, UserRole.departmenthead]
                        .map((role) => DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(getRoleString(role)),
                            ))
                        .toList(),
                    onChanged: (value) => controller.selectedRole.value = value,
                  ),
                ),
                const SizedBox(height: 15),

                Obx(
                  () => CustomTextField(
                    controller: controller.passwordController,
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    obscureText: !controller.isPasswordVisible.value,
                    label: "PASSWORD",
                    showLabel: true,
                    suffixIcon: controller.isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    onSuffixTap: controller.togglePasswordVisibility,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      if (value.length < 6) {
                        return "Minimum 6 characters required";
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                          text: "By creating an account, you agree to our ",
                        ),
                        TextSpan(
                          text: "Terms of Service",
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(Routes.termsOfService);
                            },
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(Routes.privacyPolicy);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Obx(
                  () => CustomElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (controller.selectedRole.value == null) {
                                Get.snackbar(
                                  "Role Required",
                                  "Please select a user role to continue",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              controller.handleSignUp();
                            }
                          },
                    text: "Create Account",
                    icon: Icons.arrow_forward,
                    isLoading: controller.isLoading.value,
                  ),
                ),

                const SizedBox(height: 24),
                const AuthBottomLink(
                  text: "Already have an account? ",
                  linkText: "Sign In",
                  routeName: '/login',
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
