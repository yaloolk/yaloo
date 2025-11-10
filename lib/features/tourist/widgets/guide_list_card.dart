import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class GuideListCard extends StatelessWidget {
  final String name;
  final String location;
  final String rating;
  final String imageUrl;
  final List<String> languages;
  final List<String> specialties;
  final bool isAvailable;
  // --- ADDED: We need the full data to pass ---
  final Map<String, dynamic> guideData;

  const GuideListCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.languages,
    required this.specialties,
    required this.isAvailable,
    required this.guideData, // --- ADDED ---
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: AppColors.primaryWhite,
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(width: 80, height: 80, color: AppColors.secondaryGray),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildInfoRow(CupertinoIcons.map_pin, location),
                      const SizedBox(height: 6),
                      _buildInfoRow(FontAwesomeIcons.language, languages.join(', ')),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        CupertinoIcons.star_fill,
                        rating,
                        iconColor: Colors.amber,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSpecialties(),
            const SizedBox(height: 12),
            Divider(color: AppColors.secondaryGray),
            const SizedBox(height: 8),
            _buildActionButtons(context), // <-- Pass context
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: AppTextStyles.headlineLargeBlack.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildAvailabilityChip(),
      ],
    );
  }

  Widget _buildAvailabilityChip() {
    final color = isAvailable ? AppColors.primaryGreen : AppColors.primaryRed;
    final bgColor = isAvailable ? AppColors.secondaryGreen : AppColors.primaryRed.withAlpha(20);
    final icon = isAvailable ? CupertinoIcons.checkmark_alt : CupertinoIcons.xmark;
    final text = isAvailable ? 'Available' : 'Not Available';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.textExtraSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? AppColors.primaryGray),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialties() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: specialties.map((specialty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.thirdBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              specialty,
              style: AppTextStyles.textSmall.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) { // <-- Pass context
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            // TODO: Handle Favorite
          },
          icon: Icon(CupertinoIcons.heart, color: AppColors.primaryGray),
        ),
        TextButton(
          onPressed: () {
            // --- UPDATED: Navigate to Guide Profile ---
            Navigator.pushNamed(
              context,
              '/touristGuideProfile',
              arguments: guideData, // <-- Pass the guide's data
            );
          },
          child: Text(
            'Profile',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primaryGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // --- UPDATED: Navigate to Booking Details ---
            if (isAvailable) {
              Navigator.pushNamed(
                  context,
                  '/bookingDetails',
                  arguments: { // Pass just what the booking page needs
                    'name': name,
                    'image': imageUrl,
                  }
              );
            }
            else{

            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          child: Text(
            'Book',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}