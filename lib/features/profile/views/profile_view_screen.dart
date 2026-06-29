import 'package:cached_network_image/cached_network_image.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/features/Profile/controllers/profile_view_controller.dart';
import 'package:dariziflow_app/features/Profile/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileViewScreen extends GetView<ProfileViewController> {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
          "Profile Info",
          style: TextStyle(
            color: colors.onSurface,
            fontFamily: AppFonts.outfit,
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // ── HEADER ──
              _buildHeader(colors, isDark),
              
              const SizedBox(height: 30),

              // ── DETAILS SECTION ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "ACCOUNT DETAILS",
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── DETAILS CONTENT ──
              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: CircularProgressIndicator(color: AppColors.primaryGreen),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      controller.errorMessage.value,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final user = controller.userProfile.value;
                if (user == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildTileWrapper(
                        colors,
                        ProfileTile(
                          icon: Icons.badge_outlined,
                          title: "Role",
                          subtitle: user.formattedRole,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTileWrapper(
                        colors,
                        ProfileTile(
                          icon: Icons.email_outlined,
                          title: "Email Address",
                          subtitle: user.email,
                        ),
                      ),
                      if (user.department != null && user.department!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _buildTileWrapper(
                          colors,
                          ProfileTile(
                            icon: Icons.domain_outlined,
                            title: "Department",
                            subtitle: user.department!,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTileWrapper(ColorScheme colors, Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
      ),
      child: IgnorePointer(child: child), // Disable taps/chevrons for public profile view
    );
  }

  Widget _buildHeader(ColorScheme colors, bool isDark) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Hero(
              tag: 'avatar_${controller.userId}',
              child: CircleAvatar(
                radius: 60,
                backgroundColor: colors.onSurfaceVariant.withValues(alpha: 0.2),
                child: controller.fallbackAvatar.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: controller.fallbackAvatar,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => _buildFallbackInitial(),
                        ),
                      )
                    : _buildFallbackInitial(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          controller.fallbackName,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: AppFonts.outfit,
          ),
        ),
        const SizedBox(height: 5),
        Obx(() {
          final user = controller.userProfile.value;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user != null ? user.formattedRole : "Loading...",
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildFallbackInitial() {
    return const Icon(
      Icons.person,
      size: 60,
      color: AppColors.primaryGreen,
    );
  }
}
