import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

class TourCompletionScreen extends StatefulWidget {
  const TourCompletionScreen({super.key});

  @override
  State<TourCompletionScreen> createState() => _TourCompletionScreenState();
}

class _TourCompletionScreenState extends State<TourCompletionScreen> {
  int _starRating = 0;
  final _reviewController = TextEditingController();
  final Set<String> _selectedChips = {};
  final List<String> _reviewChips = ["Friendly", "Knowledgable", "Fun", "Safe"];

  // --- MOCK DATA (Would be passed as arguments) ---
  final String guideName = "Mohamed";
  final String guideImage = "assets/images/guide_1.jpg";
  final String guideRating = "4.8";
  final String tourLocation = "Ella";
  final String duration = "4 hours";
  final String amount = "\$20";
  // ------------------------------------------------

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: '', // No title
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryBlack, size: 24.w),
        ),
        actions: [
          IconButton(
            onPressed: () { /* TODO: Show Help */ },
            icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildHeaderIcon(),
              SizedBox(height: 24.h),
              Text(
                'Tour Completed! 🎉',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 28.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Text(
                'We hope you had an amazing experience with Yaloo!',
                textAlign: TextAlign.center,
                style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 16.sp, height: 1.5.h),
              ),
              SizedBox(height: 32.h),
              _buildSummaryCard(),
              SizedBox(height: 24.h),
              _buildRatingCard(),
              SizedBox(height: 24.h),
              _buildAppreciationCard(),
              SizedBox(height: 24.h),
              _buildFooterButtons(),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryBlue.withAlpha(25),
      ),
      child: Icon(
        FontAwesomeIcons.check,
        color: AppColors.primaryBlue,
        size: 48.w,
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 6,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(radius: 24.r, backgroundImage: AssetImage(guideImage)),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("GUIDE", style: AppTextStyles.textExtraSmall.copyWith(color: AppColors.primaryGray, fontWeight: FontWeight.bold)),
                    Text(guideName, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
                  ],
                ),
                Spacer(),
                Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 14.w),
                SizedBox(width: 4.w),
                Text(guideRating, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
              ],
            ),
            Divider(height: 32.h, color: AppColors.secondaryGray.withOpacity(0.5)),
            _buildDetailRow("Tour", tourLocation),
            _buildDetailRow("Duration", duration),
            _buildDetailRow("Amount", amount),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
          Text(value, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRatingCard() {
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
              'Rate Your Experience',
              style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        _starRating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _starRating ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                      color: Colors.amber,
                      size: 32.w,
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'How was your Guide?',
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.secondaryGray),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Share details of your own experience....',
                  hintStyle: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12.w),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _reviewChips.map((chip) {
                final isSelected = _selectedChips.contains(chip);
                return ChoiceChip(
                  label: Text(chip),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedChips.add(chip);
                      } else {
                        _selectedChips.remove(chip);
                      }
                    });
                  },
                  labelStyle: AppTextStyles.textSmall.copyWith(
                    color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedColor: AppColors.thirdBlue,
                  backgroundColor: AppColors.secondaryGray.withOpacity(0.5),
                  shape: StadiumBorder(),
                );
              }).toList(),
            ),
            SizedBox(height: 20.h),
            CustomPrimaryButton(
              text: 'Submit Review',
              onPressed: () {
                // TODO: Handle Submit Review Logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppreciationCard() {
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
              'Show your Appreciation',
              style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              'Send your guide a small tip as a thank-you gesture.',
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 15.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () { /* TODO: Open Tip Modal */ },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.thirdBlue,
                foregroundColor: AppColors.primaryBlue,
                elevation: 0,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Give a Tip',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(FontAwesomeIcons.solidHeart, color: AppColors.primaryBlue, size: 16.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () { /* TODO: Handle Save to Favorites */ },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF701a75), // Dark Pink/Purple
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.solidHeart, color: Colors.white, size: 16.w),
              SizedBox(width: 10.w),
              Text(
                'Save this Guide to Favorites',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: () { /* TODO: Handle Share */ },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf3e8ff), // Light Purple
            foregroundColor: const Color(0xFF701a75), // Dark Pink/Purple
            elevation: 0,
            minimumSize: Size(double.infinity, 52.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.share, color: Color(0xFF701a75), size: 16.w),
              SizedBox(width: 10.w),
              Text(
                'Share Your Experience',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF701a75),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}