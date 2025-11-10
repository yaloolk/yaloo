import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData icon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.icon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false, required String hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Your global shadow color
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray.withAlpha(150),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 20.w, right: 16.w),
            child: Icon(icon, color: AppColors.primaryGray),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.only(top: 20.h, bottom: 20.h, right: 20.w),
        ),
      ),
    );
  }
}