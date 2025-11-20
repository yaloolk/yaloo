import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

class HostStayRequestDetailsScreen extends StatefulWidget {
  const HostStayRequestDetailsScreen({super.key});

  @override
  State<HostStayRequestDetailsScreen> createState() =>
      _HostStayRequestDetailsScreenState();
}

class _HostStayRequestDetailsScreenState
    extends State<HostStayRequestDetailsScreen> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  Widget build(BuildContext context) {
    final requestData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    final String touristName = requestData['name'] ?? 'Emil Carter';
    final String touristImage =
        requestData['image'] ?? 'assets/images/tourist_3.jpg';
    final String country = requestData['country'] ?? 'Germany';
    final int guests = requestData['guests'] ?? 2;
    final String checkIn = requestData['checkIn'] ?? 'Dec 10, 2025';
    final String checkOut = requestData['checkOut'] ?? 'Dec 12, 2025';
    final String mealType = requestData['mealType'] ?? 'Non-Veg';
    final String note = requestData['note'] ?? 'We are friendly.';
    final double price = requestData['price'] ?? 20.0;
    final double nights = requestData['nights'] ?? 2.0;
    final double platformFee = requestData['fee'] ?? -6.0;
    final double total = requestData['total'] ?? 34.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Stay Request'),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildTouristInfoCard(touristName, touristImage, country),
                  SizedBox(height: 24.h),
                  _buildStayDetailsCard(
                      guests, checkIn, checkOut, mealType, note),
                  SizedBox(height: 24.h),
                  _buildPaymentSummaryCard(
                      price, nights, platformFee, total),
                  SizedBox(height: 200.h),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTouristInfoCard(
      String name, String image, String country) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      shadowColor: AppColors.primaryGray.withAlpha(20),
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
                  style: AppTextStyles.headlineLargeBlack.copyWith(
                      fontSize: 18.sp, fontWeight: FontWeight.bold),
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
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/touristPublicProfile');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 28.h),
                  Text(
                    'View Profile →',
                    style: AppTextStyles.textSmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStayDetailsCard(int guests, String checkIn, String checkOut,
      String mealType, String note) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      shadowColor: AppColors.primaryGray.withAlpha(20),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stay Details',
                style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            _buildDetailRow(FontAwesomeIcons.userGroup, '$guests Guests'),
            // _buildDetailRow(FontAwesomeIcons.calendar,
            //     'Check in: $checkIn   Check out: $checkOut'),
            _buildDetailRow(
              FontAwesomeIcons.calendar,
              'Check in: $checkIn',
            ),
            _buildDetailRow(
              FontAwesomeIcons.calendar,
              'Check out: $checkOut',
            ),
            _buildDetailRow(FontAwesomeIcons.bowlFood, mealType),
            _buildDetailRow(FontAwesomeIcons.noteSticky,
                'Special Note: "$note"', isNote: true),
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
          Icon(icon, size: 16.w, color: AppColors.primaryGray),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.textSmall.copyWith(
                color:
                isNote ? AppColors.primaryBlack : AppColors.primaryGray,
                fontStyle: isNote ? FontStyle.italic : FontStyle.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(
      double price, double nights, double fee, double total) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      shadowColor: AppColors.primaryGray.withAlpha(20),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment Summary',
                style: AppTextStyles.headlineLargeBlack.copyWith(
                    fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            _buildPaymentRow(
                'Rate/night:',
                '\$${price.toStringAsFixed(2)} x ${nights.toInt()} = \$${(price * nights).toStringAsFixed(2)}'),
            _buildPaymentRow('Platform Fee:', '-\$${fee.abs().toStringAsFixed(2)}'),
            Divider(
                height: 24.h,
                color: AppColors.secondaryGray.withOpacity(0.5)),
            _buildPaymentRow('Total Payout:', '\$${total.toStringAsFixed(2)}',
                isTotal: true),
          ],
        ),
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
                ? AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue)
                : AppTextStyles.textSmall
                .copyWith(color: AppColors.primaryGray),
          ),
          Text(
            amount,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue)
                : AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    bool isLoading = _isAccepting || _isDeclining;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.primaryBlack.withOpacity(0.92),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    setState(() => _isAccepting = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isAccepting
                      ? SizedBox(
                    height: 20.w,
                    width: 20.w,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text('Accept Request',
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                    setState(() => _isDeclining = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.primaryGray.withOpacity(0.3),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isDeclining
                      ? SizedBox(
                    height: 20.w,
                    width: 20.w,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text('Decline',
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.shieldHalved,
                  color: AppColors.primaryGray, size: 12.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Free cancellation up to 24h before check in.',
                  style: AppTextStyles.textSmall
                      .copyWith(color: AppColors.primaryGray),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.locationDot,
                  color: AppColors.primaryGray, size: 12.w),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Meet guests only at your verified stay location.',
                  style: AppTextStyles.textSmall
                      .copyWith(color: AppColors.primaryGray),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
