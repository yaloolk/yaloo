import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';

// This is the main OnboardingScreen that holds all pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controller to manage the pages
  final PageController _pageController = PageController();
  // Keep track of the current page
  int _currentPage = 0;

  // Define the content for all onboarding pages
  final List<Widget> _onboardingPages = [
    const _OnboardingPage(
      imagePath: 'assets/illustrations/onboarding1_illustration.png',
      title: 'Explore like a Local',
      subtitle:
      'Go where locals go. Eat what they eat. Feel the culture with every step.',
    ),
    const _OnboardingPage(
      imagePath: 'assets/illustrations/onboarding2_illustration.png',
      title: 'Verified Guides & Hosts',
      subtitle:
      'You\'re in good hands. All our guides and hosts are pre screened and trusted by Yaloo.',
    ),
    const _OnboardingPage(
      imagePath: 'assets/illustrations/onboarding3_illustration.png',
      title: 'Your AI Travel Assistant',
      subtitle:
      'Let our smart assistant match you with the perfect experience.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0)
              .copyWith(top: 20, bottom: 20),
          child: Column(
            children: [
              // 1. Header: "Yaloo" Logo and Title
              _buildHeader(),

              // 2. Swipable Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: _onboardingPages,
                  // This is called when the user swipes
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                ),
              ),

              // 3. Bottom Navigation: Skip, Dots, Next
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
          'assets/images/yaloologo.svg',
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
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
          style: AppTextStyles.headlineLarge,
        ),
      ],
    );
  }

  // Helper widget for the bottom navigation bar
  Widget _buildBottomNavigation(BuildContext context) {
    // Check if we are on the last page
    bool isLastPage = _currentPage == _onboardingPages.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // "Skip" Button
        TextButton(
          onPressed: () {
            // TODO: Navigate to your main app screen (e.g., /userSelection or /home)
            Navigator.pushReplacementNamed(context, '/userSelection');
          },
          child: Text(
            'Skip',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryGray),
          ),
        ),

        // Page Indicators (Dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_onboardingPages.length, (index) {
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primaryBlue
                      : AppColors.thirdBlue,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            );
          }),
        ),

        // "Next" or "Get Started" Button
        TextButton(
          onPressed: () {
            if (isLastPage) {
              // TODO: Navigate to your main app screen
              Navigator.pushReplacementNamed(context, '/userSelection');
            } else {
              // Go to the next page
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          },
          child: Text(
            isLastPage ? 'Get Started' : 'Next',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

/// A reusable widget to display the content of a single onboarding page
class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        // Illustration
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
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
                      'Image not found.\nMake sure to add:\n$imagePath',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.primaryGray),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Spacer(flex: 1),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge,
        ),
        SizedBox(height: 16),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}