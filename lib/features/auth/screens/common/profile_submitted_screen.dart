import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class ProfileSubmittedScreen extends StatelessWidget {
  const ProfileSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 80.w,
                height: 80.h,
              ),
               SizedBox(height: 20.h),
              Text(
                'Profile Submitted!',
                style: AppTextStyles.headlineLarge
                    .copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
              ),
               SizedBox(height: 20.h),
              Text(
                'Your profile is under review. We will notify you via email once it\'s approved.',
                style: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryGray, fontSize: 16.sp, height: 1.5.h),
              ),
               SizedBox(height: 20.h),
              Text(
                'You can now explore the app. Some features may be limited until your profile is verified.',
                style: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryGray, fontSize: 16.sp, height: 1.5.h),
              ),
              const Spacer(),
              _buildActionButton(context),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            'Explore App',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
         SizedBox(width: 15.w),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to the Guide Dashboard
            // Navigator.pushReplacementNamed(context, '/guideDashboard');

            // --- MOCKUP: For now, just print ---
            print("Navigating to Guide Dashboard (placeholder)");
          },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: const StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    ),
          child: Icon(Icons.arrow_forward, color: Colors.white, size: 28.w),
        ),
      ],
    );
  }
}