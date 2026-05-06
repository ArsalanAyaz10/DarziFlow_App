import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/features/Profile/controllers/editProfile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePhotoPicker extends GetView<EditProfileController> {
  const ProfilePhotoPicker({super.key});

  @override
  Widget build(BuildContext context) {
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
                  icon: Icon(Icons.camera_alt, size: 16, color: colors.surface),
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
          Text(
            "JPEG, GIF or PNG. Max 3MB (2MB)",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
