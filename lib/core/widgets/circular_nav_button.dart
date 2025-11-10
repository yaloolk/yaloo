import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

/// The main navigation button (Text + Circle Button) for multi-page forms.
class CircularNavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CircularNavButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
         SizedBox(width: 15.w),
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isLoading ? AppColors.primaryGray : AppColors.primaryBlue,
            shape: const StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),

          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Icon(Icons.arrow_forward, color: Colors.white, size: 28.w,),
        ),
      ],
    );
  }
}