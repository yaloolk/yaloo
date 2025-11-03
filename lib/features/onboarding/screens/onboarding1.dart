import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Use padding for overall screen margins
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0)
              .copyWith(top: 20, bottom: 20),
          child: Column(
            children: [
              // 1. Header: "Yaloo" Logo and Title
              _buildHeader(),

              const Spacer(flex: 2), // Flexible space

              // 2. Illustration
              _buildIllustration(context),

              const Spacer(flex: 1), // Flexible space

              // 3. Text Content: Headline and Sub-text
              _buildTextContent(),

              const Spacer(flex: 2), // Flexible space

              // 4. Bottom Navigation: Skip, Dots, Next
              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the top "Yaloo" header
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [

        Image.asset(
          'assets/icons/Yaloo_logo.png', // <-- Yaloo logo
          width: 28,
          height: 28,
          // color: AppColors.primaryBlue,
          errorBuilder: (context, error, stackTrace) {
            // This fallback icon will show if the logo isn't found
            return Icon(
              Icons.public_rounded,
              color: AppColors.primaryBlue,
              size: 28,
            );
          },
        ),

        SizedBox(width: 8),
        Text(
          'Yaloo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue, // Using primary blue for the text
          ),
        ),
      ],
    );
  }

  // Helper widget for the main illustration
  Widget _buildIllustration(BuildContext context) {
    return SizedBox(
      // Set height relative to screen size
      height: MediaQuery.of(context).size.height * 0.35,
      child: Image.asset(
        // IMPORTANT: Add your image to this path in pubspec.yaml
        'assets/illustrations/onboarding1_illustration.png',
        fit: BoxFit.contain,

        // This provides a helpful fallback if the image is missing
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.secondaryGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Image not found.\nMake sure to add:\nassets/illustrations/onboarding1_illustration.png',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.primaryGray),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget for the text content
  Widget _buildTextContent() {
    return Column(
      children: [
        Text(
          'Explore like a Local',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            // Using a very dark blue for high contrast, as in the image
            color: Color(0xFF001A33),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Go where locals go. Eat what they eat. Feel the culture with every step.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primaryGray,
            height: 1.5, // Improves readability of multi-line text
          ),
        ),
      ],
    );
  }

  // Helper widget for the bottom navigation bar
  Widget _buildBottomNavigation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // "Skip" Button
        TextButton(
          onPressed: () {
            // TODO: Implement skip logic (e.g., navigate to home or login)
          },
          child: Text(
            'Skip',
            style: TextStyle(
              color: AppColors.primaryGray,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Page Indicators
        Row(
          children: [
            _buildDot(isActive: true),
            SizedBox(width: 8),
            _buildDot(isActive: false),
            SizedBox(width: 8),
            _buildDot(isActive: false),
          ],
        ),

        // "Next" Button
        TextButton(
          onPressed: () {
            // TODO: Implement next logic (e.g., navigate to onboarding2.dart)
          },
          child: Text(
            'Next',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget to build a single dot
  Widget _buildDot({required bool isActive}) {
    return Container(
      height: 9,
      width: 9,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : AppColors.thirdBlue,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}


