import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Text(
                'Who are you joining as?',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge
                    .copyWith(color: const Color(0xFF001A33)),
              ),
              const SizedBox(height: 40),

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
                          Navigator.pushNamed(context, '/login');
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              //  custom widget
              CustomPrimaryButton(
                text: 'Continue',
                onPressed: _selectedRole == null
                    ? null
                    : () {
                  if (_selectedRole == UserRole.tourist) {
                    Navigator.pushNamed(context, '/signup');
                  } else if (_selectedRole == UserRole.guide) {
                    Navigator.pushNamed(context, '/guideSignup');
                  } else if (_selectedRole == UserRole.host) {
                    Navigator.pushNamed(context, '/hostSignup');
                  }
                },
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
              color: AppColors.primaryGray.withAlpha(20), // Your shadow color
              blurRadius: 20,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.thirdBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
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