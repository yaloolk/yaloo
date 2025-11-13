import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// --- IMPORT THE REUSABLE WIDGETS ---
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';

// --- MOCK DATA for this screen ---
final List<String> galleryImages = [
  "assets/images/sigiriya.jpg",
  "https://placehold.co/200x200/f4a261/white?text=Gallery+2",
  "https://placehold.co/200x200/e76f51/white?text=Gallery+3",
  "https://placehold.co/200x200/2a9d8f/white?text=Gallery+4",
];
// ---------------------------------

class GuideProfileScreen extends StatelessWidget {
  const GuideProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Receive Guide data from arguments ---
    final guideData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String guideName = guideData['name'] ?? "Mohamed";
    final String guideImage = guideData['image'] ?? "assets/images/guide_1.png";
    final String guideLocation = guideData['location'] ?? "Kandy, Sri Lanka";
    final String guideRating = guideData['rating'] ?? "4.6";
    // --------------------------------------------------

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Guide Profile',
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

      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    SizedBox(height: 24.h),
                    _buildProfileCard(context, guideName, guideImage),
                    _buildAboutSection(),
                    _buildDetailsCard(),
                    _buildGallerySection(),
                    _buildReviewSection(),
                    _buildSafetySection(),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBookingBar(context, guideName, guideImage),
    );
  }

  // --- 2. The Main Profile Card ---
  Widget _buildProfileCard(BuildContext context, String name, String image) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(50),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundImage: AssetImage("assets/images/guide_1.jpg"),
          ),
          SizedBox(height: 12.h),
          Text(
            'Mohamed',
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 16.w),
              SizedBox(width: 8.w),
              Text(
                '4.9 (128 reviews)',
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Kandy, Sri Lanka',
            style: AppTextStyles.textSmall.copyWith(
              color: AppColors.primaryGray,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          // Improved responsive layout for chips and button
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 400.w) {
                // For wider screens - horizontal layout
                return Row(
                  children: [
                    _buildVerifiedChip(),
                    const Spacer(),
                    _buildCheckAvailabilityButton(),
                  ],
                );
              } else {
                // For narrower screens - vertical layout
                return Column(
                  children: [
                    _buildVerifiedChip(),
                    SizedBox(height: 12.h),
                    _buildCheckAvailabilityButton(),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                  context,
                  '/bookingDetails',
                  arguments: { 'name': name, 'image': image, 'bookingType': 'guide'}
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Book Guide',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.checkmark_alt, color: AppColors.primaryGreen, size: 14.w),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'Yaloo Verified Guide',
              style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckAvailabilityButton() {
    return TextButton(
      onPressed: () { /* TODO: Check Availability */ },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              'Check Availability',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(CupertinoIcons.calendar_today, color: AppColors.primaryBlue, size: 16.w),
        ],
      ),
    );
  }

  // --- 3. About Me Section ---
  Widget _buildAboutSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About Me'),
          SizedBox(height: 12.h),
          Text(
            'Ayubowan! I\'m John, a passionate storyteller and certified guide from the beautiful city of Kandy. With over 4 years of experience, I love sharing the hidden gems and rich culture of Sri Lanka with travelers from around the world. Let\'s create unforgettable memories together!',
            style: AppTextStyles.textSmall.copyWith(
              color: AppColors.primaryGray,
              fontSize: 15.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Details Card ---
  Widget _buildDetailsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildDetailRow("Languages", "English, Tamil"),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade300, height: 1.h),
          SizedBox(height: 16.h),
          _buildDetailRow("Experience", "2 Years"),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade300, height: 1.h),
          SizedBox(height: 16.h),
          _buildDetailRow("Guide Since", "June 2025"),
          SizedBox(height: 16.h),
          Divider(color: Colors.grey.shade300, height: 1.h),
          SizedBox(height: 16.h),
          _buildDetailRow("Tour Completed", "20+"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- 5. Gallery Section ---
  Widget _buildGallerySection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Gallery'),
          SizedBox(height: 16.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120.w,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    image: DecorationImage(
                      image: NetworkImage(galleryImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Ratings & Reviews Section ---
  Widget _buildReviewSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ratings & Reviews'),
          SizedBox(height: 16.h),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 350.w) {
                // Horizontal layout for wider screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4.9',
                      style: AppTextStyles.headlineLargeBlack.copyWith(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStarRating(4.9),
                        SizedBox(height: 4.h),
                        Text(
                          'Based on 128 reviews',
                          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                        ),
                      ],
                    ),
                  ],
                );
              } else {
                // Vertical layout for narrower screens
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4.9',
                      style: AppTextStyles.headlineLargeBlack.copyWith(
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildStarRating(4.9),
                    SizedBox(height: 4.h),
                    Text(
                      'Based on 128 reviews',
                      style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                    ),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 16.h),
          _buildRatingBars(),
          SizedBox(height: 24.h),
          _buildSingleReview(),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () { /* TODO: See All Reviews */ },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.thirdBlue,
              foregroundColor: AppColors.primaryBlue,
              elevation: 0,
              minimumSize: Size(double.infinity, 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'See All 128 Reviews',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? CupertinoIcons.star_fill :
          (index < rating ? CupertinoIcons.star_lefthalf_fill : CupertinoIcons.star_fill),
          color: Colors.amber,
          size: 16.w,
        );
      }),
    );
  }

  Widget _buildRatingBars() {
    return Column(
      children: [
        _buildRatingBar("5", 0.8),
        SizedBox(height: 4.h),
        _buildRatingBar("4", 0.6),
        SizedBox(height: 4.h),
        _buildRatingBar("3", 0.3),
        SizedBox(height: 4.h),
        _buildRatingBar("2", 0.1),
        SizedBox(height: 4.h),
        _buildRatingBar("1", 0.05),
      ],
    );
  }

  Widget _buildRatingBar(String label, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            child: Text(
                label,
                style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.secondaryGray,
                color: AppColors.primaryBlue,
                minHeight: 8.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleReview() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: AppColors.secondaryGray)
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: AssetImage("assets/images/guide_2.jpg"),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Sarah Johnson',
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'An absolutely incredible experience! Mohamed is so knowledgeable and friendly. He showed us places we never would have found on our own. Highly recommended!',
              style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryGray,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 7. Safety Section ---
  Widget _buildSafetySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Safety & Verification'),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.checkmark_shield_fill, color: AppColors.primaryGreen, size: 24.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Status',
                        style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Verified by Yaloo',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Verified',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 8. Sticky Bottom Booking Bar ---
  Widget _buildBookingBar(BuildContext context, String name, String image) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$20 / hour',
                style: AppTextStyles.headlineLargeBlack.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Price per person',
                style: AppTextStyles.textSmall.copyWith( fontSize: 12.sp, color: AppColors.primaryGray),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                  context,
                  '/bookingDetails',
                  arguments: { 'name': name, 'image': image, 'bookingType': 'guide'}
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            ),
            child: Text(
              'Request Booking',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Section Title ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headlineLargeBlack.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}