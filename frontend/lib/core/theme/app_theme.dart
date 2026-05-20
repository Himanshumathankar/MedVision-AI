import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryBlue,
      primary: AppColors.primaryBlue,
      secondary: AppColors.primaryPurple,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 42, color: Colors.black87),
      headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 28, color: Colors.black87),
    ),
    scaffoldBackgroundColor: AppColors.softGray,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0x33FFFFFF),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      labelStyle: TextStyle(color: Colors.black54),
    ),
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryPurple,
      brightness: Brightness.dark,
      primary: AppColors.primaryBlue,
      secondary: AppColors.primaryPurple,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 42, color: Colors.white),
      headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 28, color: Colors.white),
    ),
    scaffoldBackgroundColor: AppColors.darkNavy,
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0x1AFFFFFF),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      labelStyle: TextStyle(color: Colors.white70),
    ),
    useMaterial3: true,
  );
}
