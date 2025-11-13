import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../widgets/guide_list_card.dart';

// --- MOCK DATA ---
final List<Map<String, dynamic>> availableGuides = [
  {
    "uid": "guide123", // <-- Added UID
    "name": "Mohamed",
    "location": "Kandy",
    "rating": "4.6",
    "image": "assets/images/guide_1.jpg",
    "languages": ["English", "Sinhala", "Tamil"],
    "specialties": ["Historical", "Food Tour"],
    "isAvailable": true,
  },
  {
    "uid": "guide456", // <-- Added UID
    "name": "Silva",
    "location": "Galle",
    "rating": "4.8",
    "image": "assets/images/guide_2.jpg",
    "languages": ["English", "German"],
    "specialties": ["Surfing", "Beach Life"],
    "isAvailable": false,
  },
  {
    "uid": "guide789", // <-- Added UID
    "name": "Fernando",
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
  const GuideListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Choose Your Guide',
        actions: [
          CustomIconButton(
            onPressed: () { /* TODO: Handle Search */ },
            icon: Icon(CupertinoIcons.search,
                color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Stack(
            alignment: Alignment.center, // Aligns the dot better
            children: [
              CustomIconButton(
                onPressed: () { /* TODO: Handle notification */ },
                icon: Icon(CupertinoIcons.bell, color: AppColors.primaryBlack, size: 24.w),
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
          SizedBox(width: 12.w),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 8.w, bottom: 80.h), // Padding for chat button
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
      padding: EdgeInsets.fromLTRB(24.w, 0.h, 24.w, 16.h),
      child: Row(
        children: [
          _buildFilterChip(CupertinoIcons.slider_horizontal_3, "Filter"),
          SizedBox(width: 12.w),
          _buildFilterChip(CupertinoIcons.sort_down, "Sort"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.secondaryGray, width: 1.5.w),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: AppColors.primaryGray),
          SizedBox(width: 8.w),
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