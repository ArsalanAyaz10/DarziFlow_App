import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dariziflow_app/core/utils/colors.dart';

class AuthBottomLink extends StatelessWidget {
  final String text;
  final String linkText;
  final String routeName;

  const AuthBottomLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: TextStyle(color: AppColors.grey, fontSize: 14)),
        GestureDetector(
          onTap: () => Get.toNamed(routeName),
          child: Text(
            linkText,
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
