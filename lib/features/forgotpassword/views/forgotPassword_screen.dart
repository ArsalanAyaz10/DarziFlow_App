import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/core/widgets/auth_bottom_link.dart';
import 'package:dariziflow_app/core/widgets/custom_elevated_button.dart';
import 'package:dariziflow_app/core/widgets/custom_text_field.dart';
import 'package:dariziflow_app/features/forgotpassword/controllers/password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotpasswordScreen extends GetView<PasswordController> {
  const ForgotpasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildDescription(),
                const SizedBox(height: 30),
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
                const SizedBox(height: 30),
                Obx(
                  () => CustomElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.sendResetLink,
                    text: "Send Reset Link",
                    icon: Icons.arrow_forward,
                    isLoading: controller.isLoading.value,
                  ),
                ),
                const SizedBox(height: 24),
                const AuthBottomLink(
                  text: "Remember your password? ",
                  linkText: "Log In",
                  routeName: '/login',
                ),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Forgot Password?",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        "Enter the email address associated with your DarziFlow account and we'll send you a link to reset your password.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.outfit,
          fontSize: 14,
          color: AppColors.grey,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(color: Color(0xFFE0E0E0), thickness: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "POWERED BY ",
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey,
                letterSpacing: 1,
              ),
            ),
            Text(
              "DARZIFLOW",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
