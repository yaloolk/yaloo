import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/features/tourist//widgets/host_list_card.dart'; // <-- Import the new widget
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

// --- MOCK DATA ---
final List<Map<String, dynamic>> availableHosts = [
  {
    "uid": "host123",
    "name": "Silva's Village Home",
    "location": "Kandy",
    "rating": "4.6",
    "image": "assets/images/host_1.png",
    "maxGuests": 8,
  },
  {
    "uid": "host456",
    "name": "Elle Garden Stay",
    "location": "Ella",
    "rating": "4.8",
    "image": "assets/images/host_2.png",
    "maxGuests": 4,
  },
  {
    "uid": "host789",
    "name": "Galle Fort Villa",
    "location": "Galle",
    "rating": "4.7",
    "image": "assets/images/host_3.jpg",
    "maxGuests": 6,
  },
];
// -----------------

class HostListScreen extends StatelessWidget {
  const HostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Choose Your Host',
        actions: [
          CustomIconButton(
            onPressed: () { /* TODO: Handle Search */ },
            icon: Icon(CupertinoIcons.search,
                color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
          Stack(
            alignment: Alignment.center,
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
              padding: EdgeInsets.only(top: 8.h, bottom: 80.h), // Padding for chat button
              itemCount: availableHosts.length,
              itemBuilder: (context, index) {
                final host = availableHosts[index];
                return HostListCard(
                  hostData: host,
                  name: host['name'],
                  location: host['location'],
                  rating: host['rating'],
                  imageUrl: host['image'],
                  maxGuests: host['maxGuests'],
                );
              },
            ),
          ),
        ],
      ),
      // The floating chat button from TouristDashboardScreen will be visible here
    );
  }

  // --- 2. Filter & Sort Bar ---
  Widget _buildFilterBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
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