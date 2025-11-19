import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';

import '../widgets/stay_request_card.dart';

// --- MOCK DATA (Same as your home screen) ---
final List<Map<String, dynamic>> stayRequests = [
  {
    "name": "Emil Carter",
    "image": "assets/images/tourist_1.jpg",
    "countryCode": "DE",
    "duration": "2 Nights",
    "price": "\$72",
    "guests": 3,
    "rooms": 2,
    "date": "Check-in Jun 14"
  },
  {
    "name": "Maria",
    "image": "assets/images/tourist_2.jpg",
    "countryCode": "US",
    "duration": "1 Night",
    "price": "\$36",
    "guests": 2,
    "rooms": 1,
    "date": "Check-in Jun 15"
  },
  {
    "name": "Sarah",
    "image": "assets/images/tourist_3.jpg",
    "countryCode": "IN",
    "duration": "1 Night",
    "price": "\$70",
    "guests": 2,
    "rooms": 1,
    "date": "Check-in Jun 20"
  },
];
// -----------------

class HostStayRequestsScreen extends StatelessWidget {
  const HostStayRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Stay Requests',
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(top: 16.h, bottom: 100.h),
        itemCount: stayRequests.length,
        itemBuilder: (context, index) {
          final request = stayRequests[index];
          // Use a standard vertical card layout
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            child: StayRequestCard(
              touristName: request['name'],
              touristImage: request['image'],
              touristCountryCode: request['countryCode'],
              duration: request['duration'],
              price: request['price'],
              guests: request['guests'],
              rooms: request['rooms'],
              date: request['date'],
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