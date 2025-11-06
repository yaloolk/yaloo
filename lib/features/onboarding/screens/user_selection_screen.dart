import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';

// Enum to hold the different user roles
enum UserRole { tourist, guide, host }

class UserSelectionScreen extends StatefulWidget {
  const UserSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserSelectionScreen> createState() => _UserSelectionScreenState();
}

class _UserSelectionScreenState extends State<UserSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    // Using a white background as requested
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // 1. Title
              Text(
                'Who are you joining as?',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge
                    .copyWith(color: const Color(0xFF001A33)),
              ),
              const SizedBox(height: 40),

              // 2. Role Selection Cards
              _buildRoleCard(
                role: UserRole.tourist,
                title: 'Explore',
                subtitle: 'Discover, explore & book authentic experiences.',
                icon: Icons.flight_takeoff_rounded,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: UserRole.guide,
                title: 'Be a Local Guide',
                subtitle: 'Share your local knowledge & earn confidently.',
                icon: Icons.explore_outlined,
              ),
              const SizedBox(height: 16),
              _buildRoleCard(
                role: UserRole.host,
                title: 'Be a Host',
                subtitle: 'Offer authentic homestays & cultural experiences.',
                icon: Icons.home_outlined,
              ),

              const Spacer(flex: 2),

              // 3. Log In Text
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primaryGray),
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
                          // Navigate to Login screen
                          Navigator.pushNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 4. Continue Button
              ElevatedButton(
                // The button is disabled if no role is selected
                onPressed: _selectedRole == null
                    ? null
                    : () {
                  // UPDATED: Navigate based on the selected role
                  if (_selectedRole == UserRole.tourist) {
                    Navigator.pushNamed(context, '/signup');
                  } else if (_selectedRole == UserRole.guide) {
                    // TODO: Create a Guide Signup Screen
                     Navigator.pushNamed(context, '/guideSignup');
                  } else if (_selectedRole == UserRole.host) {
                    // TODO: Create a Host Signup Screen
                    // Navigator.pushNamed(context, '/hostSignup');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor:
                  AppColors.primaryGray.withAlpha(128), // 0.5 opacity
                ),
                child: Text(
                  'Continue',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the selectable role cards
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGray.withAlpha(128), // 0.5 opacity
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.thirdBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: const Color(0xFF001A33),
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primaryGray),
                  ),
                ],
              ),
            ),
            // Radio Button
            Radio<UserRole>(
              value: role,
              groupValue: _selectedRole,
              onChanged: (UserRole? value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              activeColor: AppColors.primaryBlue,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
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