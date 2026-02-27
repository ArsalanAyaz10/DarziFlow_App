import 'package:dariziflow_app/core/utils/colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F8F6),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
  );
}
