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

  const GuideListCard({
    Key? key,
    required this.name,
    required this.location,
    required this.rating,
    required this.imageUrl,
    required this.languages,
    required this.specialties,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      color: Colors.white,
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameAndRating(),
                      const SizedBox(height: 6),
                      _buildInfoRow(FontAwesomeIcons.mapPin, location),
                      const SizedBox(height: 6),
                      _buildInfoRow(FontAwesomeIcons.language, languages.join(', ')),
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
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameAndRating() {
    return Row(
      children: [
        Text(
          name,
          style: AppTextStyles.headlineLargeBlack.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 14),
        const SizedBox(width: 4),
        Text(
          rating,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryGray),
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
    return Wrap(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            // TODO: Handle Favorite
          },
          icon: Icon(FontAwesomeIcons.heart, color: AppColors.primaryGray),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to Guide Profile
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
            // TODO: Handle Book
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