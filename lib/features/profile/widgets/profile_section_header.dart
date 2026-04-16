import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
}
