import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/features/Profile/controllers/viewProfile_controller.dart';
import 'package:dariziflow_app/features/Profile/widgets/profile_header.dart';
import 'package:dariziflow_app/features/Profile/widgets/profile_shimmer.dart';
import 'package:dariziflow_app/features/Profile/widgets/profile_tile.dart';
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
            fontSize: 18,
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
      body: Obx(() {
        if (controller.userName.value.isEmpty &&
            controller.userEmail.value.isEmpty) {
          return const ProfileShimmer();
        }
        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const ProfileHeader(),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
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

                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.black),
                          ),
                          child: ProfileTile(
                            icon: Icons.email_outlined,
                            title: "Email Address",
                            subtitle: controller.userEmail.value,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ProfileTile(
                            icon: Icons.lock_outline,
                            title: "Password",
                            subtitle: controller.getPasswordUpdateText(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const ProfileTile(
                            icon: Icons.notifications_none,
                            title: "Notifications",
                            subtitle: "Manage alerts and news",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "SYSTEM",
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                // LANGUAGE SELECTION
                // TODO INTERNATIONALIZATION GETX
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const ProfileTile(
                      icon: Icons.language,
                      title: "Language",
                      subtitle: "English (US)",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => controller.logout(),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: colors.error),
                          const SizedBox(width: 10),
                          Text(
                            "LOG OUT",
                            style: TextStyle(
                              color: colors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}

