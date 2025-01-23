import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryAccent = Color(0xFF6200EE);
  static const Color secondaryAccent = Color(0xFF03DAC6);
  static const Color darkAccent = Color(0xFF000000);

  static var secondaryLight;

  static var secondary;

  static var primary;

  static var darkTextLight;

  static var errorLight;

  static var error;

  static var accent;

  static var background;
}

class AppTheme {
  static final ThemeData theme = ThemeData(
    primaryColor: AppColors.primaryAccent,
    hintColor: AppColors.secondaryAccent,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkAccent),
      bodyMedium: TextStyle(color: AppColors.darkAccent),
    ),
    // Tambahkan pengaturan tema lainnya sesuai kebutuhan
  );
}
