import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../widgets/guide_list_card.dart';

// --- MOCK DATA ---
final List<Map<String, dynamic>> availableGuides = [
  {
    "uid": "guide123", // <-- Added UID
    "name": "Hadhi Ahamed",
    "location": "Kandy",
    "rating": "4.6",
    "image": "assets/images/guide_1.jpg",
    "languages": ["English", "Sinhala", "Tamil"],
    "specialties": ["Historical", "Food Tour"],
    "isAvailable": true,
  },
  {
    "uid": "guide456", // <-- Added UID
    "name": "Hisham",
    "location": "Galle",
    "rating": "4.8",
    "image": "assets/images/guide_2.jpg",
    "languages": ["English", "German"],
    "specialties": ["Surfing", "Beach Life"],
    "isAvailable": false,
  },
  {
    "uid": "guide789", // <-- Added UID
    "name": "Dilshan",
    "location": "Ella",
    "rating": "4.7",
    "image": "assets/images/guide_3.jpg",
    "languages": ["English", "Russian"],
    "specialties": ["Hiking", "Nature"],
    "isAvailable": true,
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
                  // --- UPDATED: Pass the full map ---
                  guideData: guide,
                  // ---------------------------------
                  name: guide['name'],
                  location: guide['location'],
                  rating: guide['rating'],
                  imageUrl: guide['image'],
                  languages: List<String>.from(guide['languages']),
                  specialties: List<String>.from(guide['specialties']),
                  isAvailable: guide['isAvailable'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ... (rest of the file is unchanged) ...

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