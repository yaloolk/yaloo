import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/guide/widgets/tour_request_card.dart';

// --- MOCK DATA (Same as your home screen) ---
final List<Map<String, dynamic>> tourRequests = [
  {
    "name": "Emil Carter",
    "image": "assets/images/tourist_1.jpg",
    "countryCode": "DE",
    "duration": "4h",
    "price": "\$36",
    "guests": 2,
    "location": "Ella"
  },
  {
    "name": "Michael",
    "image": "assets/images/tourist_2.jpg",
    "countryCode": "IE",
    "duration": "4h",
    "price": "\$20",
    "guests": 1,
    "location": "Sigiriya"
  },
  {
    "name": "Sarah",
    "image": "assets/images/tourist_3.jpg",
    "countryCode": "IN",
    "duration": "8h",
    "price": "\$70",
    "guests": 2,
    "location": "Kandy"
  },
];
// -----------------

class GuideTourRequestsScreen extends StatelessWidget {
  const GuideTourRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Tour Requests',
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 16.h, bottom: 100.h),
        itemCount: tourRequests.length,
        itemBuilder: (context, index) {
          final request = tourRequests[index];
          // Use a standard vertical card layout
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: TourRequestCard(
              touristName: request['name'],
              touristImage: request['image'],
              touristCountryCode: request['countryCode'],
              duration: request['duration'],
              price: request['price'],
              guests: request['guests'],
              location: request['location'],
              onAccept: () { /* TODO: Handle Accept */ },
              onReject: () { /* TODO: Handle Reject */ },
            ),
          );
        },
      ),
      // The floating chat button from GuideDashboardScreen will be visible here
    );
  }
}