import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  static final TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlue,
  );

  static final TextStyle headlineLargeBlack = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryBlack,
  );

  static final TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryGray,
  );

  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryGray,
  );

  static final TextStyle textSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryGray,
  );

  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle bodyLargeButton = TextStyle(fontSize: 16);
}
