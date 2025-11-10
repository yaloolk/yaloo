import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';

class SocialAuthButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialAuthButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: EdgeInsets.all(16.w),
        side: BorderSide(color: AppColors.secondaryGray),
      ),
      child: Image.asset(
        iconPath,
        height: 28.h,
        width: 28.w,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.public, color: AppColors.primaryGray, size: 28.w);
        },
      ),
    );
  }
}