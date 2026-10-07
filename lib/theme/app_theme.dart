import 'package:flutter/material.dart';

/// Paleta do redesign (tema escuro com vermelho Pokédex).
class AppColors {
  static const bg = Color(0xFF15171C);
  static const card = Color(0xFF1F222A);
  static const line = Color(0xFF2B2F39);
  static const track = Color(0xFF2B2F39); // fundo de barras e miniaturas
  static const text = Color(0xFFF2F2F4);
  static const muted = Color(0xFF9AA0AD);
  static const red = Color(0xFFE5383B);
  static const redDark = Color(0xFFB3212A);
}

/// Use em MaterialApp(theme: buildAppTheme()).
ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.red,
      onPrimary: Colors.white,
      secondary: AppColors.red,
      surface: AppColors.card,
      onSurface: AppColors.text,
      error: Color(0xFFFF6B6B),
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.red,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      // Cabeçalho vermelho com a base arredondada, como no redesign.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, space: 1),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.muted),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.card,
      selectedColor: AppColors.red,
      side: const BorderSide(color: AppColors.line),
      labelStyle: const TextStyle(color: AppColors.text, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
