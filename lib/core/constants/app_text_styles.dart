import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  static final TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 26.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryBlue,
  );

  static final TextStyle headlineLargeBlack = GoogleFonts.poppins(
    fontSize: 26.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryBlack,
  );

  static final TextStyle headlineSmallBlack = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryBlack,
  );

  static final TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: AppColors.primaryGray,
  );

  static final TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryGray,
  );

  static final TextStyle textSmall = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryGray,
  );

  static final TextStyle textExtraSmall = GoogleFonts.poppins(
    fontSize: 10.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryGray,
  );

  static final TextStyle textSmallBlack = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.w300,
    color: AppColors.primaryBlack,
  );

  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle bodyLargeButton = TextStyle(fontSize: 14.sp);
}
