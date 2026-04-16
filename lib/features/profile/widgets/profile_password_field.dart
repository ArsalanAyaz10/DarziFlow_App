import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final RxBool isVisible;
  final VoidCallback onToggle;

  const ProfilePasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
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
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            controller: controller,
            obscureText: !isVisible.value,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(color: colors.onSurface, fontSize: 14),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
}
