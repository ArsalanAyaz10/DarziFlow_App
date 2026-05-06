import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';
import 'package:dariziflow_app/features/Profile/controllers/viewProfile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

class ProfileHeader extends GetView<ViewprofileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
                    ? const Icon(
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
                style: const TextStyle(
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
}
