import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class ProfileSubmittedScreen extends StatelessWidget {
  const ProfileSubmittedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),
              Text(
                'Profile Submitted!',
                style: AppTextStyles.headlineLarge
                    .copyWith(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Your profile is under review. We will notify you via email once it\'s approved.',
                style: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryGray, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              Text(
                'You can now explore the app. Some features may be limited until your profile is verified.',
                style: AppTextStyles.textSmall
                    .copyWith(color: AppColors.primaryGray, fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              _buildActionButton(context),
              const SizedBox(height: 40),
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 15),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 28,),
        ),
      ],
    );
  }
}