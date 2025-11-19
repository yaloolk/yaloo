import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class HostBookingsScreen extends StatelessWidget {
  const HostBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.calendarCheck, size: 60, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text('Guide Bookings Screen', style: AppTextStyles.headlineLarge),
          ],
        ),
      ),
    );
  }
}