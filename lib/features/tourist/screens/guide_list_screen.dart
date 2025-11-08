import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/features/tourist/widgets/guide_list_card.dart'; // <-- Import the new widget
import 'package:yaloo/core/widgets/icon_Button.dart';

import '../../../core/widgets/custom_app_bar.dart';

// --- MOCK DATA ---
final List<Map<String, dynamic>> availableGuides = [
  {
    "name": "Hadhi Ahamed",
    "location": "Kandy",
    "rating": "4.6",
    "image": "assets/images/guide_1.jpg",
    "languages": ["English", "Sinhala", "Tamil"],
    "specialties": ["Historical", "Food Tour"],
    "isAvailable": true,
  },
  {
    "name": "Hisham",
    "location": "Galle",
    "rating": "4.8",
    "image": "assets/images/guide_2.jpg",
    "languages": ["English", "German"],
    "specialties": ["Surfing", "Beach Life"],
    "isAvailable": false,
  },
  {
    "name": "Dilshan",
    "location": "Ella",
    "rating": "4.7",
    "image": "assets/images/guide_3.jpg",
    "languages": ["English", "Russian"],
    "specialties": ["Hiking", "Nature"],
    "isAvailable": true,
  },
  {
    "name": "Aman",
    "location": "Ella",
    "rating": "4.7",
    "image": "assets/images/guide_3.jpg",
    "languages": ["English", "Russian"],
    "specialties": ["Hiking", "Nature"],
    "isAvailable": false,
  },
];
// -----------------

class GuideListScreen extends StatelessWidget {
  const GuideListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
          title: 'Choose Your Guide',
          actions: [
            CustomIconButton(
              onPressed: () { /* TODO: Handle Search */ },
              icon: Icon(FontAwesomeIcons.magnifyingGlass,
                  color: AppColors.primaryBlack, size: 24),
            ),
            const SizedBox(width: 12),
            Stack(
              alignment: Alignment.center, // Aligns the dot better
              children: [
                CustomIconButton(
                  onPressed: () { /* TODO: Handle notification */ },
                  icon: Icon(FontAwesomeIcons.bell, color: AppColors.primaryBlack, size: 24),
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
            const SizedBox(width: 12),
          ],
        ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80), // Padding for chat button
              itemCount: availableGuides.length,
              itemBuilder: (context, index) {
                final guide = availableGuides[index];
                return GuideListCard(
                  name: guide['name'],
                  location: guide['location'],
                  rating: guide['rating'],
                  imageUrl: guide['image'],
                  languages: guide['languages'],
                  specialties: guide['specialties'],
                  isAvailable: guide['isAvailable'],
                );
              },
            ),
          ),
        ],
      ),
      // NOTE: The floating chat button will be visible here,
      // because this screen is pushed on top of the 'TouristDashboardScreen'
    );
  }

  // --- 1. Custom App Bar ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop(); // Go back
        },
        icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryBlack, size: 24),
      ),
      title: Text(
        'Choose Your Guide',
        style: AppTextStyles.headlineLargeBlack.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        CustomIconButton(
          onPressed: () { /* TODO: Handle Search */ },
          icon: Icon(FontAwesomeIcons.magnifyingGlass,
              color: AppColors.primaryBlack, size: 24),
        ),
        const SizedBox(width: 12),
        Stack(
          children: [
            CustomIconButton(
              onPressed: () { /* TODO: Handle notification */ },
              icon: Icon(FontAwesomeIcons.bell, color: AppColors.primaryBlack, size: 24),
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
        const SizedBox(width: 12),
      ],
    );
  }

  // --- 2. Filter & Sort Bar ---
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        children: [
          _buildFilterChip(FontAwesomeIcons.sliders, "Filter"),
          const SizedBox(width: 12),
          _buildFilterChip(FontAwesomeIcons.sort, "Sort"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGray, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryGray),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}