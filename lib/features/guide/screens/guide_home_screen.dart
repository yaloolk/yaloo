import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import 'package:yaloo/features/guide/widgets/tour_request_card.dart';
import 'package:yaloo/features/guide/widgets/upcoming_booking_card.dart';

// --- MOCK DATA ---
final List<Map<String, dynamic>> tourRequests = [
  {
    "name": "Emil Carter",
    "image": "assets/images/tourist_1.jpg",
    "countryCode": "DE",
    "duration": "4h",
    "price": "\$36",
    "guests": 2,
    "location": "Ella"
  },
  {
    "name": "Maria",
    "image": "assets/images/tourist_2.jpg",
    "countryCode": "US",
    "duration": "8h",
    "price": "\$72",
    "guests": 4,
    "location": "Kandy"
  },
];

final List<Map<String, dynamic>> upcomingBookings = [
  {
    "title": "Andrea",
    "location": "Galle",
    "guests": 1,
    "date": "10 JUNE",
    "duration": "4h",
    "price": "\$20",
    "image": "assets/images/tourist_3.jpg"
  },
  {
    "title": "Hadhi Ahamed",
    "location": "Ella",
    "guests": 2,
    "date": "12 JUNE",
    "duration": "8h",
    "price": "\$40",
    "image": "assets/images/tourist_4.jpg"
  },
];
// -----------------

class GuideHomeScreen extends StatelessWidget {
  const GuideHomeScreen({super.key});

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
                  _buildSearchBar(context),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(title: "Tour Requests"),
                  SizedBox(height: 16.h),
                  _buildTourRequestsList(),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(title: "Upcoming Bookings"),
                  SizedBox(height: 16.h),
                  _buildUpcomingBookingsList(),
                  SizedBox(height: 24.h),
                  _buildInviteBanner(),
                  SizedBox(height: 60.h), // Padding for bottom nav
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
            'assets/images/yaloo_logo.png', // Your logo
            width: 40.w,
            height: 40.h,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Hi, yalooguide',
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

  // --- 2. Search Bar ---
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: AppColors.primaryBlue, width: 1.w),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.primaryGray),
                  prefixIcon:
                  Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.primaryGray, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          CustomIconButton(
            onPressed: () { /* TODO: Handle filter */ },
            icon: Icon(FontAwesomeIcons.sliders,
                color: AppColors.primaryBlack, size: 24.w),
          ),
        ],
      ),
    );
  }

  // --- 3. Section Header ---
  Widget _buildSectionHeader({required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Handle "See All"
            },
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

  // --- 4. Tour Requests List ---
  Widget _buildTourRequestsList() {
    return SizedBox(
      height: 180.h, // Fixed height for the card
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tourRequests.length,
        itemBuilder: (context, index) {
          final request = tourRequests[index];
          return TourRequestCard(
            touristName: request['name'],
            touristImage: request['image'],
            touristCountryCode: request['countryCode'],
            duration: request['duration'],
            price: request['price'],
            guests: request['guests'],
            location: request['location'],
            onAccept: () { /* TODO: Handle Accept */ },
            onReject: () { /* TODO: Handle Reject */ },
          );
        },
      ),
    );
  }

  // --- 5. Upcoming Bookings List ---
  Widget _buildUpcomingBookingsList() {
    return SizedBox(
      height: 260.h, // Fixed height for this card
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: upcomingBookings.length,
        itemBuilder: (context, index) {
          final booking = upcomingBookings[index];
          return UpcomingBookingCard(
            title: booking['title'],
            location: booking['location'],
            guests: booking['guests'],
            date: booking['date'],
            duration: booking['duration'],
            price: booking['price'],
            imageUrl: booking['image'],
          );
        },
      ),
    );
  }

  // --- 6. Invite Banner ---
  Widget _buildInviteBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.thirdBlue,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invite your friends',
                  style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Earn 100 Yaloo Points',
                  style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () { /* TODO: Handle Invite */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text('INVITE'),
                )
              ],
            ),
          ),
          Icon(LucideIcons.gift, size: 100.w, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}