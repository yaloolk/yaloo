import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

import '../../../core/widgets/custom_icon_button.dart';

// (Mock data lists remain the same...)
// --- MOCK DATA for the sliders ---
final List<Map<String, String>> featuredDestinations = [
  {"name": "Yala", "image": "assets/images/yaloo_banner_1.jpg"},
  {"name": "Forest", "image": "assets/images/yaloo_banner_2.jpg"},
];
final List<Map<String, String>> popularDestinations = [
  {"name": "Sigiriya", "location": "Sigiriya", "image": "assets/images/sigiriya.jpg"},
  {"name": "Ella", "location": "Ella", "image": "assets/images/ella.jpg"},
  {"name": "Galle", "location": "Galle", "image": "assets/images/galle.jpg"},
];
final List<Map<String, dynamic>> categories = [
  {"name": "Beach", "icon": FontAwesomeIcons.umbrellaBeach},
  {"name": "Mountains", "icon": FontAwesomeIcons.mountain},
  {"name": "Jungle", "icon": FontAwesomeIcons.tree},
  {"name": "Culture", "icon": FontAwesomeIcons.landmark},
];
// ---------------------------------

class TouristHomeScreen extends StatelessWidget {
  const TouristHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: 20.h),
                  _buildTitle(),
                  SizedBox(height: 20.h),
                  _buildSearchBar(),
                  SizedBox(height: 24.h),
                  _buildFeaturedSlider(),
                  SizedBox(height: 24.h),
                  _buildFindSection(context),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(title: "Popular Destinations"),
                  SizedBox(height: 16.h),
                  _buildPopularSlider(),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(title: "Choose Category"),
                  SizedBox(height: 16.h),
                  _buildCategorySlider(),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 1. Header ---
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        children: [
          Image.asset(
            'assets/images/yaloo_logo.png',
            width: 40.w,
            height: 40.h,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Hi, yaloo',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: AppColors.primaryBlack,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CustomIconButton(
            onPressed: () { /* TODO: Handle Settings */ },
            icon: Icon(CupertinoIcons.gear,
                color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Stack(
            children: [
              CustomIconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(CupertinoIcons.bell,
                    color: AppColors.primaryBlack, size: 24.w),
              ),
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Title ---
  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Amazing',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Destinations !',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Search Bar ---
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: AppColors.primaryBlue, width: 1),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.primaryGray),
                  prefixIcon: Icon(CupertinoIcons.search,
                      color: AppColors.primaryGray, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          CustomIconButton(
            onPressed: () { /* TODO: Handle filter */ },
            icon: Icon(CupertinoIcons.slider_horizontal_3,
                color: AppColors.primaryBlack, size: 24.w),
          ),
        ],
      ),
    );
  }

  // --- 4. Featured Slider ---
  Widget _buildFeaturedSlider() {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredDestinations.length,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (context, index) {
          final item = featuredDestinations[index];
          return _buildFeaturedCard(
            imageUrl: item['image']!,
            isFirst: index == 0,
            isLast: index == featuredDestinations.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard({
    required String imageUrl,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 300.w,
      margin: EdgeInsets.only(
        left: isFirst ? 16.w : 8.w,
        right: isLast ? 16.w : 8.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        image: DecorationImage(
          image: imageUrl.startsWith('assets/')
              ? AssetImage(imageUrl) as ImageProvider
              : NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(50),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
    );
  }

  // --- 5. Find (Guide/Host) Section ---
  Widget _buildFindSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find What You're Looking For",
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final buttonHeight = constraints.maxWidth < 350 ? 100.h : 120.h;
              return Row(
                children: [
                  Expanded(
                    child: _buildFindButton(
                      context: context,
                      label: "GUIDE",
                      icon: CupertinoIcons.compass,
                      height: buttonHeight,
                      onPressed: () {
                        Navigator.pushNamed(context, '/findGuide');
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildFindButton(
                      context: context,
                      label: "HOST",
                      icon: CupertinoIcons.house_fill,
                      height: buttonHeight,
                      onPressed: () {
                        // TODO: Create a '/findHost' screen
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildFindButton(
                      context: context,
                      label: "FOOD",
                      icon: FontAwesomeIcons.utensils,
                      height: buttonHeight,
                      onPressed: () { /* TODO: Navigate to Find Food */ },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildFindButton(
                      context: context,
                      label: "HOTEL",
                      icon: FontAwesomeIcons.hotel,
                      height: buttonHeight,
                      onPressed: () { /* TODO: Navigate to Find Hotel */ },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFindButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required double height,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: height,
      child: Card(
        elevation: 3.0,
        shadowColor: AppColors.primaryGray.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        color: AppColors.fourthBlue,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGray.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.secondaryBlue,
                    size: 20.w,
                  ),
                ),
                SizedBox(height: 8.h),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 6. Reusable Section Header ---
  Widget _buildSectionHeader({required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineLargeBlack.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () { /* TODO: Handle "See All" */ },
            child: Text(
              "See All",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.thirdGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 7. Popular Destinations Slider ---
  Widget _buildPopularSlider() {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: popularDestinations.length,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (context, index) {
          final item = popularDestinations[index];
          return _buildPopularCard(
            title: item['name']!,
            location: item['location']!,
            imageUrl: item['image']!,
            isFirst: index == 0,
            isLast: index == popularDestinations.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildPopularCard({
    required String title,
    required String location,
    required String imageUrl,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(
        left: isFirst ? 16.w : 8.w,
        right: isLast ? 16.w : 8.w,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: imageUrl.startsWith('assets/')
              ? AssetImage(imageUrl) as ImageProvider
              : NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(50),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: LinearGradient(
                colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(CupertinoIcons.viewfinder,
                  color: Colors.white, size: 16.w),
            ),
          ),
          Positioned(
            bottom: 12.h,
            left: 12.w,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.map_pin,
                        color: Colors.white, size: 12.w),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  location,
                  style: AppTextStyles.textSmall.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. Category Slider ---
  Widget _buildCategorySlider() {
    return SizedBox(
      height: 48.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _buildCategoryChip(
            label: item['name']!,
            icon: item['icon']!,
            isFirst: index == 0,
            isLast: index == categories.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: isFirst ? 16.w : 8.w,
        right: isLast ? 16.w : 8.w,
      ),
      child: ChoiceChip(
        label: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
        avatar: Icon(icon, color: AppColors.primaryBlue, size: 16.w),
        selected: false,
        onSelected: (selected) { /* TODO: Handle selection */ },
        backgroundColor: Colors.white,
        selectedColor: AppColors.thirdBlue,
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.secondaryGray, width: 1.5.w),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
      ),
    );
  }
}