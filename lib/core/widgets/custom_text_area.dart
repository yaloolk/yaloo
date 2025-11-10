import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

/// A custom multi-line text field with your app's standard shadow and style.
class CustomTextArea extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData icon;

  const CustomTextArea({
    super.key,
    this.controller,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20), // Your global shadow
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.multiline,
        maxLines: 5, // Allows the field to expand
        minLines: 3, // Starts at this height
        style: AppTextStyles.textSmall.copyWith(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray.withAlpha(150),
          ),
          prefixIcon: Padding(
            padding:  EdgeInsets.only(left: 20.w, right: 16.w, top: 20.h),
            // --- THIS IS THE FIX ---
            // Aligns the icon to the top-left, not the center
            child: Align(
              alignment: Alignment.topCenter,
              child: Icon(icon, color: AppColors.primaryGray),
            ),
          ),
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