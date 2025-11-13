import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';

// --- MOCK DATA for "Similar Guides" ---
final List<Map<String, String>> similarGuides = [
  {"name": "Dasun", "rating": "4.8", "image": "assets/images/guide_2.jpg"},
  {"name": "Dilshan", "rating": "4.7", "image": "assets/images/guide_3.jpg"},
];
// ------------------------------------

class BookingStatusScreen extends StatelessWidget {
  const BookingStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Receive booking data ---
    final bookingData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String status = bookingData['status'] ?? 'confirmed';

    // --- Fill data from arguments ---
    final String guideName = bookingData['guideName'] ?? 'Mohamed';
    final String guideImage = bookingData['guideImage'] ?? 'assets/images/guide_1.jpg';
    final String rating = bookingData['rating'] ?? '4.8';
    final String date = bookingData['date'] ?? 'Oct 25, 2025';
    final String time = bookingData['time'] ?? '10:00 AM';
    final String duration = bookingData['duration'] ?? '4 hours';
    final String total = (bookingData['total'] as double? ?? 20.0).toStringAsFixed(2);
    final String meetingPoint = bookingData['meetingPoint'] ?? 'Ella Train Station';
    // ------------------------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Booking Details',
        actions: [
          IconButton(
            onPressed: () { /* TODO: Show Help */ },
            icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryBlack, size: 24),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              // --- DYNAMICALLY SHOW UI BASED ON STATUS ---
              if (status == 'confirmed')
                _buildConfirmedUI(context, guideName, guideImage, rating, date, time, duration, total, meetingPoint)
              else if (status == 'declined')
                _buildDeclinedUI(context, guideName)
              else
                _buildPendingUI(guideName, guideImage, date, time, total),
              // ------------------------------------------
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),

      floatingActionButton: const FloatingChatButton(),
    );
  }

  // --- UI for PENDING (image_356afc.png) ---
  Widget _buildPendingUI(String name, String image, String date, String time, String total) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryBlue.withAlpha(25),
          ),
          child: Icon(FontAwesomeIcons.check, color: AppColors.primaryBlue, size: 48.w),
        ),
         SizedBox(height: 24.h),
        Text(
          'Booking Request Sent!',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 28.sp, fontWeight: FontWeight.bold),
        ),
         SizedBox(height: 16.h),
        Text(
          'Your booking request is pending. Payment is securely held and will only be charged once confirmed.',
          textAlign: TextAlign.center,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 16.sp, height: 1.5.h),
        ),
         SizedBox(height: 32.h),
        _buildBookingSummaryCard(name, image, date, time, total),
         SizedBox(height: 24.h),
        ElevatedButton(
          onPressed: () { /* TODO: Handle Cancel Request */ },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryRed,
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: BorderSide(color: AppColors.secondaryGray, width: 1.5.h),
            ),
            elevation: 0,
          ),
          child: Text(
            'Cancel Request',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- UI for CONFIRMED (image_35dafe.png) ---
  Widget _buildConfirmedUI(BuildContext context, String name, String image, String rating, String date, String time, String duration, String total, String meetingPoint) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen.withAlpha(25), // Green background
          ),
          child: Icon(FontAwesomeIcons.check, color: AppColors.primaryGreen, size: 48.w),
        ),
         SizedBox(height: 24.h),
        Text(
          'Booking Confirmed! 🎉',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 28.sp, fontWeight: FontWeight.bold),
        ),
         SizedBox(height: 16.h),
        Text(
          'Your booking with $name (Guide) is confirmed! Payment has been processed successfully.',
          textAlign: TextAlign.center,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 16.sp, height: 1.5.h),
        ),
         SizedBox(height: 32.h),
        _buildBookingDetailsCard(name, image, rating, date, time, duration, total, meetingPoint),
         SizedBox(height: 24.h),
        CustomPrimaryButton(
          text: 'Chat with Guide',
          onPressed: () {
            // TODO: Navigate to chat with this guide
            // You'll need to pass the guide's UID
            // Navigator.pushNamed(context, '/chatDetail', arguments: {'guideId': ...});
          },
        ),
         SizedBox(height: 16.h),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/touristDashboard'), // Go back to tab root
          child: Text(
            'Return Home',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- UI for DECLINED (image_3fc447.png) ---
  Widget _buildDeclinedUI(BuildContext context, String guideName) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryRed.withAlpha(25), // Red background
          ),
          child: Icon(FontAwesomeIcons.calendarXmark, color: AppColors.primaryRed, size: 48.w),
        ),
         SizedBox(height: 24.h),
        Text(
          'Your Booking Was Declined',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 28.sp, fontWeight: FontWeight.bold),
        ),
         SizedBox(height: 16.h),
        Text(
          '$guideName wasn\'t available this time. Don\'t worry, there are many other amazing guides ready to show you around.',
          textAlign: TextAlign.center,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 16.sp, height: 1.5.h),
        ),
         SizedBox(height: 32.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Similar Guides in Kandy', // TODO: Make this dynamic
            style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
         SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildSimilarGuideCard(similarGuides[0])),
             SizedBox(width: 16.h),
            Expanded(child: _buildSimilarGuideCard(similarGuides[1])),
          ],
        ),
         SizedBox(height: 32.h),
        CustomPrimaryButton(
          text: 'Explore Other Guides',
          onPressed: () {
            // Go back to the "Find Guide" screen
            Navigator.popUntil(context, (route) => route.settings.name == '/findGuide');
          },
        ),
         SizedBox(height: 16.h),
        TextButton(
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), // Go back to tab root
          child: Text(
            'Return Home',
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // --- Reusable Card for Pending Status ---
  Widget _buildBookingSummaryCard(String name, String image, String date, String time, String total) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24.r, backgroundImage: AssetImage(image)),
                 SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("GUIDE", style: AppTextStyles.textExtraSmall.copyWith(color: AppColors.primaryGray, fontWeight: FontWeight.bold)),
                    Text(name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
             SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(date, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack)),
                     SizedBox(height: 4.h),
                    Text(time, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
                  ],
                ),
                Text("\$$total", style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold)),
              ],
            ),
             SizedBox(height: 20.h),
            Container(
              padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1), // Light yellow
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(FontAwesomeIcons.clock, color: const Color(0xFFF59E0B), size: 16.w),
                   SizedBox(width: 8.w),
                  Text(
                    'Pending Confirmation',
                    style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFFB45309), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Card for Confirmed Status ---
  Widget _buildBookingDetailsCard(String name, String image, String rating, String date, String time, String duration, String total, String meetingPoint) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24.r, backgroundImage: AssetImage(image)),
                 SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
                     SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 14.w),
                         SizedBox(width: 4.w),
                        Text(rating, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 32, color: AppColors.secondaryGray),
            _buildDetailRow(FontAwesomeIcons.calendar, "Date", date),
            _buildDetailRow(FontAwesomeIcons.clock, "Time", time),
            _buildDetailRow(FontAwesomeIcons.hourglassHalf, "Duration", duration),
            _buildDetailRow(FontAwesomeIcons.dollarSign, "Total Amount", "\$$total"),
            _buildDetailRow(FontAwesomeIcons.mapPin, "Meeting Point", meetingPoint),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGray, size: 16.w),
           SizedBox(width: 12.w),
          Text(title, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Reusable Card for Declined Status ---
  Widget _buildSimilarGuideCard(Map<String, String> guide) {
    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryGray.withAlpha(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:  BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Image.asset(guide['image']!, height: 120, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(guide['name']!, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                 SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 12.w),
                     SizedBox(width: 4.h),
                    Text(guide['rating']!, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}