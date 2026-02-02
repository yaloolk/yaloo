// lib/features/auth/screens/common/approval_rejected_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class ApprovalRejectedScreen extends StatelessWidget {
  const ApprovalRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Sad Icon
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 60.w,
                  color: Colors.red,
                ),
              ),

              SizedBox(height: 40.h),

              Text(
                'Application Rejected',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              Text(
                'Unfortunately, your application has been rejected.\n\n'
                    'This could be due to incomplete information or verification issues.\n\n'
                    'Please contact our support team for more details or to reapply.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 16.sp,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // Contact Support Button
              ElevatedButton(
                onPressed: () {
                  // TODO: Open email or contact form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Support email: support@yaloo.com')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Contact Support',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Logout Button
              TextButton(
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  'Logout',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}