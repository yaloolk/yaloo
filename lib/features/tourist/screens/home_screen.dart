import 'package:flutter/material.dart';
import  'package:lucide_icons_flutter/lucide_icons.dart';// <-- Your import
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

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
  {"name": "Beach", "icon": LucideIcons.umbrella},
  {"name": "Mountains", "icon": LucideIcons.mountain},
  {"name": "Jungle", "icon": LucideIcons.trees},
  {"name": "Culture", "icon": LucideIcons.landmark},
];
// ---------------------------------


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildFeaturedSlider(),
              const SizedBox(height: 24),
              _buildFindSection(),
              const SizedBox(height: 24),
              _buildSectionHeader(title: "Popular Destinations"),
              const SizedBox(height: 16),
              _buildPopularSlider(),
              const SizedBox(height: 24),
              _buildSectionHeader(title: "Choose Category"),
              const SizedBox(height: 16),
              _buildCategorySlider(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          Image.asset(
            'assets/images/yaloo_logo.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),
          Text(
            'Hi, yaloo',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primaryBlack,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () { /* TODO: Handle Settings */ },
            icon: Icon(LucideIcons.settings,
                color: AppColors.primaryBlack, size: 24),
            style: _iconButtonStyle(),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(LucideIcons.bell,
                    color: AppColors.primaryBlack, size: 24),
                style: _iconButtonStyle(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
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

  ButtonStyle _iconButtonStyle() {
    return IconButton.styleFrom(
      shape: CircleBorder(),
      backgroundColor: Colors.white,
      elevation: 8, //shadow
      padding: EdgeInsets.all(10),
      shadowColor: Colors.black.withOpacity(0.2),
    );
  }

  // --- 2. Title ---
  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Amazing',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Destinations !',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 28,
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primaryBlue, width: 1),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.primaryGray),
                  prefixIcon:
                  Icon(LucideIcons.search, color: AppColors.primaryGray, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () { /* TODO: Handle filter */ },
            icon: Icon(LucideIcons.slidersHorizontal,
                color: AppColors.primaryBlack, size: 24),
            style: _iconButtonStyle(),
          ),
        ],
      ),
    );
  }

  // --- 4. Featured Slider ---
  Widget _buildFeaturedSlider() {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredDestinations.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final item = featuredDestinations[index];
          return _buildFeaturedCard(
            // title parameter removed
            imageUrl: item['image']!,
            isFirst: index == 0,
            isLast: index == featuredDestinations.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard({
    // required String title, // <-- REMOVED
    required String imageUrl,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(
        left: isFirst ? 24.0 : 8.0,
        right: isLast ? 24.0 : 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          // Use AssetImage for local assets, NetworkImage for web
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
      // --- UPDATED: Removed the Center/3DText child ---
      // child: Center(
      //   child: _build3dText(title, fontSize: 56),
      // ),
    );
  }

  // --- 5. Find (Guide/Host) Section ---
  Widget _buildFindSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find What You're Looking For",
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFindButton(
                  label: "GUIDE",
                  icon: LucideIcons.compass,
                  onPressed: () { /* TODO: Go to Find Guide */ },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFindButton(
                  label: "HOST",
                  icon: LucideIcons.house,
                  onPressed: () { /* TODO: Go to Find Host */ },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFindButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.thirdBlue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGray.withAlpha(20),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.secondaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 6. Reusable Section Header ---
  Widget _buildSectionHeader({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
    return Container(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: popularDestinations.length,
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
      width: 220,
      margin: EdgeInsets.only(
        left: isFirst ? 24.0 : 8.0,
        right: isLast ? 24.0 : 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
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
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(LucideIcons.maximize, color: Colors.white, size: 20),
            ),
          ),
          // --- UPDATED: Removed the Center/3DText widget ---
          // Center(
          //   child: _build3dText(title, fontSize: 48),
          // ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                Icon(LucideIcons.mapPin,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                // --- UPDATED: Show the title where the location was ---
                Text(
                  title, // <-- Show title here
                  style: AppTextStyles.bodyLarge.copyWith( // <-- Bigger text
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
    return Container(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
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
    return Padding(
      padding: EdgeInsets.only(
        left: isFirst ? 24.0 : 8.0,
        right: isLast ? 24.0 : 8.0,
      ),
      child: ChoiceChip(
        label: Text(label),
        avatar: Icon(icon, color: AppColors.primaryBlue, size: 20),
        selected: false,
        onSelected: (selected) { /* TODO: Handle selection */ },
        labelStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.thirdBlue,
        shape: StadiumBorder(
          side: BorderSide(color: AppColors.secondaryGray, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  // --- Helper for 3D Text Effect ---
  // This is no longer used, but I'll leave it in case you want to
  // add it back to the "Popular" slider.
  Widget _build3dText(String text, {double fontSize = 48}) {
    return Stack(
      children: [
        Text(
          text,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        Positioned(
          top: -2,
          left: -2,
          child: Text(
            text,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}