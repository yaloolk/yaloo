import 'package:flutter/material.dart';
// --- UPDATED IMPORT ---
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  // --- UPDATED ICONS ---
  {"name": "Beach", "icon": FontAwesomeIcons.umbrellaBeach},
  {"name": "Mountains", "icon": FontAwesomeIcons.mountain},
  {"name": "Jungle", "icon": FontAwesomeIcons.tree},
  {"name": "Culture", "icon": FontAwesomeIcons.landmark},
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
              // Now passes the context
              _buildFindSection(context),
              const SizedBox(height: 24),
              _buildSectionHeader(title: "Popular Destinations"),
              const SizedBox(height: 16),
              _buildPopularSlider(),
              const SizedBox(height: 24),
              _buildSectionHeader(title: "Choose Category"),
              const SizedBox(height: 16),
              _buildCategorySlider(),
              const SizedBox(height: 24),
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
            icon: Icon(FontAwesomeIcons.gear,
                color: AppColors.primaryBlack, size: 24),
            style: _iconButtonStyle(),
          ),
          const SizedBox(width: 12),
          Stack(
            children: [
              IconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(FontAwesomeIcons.bell,
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Destinations !',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 22,
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
                  Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primaryGray, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () { /* TODO: Handle filter */ },
            icon: Icon(FontAwesomeIcons.sliders,
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
      width: 300,
      margin: EdgeInsets.only(
        left: isFirst ? 24.0 : 8.0,
        right: isLast ? 24.0 : 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
                  context: context,
                  label: "GUIDE",
                  icon: FontAwesomeIcons.compass,
                  onPressed: () {
                    Navigator.pushNamed(context, '/findGuide');

                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFindButton(
                  context: context,
                  label: "HOST",
                  icon: FontAwesomeIcons.houseChimney,
                  onPressed: () { /* TODO: Go to Find Host */ },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFindButton(
                  context: context,
                  label: "FOOD",
                  icon: FontAwesomeIcons.utensils,
                  onPressed: () { /* TODO: Go to Find Host */ },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFindButton(
                  context: context,
                  label: "HOTEL",
                  icon: FontAwesomeIcons.hotel,
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
    required BuildContext context,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3.0,
      shadowColor: AppColors.primaryGray.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.fourthBlue,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGray.withOpacity(0.12),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.secondaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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
              child: Icon(FontAwesomeIcons.expand, color: Colors.white, size: 20),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                Icon(FontAwesomeIcons.mapPin,
                    color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
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

  // --- Helper for 3D Text Effect (No longer used) ---
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