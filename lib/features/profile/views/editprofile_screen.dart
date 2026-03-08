import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/profile/controllers/editProfile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoPicker(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("PERSONAL DETAILS"),
                  const SizedBox(height: 15),
                  _buildInputField("Full Name", controller.nameController),
                  const SizedBox(height: 15),
                  _buildInputField("Email Address", controller.emailController),
                  const SizedBox(height: 30),
                  _buildSectionHeader("SECURITY & PASSWORD"),
                  const SizedBox(height: 10),
                  _buildSecurityCard(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("APP PREFERENCES"),
                  const SizedBox(height: 10),
                  _buildNotificationToggle(),
                  const SizedBox(height: 30),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (controller.isUploading.value || controller.isLoading.value)
              _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.black),
        onPressed: () => Get.back(
          result: {
            'name': controller.userName.value,
            'email': controller.userEmail.value,
          },
        ),
      ),
      title: const Text(
        "Edit Profile",
        style: TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primaryGreen.withValues(
                    alpha: 0.1,
                  ),
                  backgroundImage: controller.userAvatar.value.isNotEmpty
                      ? NetworkImage(controller.userAvatar.value)
                      : null,
                  child: controller.userAvatar.value.isEmpty
                      ? const Icon(
                          Icons.person_outline,
                          size: 50,
                          color: AppColors.primaryGreen,
                        )
                      : null,
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryGreen,
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: AppColors.white,
                  ),
                  onPressed: controller.pickAndUploadImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: controller.pickAndUploadImage,
            child: const Text(
              "Change Profile Photo",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            "JPEG, GIF or PNG. Max 3MB (2MB)",
            style: TextStyle(color: AppColors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onTapOutside: (_) => FocusScope.of(Get.context!).unfocus(),
          controller: controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade400.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildPasswordField(
            "Current Password",
            controller.currentPasswordController,
            isVisible: controller.isCurrentPasswordVisible,
            onToggle: controller.toggleCurrentPasswordVisibility,
          ),
          const SizedBox(height: 15),
          _buildPasswordField(
            "New Password",
            controller.newPasswordController,
            isVisible: controller.isNewPasswordVisible,
            onToggle: controller.toggleNewPasswordVisibility,
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Minimum 8 chars",
              style: TextStyle(color: AppColors.grey, fontSize: 11),
            ),
          ),

          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: controller.changePassword,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Update Password",
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller, {
    required RxBool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller,
            obscureText: !isVisible.value,
            keyboardType: TextInputType.visiblePassword,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible.value ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AppColors.grey,
                ),
                onPressed: onToggle,
              ),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.grey,
          ),
          title: const Text(
            "Order Notification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          subtitle: const Text(
            "Alert for production messages",
            style: TextStyle(fontSize: 10),
          ),
          trailing: Switch(
            value: controller.notificationsEnabled.value,
            activeThumbColor: AppColors.primaryGreen,
            onChanged: controller.toggleNotifications,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showSaveConfirmationDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.all(15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Discard Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _showDiscardConfirmationDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(15),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Discard Changes",
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Save Confirmation Dialog
  void _showSaveConfirmationDialog() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          title: const Text("Save Changes"),
          content: const Text("Are you sure you want to save the changes?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                controller.saveProfile(); // Save changes
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        // These options ensure dialog appears above everything
        barrierDismissible: false,
        useSafeArea: true,
      );
    });
  }

  // Discard Confirmation Dialog
  void _showDiscardConfirmationDialog() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          title: const Text("Discard Changes"),
          content: const Text("Are you sure you want to discard all changes?"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close dialog
                Get.back(); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text(
                "Discard",
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    });
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}
