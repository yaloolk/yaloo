import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _onboardingPages = const [
    _OnboardingPage(
      imagePath: 'assets/illustrations/onboarding1_illustration.png',
      title: 'Explore like a Local',
      subtitle:
      'Go where locals go. Eat what they eat. Feel the culture with every step.',
    ),
    _OnboardingPage(
      imagePath: 'assets/illustrations/onboarding2_illustration.png',
      title: 'Verified Guides & Hosts',
      subtitle:
      'You\'re in good hands. All our guides and hosts are pre-screened and trusted by Yaloo.',
    ),
    _OnboardingPage(
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
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: _onboardingPages,
                ),
              ),
              _buildBottomNavigation(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(
          'assets/images/yaloo_logo.png',
          width: 40.w,
          height: 40.h,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.public_rounded,
              color: AppColors.primaryBlue,
              size: 28.w,
            );
          },
        ),
        SizedBox(width: 8.w),
        Text(
          'Yaloo',
          style: AppTextStyles.headlineLarge,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    bool isLastPage = _currentPage == _onboardingPages.length - 1;

    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/userSelection');
            },
            child: Text(
              'Skip',
              style:
              AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryGray),
            ),
          ),
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
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 9.h,
                  width: _currentPage == index ? 20.w : 9.w,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryBlue
                        : AppColors.thirdBlue,
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
              );
            }),
          ),
          TextButton(
            onPressed: () {
              if (isLastPage) {
                Navigator.pushReplacementNamed(context, '/userSelection');
              } else {
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
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(top: 100.h),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGray,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'Image not found.\n$imagePath',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.primaryGray),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.primaryBlack,
                fontSize: 22.sp,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGray,
                fontSize: 14.sp,
                height: 1.4.h,
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
