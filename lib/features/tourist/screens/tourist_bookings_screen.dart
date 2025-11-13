import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// --- MOCK DATA for the list ---
final List<Map<String, dynamic>> userBookings = [
  {
    "id": "bk001",
    "guideName": "Sarath Kumara",
    "guideImage": "assets/images/guide_3.jpg",
    "date": "Nov 10, 2025",
    "status": "completed" // <-- NEW COMPLETED STATUS
  },
  {
    "id": "bk123",
    "guideName": "Hadhi Ahamed",
    "guideImage": "assets/images/guide_1.jpg",
    "date": "Nov 15, 2025",
    "status": "confirmed"
  },
  {
    "id": "bk456",
    "guideName": "Hisham",
    "guideImage": "assets/images/guide_2.jpg",
    "date": "Nov 22, 2025",
    "status": "pending"
  },
  {
    "id": "bk789",
    "guideName": "Dasun",
    "guideImage": "assets/images/guide_2.jpg",
    "date": "Nov 18, 2025",
    "status": "declined"
  },
];
// -----------------------------

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: AppTextStyles.headlineLargeBlack
              .copyWith(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100), // Padding for chat button
        itemCount: userBookings.length,
        itemBuilder: (context, index) {
          final booking = userBookings[index];
          return _buildBookingListCard(context, booking);
        },
      ),
    );
  }

  Widget _buildBookingListCard(
      BuildContext context, Map<String, dynamic> booking) {
    // Determine color and text based on status
    Map<String, dynamic> statusInfo;
    switch (booking['status']) {
      case 'completed':
        statusInfo = {
          "text": "Completed",
          "color": AppColors.primaryBlack,
          "icon": FontAwesomeIcons.circleCheck
        };
        break;
      case 'confirmed':
        statusInfo = {
          "text": "Confirmed",
          "color": AppColors.primaryGreen,
          "icon": FontAwesomeIcons.check
        };
        break;
      case 'declined':
        statusInfo = {
          "text": "Declined",
          "color": AppColors.primaryRed,
          "icon": FontAwesomeIcons.xmark
        };
        break;
      default:
        statusInfo = {
          "text": "Pending",
          "color": const Color(0xFFB45309), // Dark yellow
          "icon": FontAwesomeIcons.clock
        };
    }

    return Card(
      elevation: 4,
      shadowColor: AppColors.primaryGray.withAlpha(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          // --- UPDATED NAVIGATION ---
          if (booking['status'] == 'completed') {
            // If completed, go to the review screen
            Navigator.pushNamed(
              context,
              '/tourCompletion',
              arguments: booking,
            );
          } else {
            // Otherwise, go to the status screen
            Navigator.pushNamed(
              context,
              '/bookingStatus',
              arguments: booking,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(booking['guideImage']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['guideName'],
                      style: AppTextStyles.bodyLarge
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking['date'],
                      style: AppTextStyles.textSmall
                          .copyWith(color: AppColors.primaryGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusInfo['color'].withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(statusInfo['icon'], size: 12, color: statusInfo['color']),
                    const SizedBox(width: 6),
                    Text(
                      statusInfo['text'],
                      style: AppTextStyles.textSmall.copyWith(
                        color: statusInfo['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}