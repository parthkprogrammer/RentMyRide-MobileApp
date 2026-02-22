import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class AppColors {
  // Light Mode
  static const Color lightPrimary = Color(0xFF1E3A8A);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF3B82F6);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightAccent = Color(0xFF60A5FA);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightPrimaryText = Color(0xFF1E293B);
  static const Color lightSecondaryText = Color(0xFF64748B);
  static const Color lightHint = Color(0xFF94A3B8);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightSuccess = Color(0xFF10B981);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Dark Mode
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color darkSecondary = Color(0xFF1E3A8A);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkAccent = Color(0xFF60A5FA);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkOnSurface = Color(0xFFF8FAFC);
  static const Color darkPrimaryText = Color(0xFFF1F5F9);
  static const Color darkSecondaryText = Color(0xFF94A3B8);
  static const Color darkHint = Color(0xFF475569);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFFFFFFFF);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkDivider = Color(0xFF334155);
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightOnPrimary,
    secondary: AppColors.lightSecondary,
    onSecondary: AppColors.lightOnSecondary,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    outline: AppColors.lightDivider,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.lightPrimaryText,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.lightSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.lightDivider, width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightOnPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.lightPrimaryText,
      side: const BorderSide(color: AppColors.lightDivider),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.lightDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.lightDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.light),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkOnPrimary,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkOnSecondary,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    outline: AppColors.darkDivider,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.darkPrimaryText,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.darkSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      side: const BorderSide(color: AppColors.darkDivider, width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkOnPrimary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkPrimaryText,
      side: const BorderSide(color: AppColors.darkDivider),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.darkDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.darkDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.dark),
);

TextTheme _buildTextTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final baseColor = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
  
  return TextTheme(
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      height: 1.2,
      color: baseColor,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: baseColor,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: baseColor,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: baseColor,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: baseColor,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: baseColor,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: baseColor,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: baseColor,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: baseColor,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: baseColor,
    ),
  );
}