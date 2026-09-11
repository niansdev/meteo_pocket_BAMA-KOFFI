import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.orange,
      secondary: AppColors.green,
      surface: AppColors.lightBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.navy,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fillColor: Colors.white,
        hintColor: Colors.black54,
        borderColor: AppColors.orange,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFFFFA726),
        secondary: const Color(0xFF49D18D),
        surface: const Color(0xFF111D27),
        onSurface: const Color(0xFFF5F7FA),
        onSurfaceVariant: const Color(0xFFC7D0D9),
        outline: const Color(0xFF52616F),
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF5F7FA)),
        bodyMedium: TextStyle(color: Color(0xFFE1E7EC)),
        bodySmall: TextStyle(color: Color(0xFFB9C4CE)),
        titleLarge: TextStyle(color: Color(0xFFF5F7FA)),
        titleMedium: TextStyle(color: Color(0xFFF5F7FA)),
        titleSmall: TextStyle(color: Color(0xFFE1E7EC)),
        labelLarge: TextStyle(color: Color(0xFFF5F7FA)),
        labelMedium: TextStyle(color: Color(0xFFD3DCE4)),
        labelSmall: TextStyle(color: Color(0xFFB9C4CE)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFF5F7FA),
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fillColor: AppColors.darkSurface,
        hintColor: Color(0xFF9EABB7),
        borderColor: AppColors.orange,
        labelColor: Color(0xFFD3DCE4),
        prefixColor: Color(0xFFB9C4CE),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2B3A46)),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF24323D),
        contentTextStyle: TextStyle(color: Color(0xFFF5F7FA)),
      ),
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fillColor,
    required Color hintColor,
    required Color borderColor,
    Color? labelColor,
    Color? prefixColor,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide.none,
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: hintColor),
      labelStyle: labelColor == null ? null : TextStyle(color: labelColor),
      prefixIconColor: prefixColor,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    );
  }
}
