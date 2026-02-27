import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback? onTap;
  final String text;

  const ForgotPasswordLink({
    super.key,
    this.onTap,
    this.text = "Forgot Password?",
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap ?? () => Get.toNamed('/forgot-password'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
