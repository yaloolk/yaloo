import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import 'package:yaloo/features/host/widgets/stay_request_card.dart';
import 'package:yaloo/features/host/widgets/upcoming_stay_card.dart';

import '../widgets/host_stay_details_dialog.dart';

// --- MOCK DATA ---
final List<Map<String, dynamic>> stayRequests = [
  {
    "name": "Emil Carter",
    "image": "assets/images/tourist_1.jpg",
    "countryCode": "DE",
    "duration": "2 nights",
    "price": "\$72",
    "guests": 3,
    "rooms": 2,
    "date": "Check-in Jun 14"
  },
  {
    "name": "Maria",
    "image": "assets/images/tourist_2.jpg",
    "countryCode": "US",
    "duration": "1 night",
    "price": "\$36",
    "guests": 2,
    "rooms": 1,
    "date": "Check-in Jun 15"
  },
];

final List<Map<String, dynamic>> upcomingStays = [
  {
    "title": "Emma",
    "guests": 1,
    "date": "10 JUNE",
    "duration": "1 Night",
    "price": "\$20",
    "checkIn": "Check-in Jun 10",
    "image": "assets/images/tourist_3.jpg"
  },
  {
    "title": "Chloe",
    "guests": 2,
    "date": "12 JUNE",
    "duration": "2 Nights",
    "price": "\$40",
    "checkIn": "Check-in Jun 12",
    "image": "assets/images/tourist_4.jpg"
  },
];
// -----------------

class HostHomeScreen extends StatelessWidget {
  const HostHomeScreen({super.key});

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
                  _buildSectionHeader(context: context, title: "Stay Requests"),
                  SizedBox(height: 16.h),
                  _buildStayRequestsList(),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(context: context, title: "Upcoming Stays"),
                  SizedBox(height: 16.h),
                  _buildUpcomingStaysList(),
                  SizedBox(height: 24.h),
                  _buildInviteBanner(),
                  SizedBox(height: 60.h),
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
              'Hi, yaloohost',
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
  Widget _buildSectionHeader({required BuildContext context, required String title}) {
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
              if (title == "Stay Requests") {

                Navigator.pushNamed(context, '/hostStayRequests');
              } else if (title == "Upcoming Stays") {
                // TODO: Navigate to All Bookings
                Navigator.pushNamed(context, '/hostBookings');
              }
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

  // --- 4. Stay Requests List ---
  Widget _buildStayRequestsList() {
    return SizedBox(
      // FIX: Increased height to 210.h to prevent bottom overflow/shadow clipping
      height: 210.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stayRequests.length,
        itemBuilder: (context, index) {
          final request = stayRequests[index];
          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0.w : 0.w),
            // CRITICAL FIX: Wrapped in SizedBox(width: 310.w)
            // This is required because the card is inside a horizontal ListView.
            // Without this, the card tries to expand infinitely and crashes.
            child: SizedBox(
              width: 310.w,
              child: StayRequestCard(
                touristName: request['name'],
                touristImage: request['image'],
                touristCountryCode: request['countryCode'],
                duration: request['duration'],
                price: request['price'],
                guests: request['guests'],
                rooms: request['rooms'],
                date: request['date'],
                onAccept: () { /* TODO */ },
                onReject: () { /* TODO */ },
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 5. Upcoming Stays List ---
  Widget _buildUpcomingStaysList() {
    return SizedBox(
      height: 260.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: upcomingStays.length,
        itemBuilder: (context, index) {
          final stay = upcomingStays[index];

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0.w : 8.w),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return HostStayRequestDetails(
                      data: {
                        'guestName': stay['title'] ?? '',
                        'guestImage': stay['image'] ?? '',
                        'status': stay['status'] ?? 'Confirmed',

                        'stayDates': stay['date'] ?? '',
                        'family': '${stay['guests']} Guests',

                        'checkIn': stay['checkIn'] ?? '',
                        'checkOut': stay['checkOut'] ?? '',

                        'meal': stay['meal'] ?? 'Non Veg',
                        'note': stay['note'] ?? '',

                        'rate': '\$${stay['price']} x ${stay['duration']}',
                        'fee': '-\$4',
                        'total': stay['price'] ?? 0
                      },
                    );
                  },
                );
              },
              child: UpcomingStayCard(
                title: stay['title'] ?? '',
                guests: stay['guests'] ?? 0,
                date: stay['date'] ?? '',
                duration: stay['duration'] ?? 0,
                price: stay['price'] ?? 0,
                imageUrl: stay['image'] ?? '',
                checkInDate: stay['checkIn'] ?? '',
              ),
            ),
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
          SizedBox(width: 10.w),
          Icon(LucideIcons.gift, size: 80.w, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}