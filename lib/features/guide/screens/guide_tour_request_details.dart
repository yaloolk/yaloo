import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class GuideTourRequestDetailsScreen extends StatefulWidget {
  const GuideTourRequestDetailsScreen({super.key});

  @override
  State<GuideTourRequestDetailsScreen> createState() =>
      _GuideTourRequestDetailsScreenState();
}

class _GuideTourRequestDetailsScreenState
    extends State<GuideTourRequestDetailsScreen> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  Widget build(BuildContext context) {
    // --- Receive tour request data ---
    final requestData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    // --- Fill data from arguments ---
    final String touristName = requestData['name'] ?? 'Emil Carter';
    final String touristImage =
        requestData['image'] ?? 'assets/images/tourist_3.jpg';
    final String touristCountryCode = requestData['countryCode'] ?? 'DE';
    final String touristCountryName = "Germany"; // TODO: Pass this or get from code
    final int guests = requestData['guests'] ?? 2;
    final String location = requestData['location'] ?? 'Ella';
    final String date = "October 05, 2025"; // TODO: Pass this
    final String time = "10:00 AM - 2:00 PM"; // TODO: Pass this
    final String meetingPoint = "Ella Station"; // TODO: Pass this
    final String note = "We'd love to see hike Ella mountain."; // TODO: Pass this
    final double rate = 10.0; // TODO: Pass this
    final double duration = 4.0; // TODO: Pass this
    final double platformFee = -4.0; // TODO: Pass this
    final double totalPayout = 36.0; // TODO: Pass this
    // ------------------------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Tour Request',
      ),
      // --- UPDATED: Use a Stack for the sticky bottom bar ---
      body: Stack(
        children: [
          // --- 1. Scrollable Content ---
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildTouristInfoCard(
                      touristName, touristImage, touristCountryName),
                  SizedBox(height: 24.h),
                  _buildTourDetailsCard(
                      location, date, time, guests, meetingPoint, note),
                  SizedBox(height: 24.h),
                  _buildPaymentSummaryCard(rate, duration, platformFee, totalPayout),
                  // --- ADDED: Padding at the bottom ---
                  // This must be taller than the black action bar
                  SizedBox(height: 180.h),
                ],
              ),
            ),
          ),

          // --- 2. Sticky Bottom Action Bar ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
      // --- REMOVED bottomNavigationBar ---
      // The parent dashboard provides the main nav bar & chat button
    );
  }

  Widget _buildTouristInfoCard(
      String name, String image, String country) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundImage: NetworkImage(image),
            ),
            SizedBox(width: 16.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headlineLargeBlack
                      .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  country,
                  style: AppTextStyles.textSmall
                      .copyWith(color: AppColors.primaryGray),
                ),
              ],
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 28.h),
                Text(
                  'View Profile →',
                  style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourDetailsCard(String location, String date, String time,
      int guests, String meetingPoint, String note) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tour Details',
              style: AppTextStyles.headlineLargeBlack
                  .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildDetailRow(FontAwesomeIcons.mapPin, location),
            _buildDetailRow(FontAwesomeIcons.calendar, '$date, $time'),
            _buildDetailRow(FontAwesomeIcons.userGroup, '$guests Guests'),
            _buildDetailRow(FontAwesomeIcons.locationArrow, meetingPoint),
            _buildDetailRow(FontAwesomeIcons.noteSticky, 'Special Note: "$note"', isNote: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
      double rate, double duration, double fee, double total) {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: AppTextStyles.headlineLargeBlack
                  .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            _buildPaymentRow("Rate/hour:",
                "\$${rate.toStringAsFixed(2)} x ${duration.toInt()}h = \$${(rate * duration).toStringAsFixed(2)}"),
            _buildPaymentRow("Platform Fee (10%):", "-\$${fee.abs().toStringAsFixed(2)}"),
            Divider(height: 24.h, color: AppColors.secondaryGray.withOpacity(0.5)),
            _buildPaymentRow("Total Payout:", "\$${total.toStringAsFixed(2)}",
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isNote = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGray, size: 16.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSmall.copyWith(
                color: isNote ? AppColors.primaryBlack : AppColors.primaryGray,
                fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
                : AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          ),
          Text(
            amount,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)
                : AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    bool isLoading = _isAccepting || _isDeclining;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h), // Padding for safe area
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    // TODO: Handle Accept
                    setState(() => _isAccepting = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isAccepting
                      ? SizedBox(height: 20.w, width: 20.w, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Accept Request', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : () {
                    // TODO: Handle Decline
                    setState(() => _isDeclining = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGray.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isDeclining
                      ? SizedBox(height: 20.w, width: 20.w, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Decline', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(FontAwesomeIcons.shieldHalved, color: AppColors.primaryGray, size: 12.w),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'Free cancellation up to 24h before tour.',
                  style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(FontAwesomeIcons.locationArrow, color: AppColors.primaryGray, size: 12.w),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'Meet only at safe & agreed locations.',
                  style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}