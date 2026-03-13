import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/profile/controllers/editProfile_controller.dart';
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
      backgroundColor: colors.background,
      appBar: _buildAppBar(context),
      body: Obx(
        () => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoPicker(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "PERSONAL DETAILS"),
                  const SizedBox(height: 15),
                  _buildInputField(context, "Full Name", controller.nameController),
                  const SizedBox(height: 15),
                  _buildInputField(context, "Email Address", controller.emailController),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "SECURITY & PASSWORD"),
                  const SizedBox(height: 10),
                  _buildSecurityCard(context),
                  const SizedBox(height: 30),
                  _buildSectionHeader(context, "APP PREFERENCES"),
                  const SizedBox(height: 10),
                  _buildNotificationToggle(context),
                  const SizedBox(height: 30),
                  _buildActionButtons(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            if (controller.isUploading.value || controller.isLoading.value)
              _buildLoadingOverlay(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.onBackground),
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
    );
  }

  Widget _buildPhotoPicker(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                  backgroundImage: controller.userAvatar.value.isNotEmpty
                      ? NetworkImage(controller.userAvatar.value)
                      : null,
                  child: controller.userAvatar.value.isEmpty
                      ? Icon(
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
                  icon: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: colors.surface,
                  ),
                  onPressed: controller.pickAndUploadImage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: controller.pickAndUploadImage,
            child: Text(
              "Change Profile Photo",
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            "JPEG, GIF or PNG. Max 3MB (2MB)",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {IconData? icon}) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(BuildContext context, String label, TextEditingController textController) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold, 
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onTapOutside: (_) => FocusScope.of(Get.context!).unfocus(),
          controller: textController,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
            context,
            "Current Password",
            controller.currentPasswordController,
            isVisible: controller.isCurrentPasswordVisible,
            onToggle: controller.toggleCurrentPasswordVisibility,
          ),
          const SizedBox(height: 15),
          _buildPasswordField(
            context,
            "New Password",
            controller.newPasswordController,
            isVisible: controller.isNewPasswordVisible,
            onToggle: controller.toggleNewPasswordVisibility,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Minimum 8 chars",
              style: TextStyle(
                color: colors.onSurfaceVariant, 
                fontSize: 11,
              ),
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
              child: Text(
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
    BuildContext context,
    String label,
    TextEditingController textController, {
    required RxBool isVisible,
    required VoidCallback onToggle,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.bold, 
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: textController,
            obscureText: !isVisible.value,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible.value ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                onPressed: onToggle,
              ),
              filled: true,
              fillColor: colors.surface,
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

  Widget _buildNotificationToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => Container(
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
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 10,
            ),
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

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        // Save Button
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

        // Discard Button
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
    );
  }

  // Save Confirmation Dialog
  void _showSaveConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          backgroundColor: colors.surface,
          title: Text("Save Changes", style: TextStyle(color: colors.onSurface)),
          content: Text("Are you sure you want to save the changes?", style: TextStyle(color: colors.onSurfaceVariant)),
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
                Get.back(); // Close dialog
                controller.saveProfile(); // Save changes
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              child: Text(
                "Save",
                style: TextStyle(color: colors.surface),
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
  void _showDiscardConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Future.delayed(const Duration(milliseconds: 100), () {
      Get.dialog(
        AlertDialog(
          backgroundColor: colors.surface,
          title: Text("Discard Changes", style: TextStyle(color: colors.onSurface)),
          content: Text("Are you sure you want to discard all changes?", style: TextStyle(color: colors.onSurfaceVariant)),
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
                Get.back(); // Close dialog
                Get.back(); // Go back to previous screen
              },
              style: ElevatedButton.styleFrom(backgroundColor: colors.error),
              child: Text(
                "Discard",
                style: TextStyle(color: colors.surface),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    });
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      color: colors.onBackground.withValues(alpha: 0.3),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}
