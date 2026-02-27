import 'package:flutter/material.dart';
import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:dariziflow_app/core/utils/fonts.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final IconData prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? label;
  final bool showLabel;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hint,
    required this.prefixIcon,
    required this.items,
    required this.onChanged,
    this.label,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel && label != null) ...[
          _buildLabel(label!),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              hint: Text(
                hint,
                style: TextStyle(
                  color: AppColors.grey.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              icon: Icon(Icons.arrow_drop_down, color: AppColors.grey),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  prefixIcon,
                  color: AppColors.grey.withOpacity(0.8),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 40),
                border: InputBorder.none,
              ),
              items: items,
              onChanged: onChanged,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.black.withOpacity(0.7),
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}
