import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
          controller: controller,
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}
