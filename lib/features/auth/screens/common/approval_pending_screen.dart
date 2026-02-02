// lib/features/auth/screens/common/approval_pending_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/services/api_service.dart';
import 'package:yaloo/core/services/auth_guard_service.dart';

class ApprovalPendingScreen extends StatefulWidget {
  const ApprovalPendingScreen({super.key});

  @override
  State<ApprovalPendingScreen> createState() => _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends State<ApprovalPendingScreen> with SingleTickerProviderStateMixin {
  final DjangoApiService _apiService = DjangoApiService();
  final AuthGuardService _authGuard = AuthGuardService();
  bool _isChecking = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ... (Build method remains the same) ...
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
              // Animated Icon
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * 3.14159,
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: AppColors.thirdBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.hourglass_empty_rounded,
                        size: 60.w,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40.h),

              Text(
                'Approval Pending',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              Text(
                'Thank you for submitting your profile!\n\n'
                    'Our team is currently reviewing your application. '
                    'This usually takes 24-48 hours.\n\n'
                    'You\'ll receive an email notification once your profile is approved.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 16.sp,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // Check Status Button
              ElevatedButton(
                onPressed: _isChecking ? null : _checkApprovalStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isChecking
                    ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  'Check Status',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Logout Button
              TextButton(
                onPressed: _logout,
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

  // --- UPDATED LOGIC HERE ---
  Future<void> _checkApprovalStatus() async {
    setState(() => _isChecking = true);

    try {
      if (kDebugMode) {
        print('🔍 Checking approval status...');
      }

      final user = await _apiService.getCurrentUser();
      final verificationStatus = user['verification_status'] as String?;
      final userRole = user['user_role'] as String?;
      final hasVerifiedStay = user['has_verified_stay'] as bool? ?? false;

      if (kDebugMode) {
        print('📊 Status: $verificationStatus | Role: $userRole | Stay Verified: $hasVerifiedStay');
      }

      // 1. Check for Rejection first
      if (verificationStatus == 'rejected') {
        if (mounted) Navigator.pushReplacementNamed(context, '/approvalRejected');
        return;
      }

      // 2. Use AuthGuard to determine the route
      final route = await _authGuard.getInitialRoute();

      // 3. Logic for Feedback
      if (route == '/approvalPending') {
        // If we are still sent to pending, show specific reason
        if (userRole == 'host' && verificationStatus == 'verified' && !hasVerifiedStay) {
          _showMessage('Your profile is approved! We are now reviewing your Stay property.');
        } else {
          _showMessage('Your application is still under review. Please check back later.');
        }
      } else {
        // Approved! Navigate away
        if (kDebugMode) {
          print('✅ Approved! Navigating to $route...');
        }
        if (mounted) Navigator.pushReplacementNamed(context, route);
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking status: $e');
      }
      _showMessage('Error checking status. Please try again.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}