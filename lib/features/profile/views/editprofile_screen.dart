import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/profile/controllers/editProfile_controller.dart';
import 'package:dariziflow_app/features/profile/widgets/profile_input_field.dart';
import 'package:dariziflow_app/features/profile/widgets/profile_password_field.dart';
import 'package:dariziflow_app/features/profile/widgets/profile_photo_picker.dart';
import 'package:dariziflow_app/features/profile/widgets/profile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Get.back(
            result: {
              'name': controller.userName.value,
              'email': controller.userEmail.value,
            },
          ),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfilePhotoPicker(),
                  const SizedBox(height: 30),
                  const ProfileSectionHeader(title: "PERSONAL DETAILS"),
                  const SizedBox(height: 15),
                  ProfileInputField(
                    label: "Full Name",
                    controller: controller.nameController,
                  ),
                  const SizedBox(height: 15),
                  ProfileInputField(
                    label: "Email Address",
                    controller: controller.emailController,
                  ),
                  const SizedBox(height: 30),
                  const ProfileSectionHeader(title: "SECURITY & PASSWORD"),
                  const SizedBox(height: 10),
                  Container(
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
                        ProfilePasswordField(
                          label: "Current Password",
                          controller: controller.currentPasswordController,
                          isVisible: controller.isCurrentPasswordVisible,
                          onToggle: controller.toggleCurrentPasswordVisibility,
                        ),
                        const SizedBox(height: 15),
                        ProfilePasswordField(
                          label: "New Password",
                          controller: controller.newPasswordController,
                          isVisible: controller.isNewPasswordVisible,
                          onToggle: controller.toggleNewPasswordVisibility,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Minimum 8 chars",
                            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: controller.changePassword,
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  ),
                  const SizedBox(height: 30),
                  const ProfileSectionHeader(title: "APP PREFERENCES"),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: colors.onSurfaceVariant,
                      ),
                      title: Text(
                        "Order Notification",
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      subtitle: Text(
                        "Alert for production messages",
                        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
                      ),
                      trailing: Switch(
                        value: controller.notificationsEnabled.value,
                        activeThumbColor: AppColors.primaryGreen,
                        onChanged: controller.toggleNotifications,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showSaveConfirmationDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Save Changes",
                            style: TextStyle(
                              color: colors.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _showDiscardConfirmationDialog(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            side: BorderSide(color: colors.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Discard Changes",
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (controller.isUploading.value || controller.isLoading.value)
              Container(
                color: colors.onSurface.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryGreen),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            "Save Changes",
            style: TextStyle(color: colors.onSurface),
          ),
          content: Text(
            "Are you sure you want to save the changes?",
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.saveProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: Text("Save", style: TextStyle(color: colors.surface)),
            ),
          ],
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    });
  }

  void _showDiscardConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            "Discard Changes",
            style: TextStyle(color: colors.onSurface),
          ),
          content: Text(
            "Are you sure you want to discard all changes?",
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.error),
              child: Text("Discard", style: TextStyle(color: colors.surface)),
            ),
          ],
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    });
  }
}
