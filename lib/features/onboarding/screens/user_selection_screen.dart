import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

// Enum to hold the different user roles
enum UserRole { tourist, guide, host }

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({super.key});

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                Text(
                  'Who are you joining as?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: const Color(0xFF001A33),
                  ),
                ),
                SizedBox(height: 40.h),

                // Role selection cards
                _buildRoleCard(
                  role: UserRole.tourist,
                  title: 'Explore',
                  subtitle: 'Discover, explore & book authentic experiences.',
                  icon: Icons.flight_takeoff_rounded,
                ),
                SizedBox(height: 16.h),
                _buildRoleCard(
                  role: UserRole.guide,
                  title: 'Be a Local Guide',
                  subtitle: 'Share your local knowledge & earn confidently.',
                  icon: Icons.explore_outlined,
                ),
                SizedBox(height: 16.h),
                _buildRoleCard(
                  role: UserRole.host,
                  title: 'Be a Host',
                  subtitle: 'Offer authentic homestays & cultural experiences.',
                  icon: Icons.home_outlined,
                ),

                SizedBox(height: 40.h),

                // Login text
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGray,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Log In',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/login');
                          },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Continue button
                CustomPrimaryButton(
                  text: 'Continue',
                  onPressed: _selectedRole == null
                      ? null
                      : () {
                    Navigator.pushNamed(
                      context,
                      '/signup',
                      arguments: _selectedRole!.name,
                    );
                  },
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build each role selection card
  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.thirdBlue.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
            isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGray.withAlpha(20),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.thirdBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 24.w),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: const Color(0xFF001A33),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGray,
                    ),
                  ),
                ],
              ),
            ),
            Radio<UserRole>(
              value: role,
              groupValue: _selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              activeColor: AppColors.primaryBlue,
              fillColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.primaryBlue;
                }
                return AppColors.secondaryGray;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
