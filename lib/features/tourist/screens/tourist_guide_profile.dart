import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// --- IMPORT THE REUSABLE WIDGETS ---
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';

// --- MOCK DATA for this screen ---
final List<String> galleryImages = [
  "https://placehold.co/200x200/e9c46a/white?text=Gallery+1",
  "https://placehold.co/200x200/f4a261/white?text=Gallery+2",
  "https://placehold.co/200x200/e76f51/white?text=Gallery+3",
  "https://placehold.co/200x200/2a9d8f/white?text=Gallery+4",
];
// ---------------------------------

class GuideProfileScreen extends StatelessWidget {
  const GuideProfileScreen({Key? key}) : super(key: key);

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
            alignment: Alignment.center,
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

      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildProfileCard(context), // <-- Pass context
                _buildAboutSection(),
                _buildDetailsCard(),
                _buildGallerySection(),
                _buildReviewSection(),
                _buildSafetySection(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookingBar(context), // <-- Pass context
    );
  }

  // --- 2. The Main Profile Card ---
  Widget _buildProfileCard(BuildContext context) { // <-- Pass context
    return Container(
      transform: Matrix4.translationValues(0.0, 0.0, 0.0),
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
            radius: 50,
            backgroundImage: AssetImage("assets/images/guide_1.jpg"), // Use local asset
          ),
          const SizedBox(height: 12),
          Text(
            'Hadhi Ahmed',
            style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                '4.9 (128 reviews)',
                style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kandy, Sri Lanka',
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildVerfiedChip(),
              const Spacer(),
              _buildCheckAvailabilityButton(),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // --- UPDATED: Navigate to Booking Details ---
              Navigator.pushNamed(context, '/bookingDetails');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Book Guide',
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerfiedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.check, color: AppColors.primaryGreen, size: 14),
          const SizedBox(width: 6),
          Text(
            'Yaloo Verified Guide',
            style: AppTextStyles.textSmall.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
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
        children: [
          Text(
            'Check Availability',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(FontAwesomeIcons.calendarDay, color: AppColors.primaryBlue, size: 14),
        ],
      ),
    );
  }

  // --- 3. About Me Section ---
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About Me'),
          const SizedBox(height: 8),
          Text(
            'Ayubowan! I\'m John, a passionate storyteller and certified guide from the beautiful city of Kandy. With over 4 years of experience, I love sharing the hidden gems and rich culture of Sri Lanka with travelers from around the world. Let\'s create unforgettable memories together!',
            style: AppTextStyles.textSmall.copyWith(
              color: AppColors.primaryGray,
              fontSize: 15,
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
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDetailRow("Languages", "English, Sinhala, Tamil"),
          Divider(color: Colors.grey.shade300, height: 24),
          _buildDetailRow("Experience", "2 Years"),
          Divider(color: Colors.grey.shade300, height: 24),
          _buildDetailRow("Guide Since", "June 2025"),
          Divider(color: Colors.grey.shade300, height: 24),
          _buildDetailRow("Tour Completed", "20+"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // --- 5. Gallery Section ---
  Widget _buildGallerySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 0, 16), // Left padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Gallery'),
          const SizedBox(height: 16),
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: galleryImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ratings & Reviews'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '4.9',
                style: AppTextStyles.headlineLargeBlack.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStarRating(4.9),
                  const SizedBox(height: 4),
                  Text(
                    'Based on 128 reviews',
                    style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRatingBars(),
          const SizedBox(height: 24),
          _buildSingleReview(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () { /* TODO: See All Reviews */ },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.thirdBlue,
              foregroundColor: AppColors.primaryBlue,
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? FontAwesomeIcons.solidStar :
          (index < rating ? FontAwesomeIcons.starHalfAlt : FontAwesomeIcons.star),
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingBars() {
    return Column(
      children: [
        _buildRatingBar("5", 0.8),
        _buildRatingBar("4", 0.6),
        _buildRatingBar("3", 0.3),
        _buildRatingBar("2", 0.1),
        _buildRatingBar("1", 0.05),
      ],
    );
  }

  Widget _buildRatingBar(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.secondaryGray,
                color: AppColors.primaryBlue,
                minHeight: 8,
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
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.secondaryGray)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage("assets/images/guide_2.jpg"), // Use local asset
                ),
                const SizedBox(width: 12),
                Text(
                  'Sarah Johnson',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'An absolutely incredible experience! Hadhi is so knowledgeable and friendly. He showed us places we never would have found on our own. Highly recommended!',
              style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  // --- 7. Safety Section ---
  Widget _buildSafetySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Safety & Verification'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.shieldHalved, color: AppColors.primaryGreen, size: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Status',
                      style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Verified by Yaloo',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
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
  Widget _buildBookingBar(BuildContext context) { // <-- Pass context
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Price per person',
                style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // --- UPDATED: Navigate to Booking Details ---
              Navigator.pushNamed(context, '/bookingDetails');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}