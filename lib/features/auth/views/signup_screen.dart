import 'package:dariziflow_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import '../controllers/signup_controller.dart';

class SignupScreen extends GetView<SignupController> {
  SignupScreen({super.key});

  // Global key for the form to handle UI validation
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey, // Connecting the form key
            child: Column(
              children: [
                const SizedBox(height: 60),

                // --- Header Section ---
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.keyboard,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join DarziFlow to streamline your production today.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.outfit,
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Form Fields ---
                _buildLabel("FULL NAME"),
                _buildTextField(
                  controller: controller.fullNameController,
                  hint: "Enter your full name",
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Name is required";
                    if (value.length < 3) return "Name too short";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _buildLabel("EMAIL ADDRESS"),
                _buildTextField(
                  controller: controller.emailController,
                  hint: "name@company.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email is required";
                    if (!GetUtils.isEmail(value))
                      return "Enter a valid email address";
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _buildLabel("ROLE"),
                _buildRoleDropdown(),
                const SizedBox(height: 15),

                _buildLabel("PASSWORD"),
                Obx(
                  () => _buildTextField(
                    controller: controller.passwordController,
                    hint: "••••••••",
                    icon: Icons.lock_outline,
                    obscureText: !controller.isPasswordVisible.value,
                    onSuffixTap: controller.togglePasswordVisibility,
                    suffixIcon: controller.isPasswordVisible.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Password is required";
                      if (value.length < 6)
                        return "Minimum 6 characters required";
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),
                _buildTermsText(),
                const SizedBox(height: 20),

                // --- Action Button ---
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null // Disable button while loading
                        : _handleFormSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- Footer ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed('/login'),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper logic to validate UI before hitting API
  void _handleFormSubmit() {
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
  }

  // --- Reusable Widgets ---

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.black.withOpacity(0.7),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode:
          AutovalidateMode.onUserInteraction, // Shows error as user types
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.grey.withOpacity(0.6),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.grey.withOpacity(0.8),
          size: 18,
        ),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(
                  suffixIcon,
                  color: AppColors.grey.withOpacity(0.8),
                  size: 18,
                ),
                onPressed: onSuffixTap,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    final roleOptions = [UserRole.qcMember, UserRole.departmenthead];

    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField<UserRole>(
            value: controller.selectedRole.value,
            hint: Text(
              "Select your role",
              style: TextStyle(
                color: AppColors.grey.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: AppColors.grey),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.badge_outlined,
                color: AppColors.grey.withOpacity(0.8),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              border: InputBorder.none,
            ),
            items: roleOptions.map((role) {
              return DropdownMenuItem<UserRole>(
                value: role,
                child: Text(
                  getRoleString(role),
                  style: TextStyle(
                    fontFamily: AppFonts.outfit,
                    color: AppColors.black,
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) => controller.selectedRole.value = value,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontSize: 12, color: AppColors.grey, height: 1.5),
          children: const [
            TextSpan(text: "By creating an account, you agree to our "),
            TextSpan(
              text: "Terms of Service",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
