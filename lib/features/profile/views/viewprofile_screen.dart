import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/features/profile/controllers/viewProfile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewProfileScreen extends GetView<ViewprofileController> {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: colors.onSurface,
            fontFamily: AppFonts.outfit,
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(context),
              const SizedBox(height: 30),
              _buildSectionTitle(context, "ACCOUNT DETAILS"),
              const SizedBox(height: 10),
              _buildAccountSection(context),
              const SizedBox(height: 20),
              _buildSectionTitle(context, "SYSTEM"),
              _buildSystemSection(context),
              const SizedBox(height: 30),
              _buildLogoutButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: colors.onSurfaceVariant.withValues(alpha: 0.2),
                backgroundImage: controller.userAvatar.value.isNotEmpty
                    ? NetworkImage(controller.userAvatar.value)
                    : null,
                child: controller.userAvatar.value.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primaryGreen,
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            controller.userName.value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.outfit,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.userRole.value,
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              controller.navigateToEditProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: Text(
              "Edit Profile",
              style: TextStyle(color: colors.surface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _profileTile(
                context,
                Icons.email_outlined,
                "Email Address",
                controller.userEmail.value,
              ),
            ),

            const SizedBox(height: 10), // Space between containers
            // Password Container
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: _profileTile(
                  context,
                  Icons.lock_outline,
                  "Password",
                  controller.getPasswordUpdateText(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: _profileTile(
                context,
                Icons.notifications_none,
                "Notifications",
                "Manage alerts and news",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: _profileTile(
          context,
          Icons.language,
          "Language",
          "English (US)",
        ),
      ),
    );
  }

  Widget _profileTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGreen),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
      ),
      trailing: Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () => controller.logout(),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: colors.error.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: colors.error),
              const SizedBox(width: 10),
              Text(
                "Log Out",
                style: TextStyle(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
