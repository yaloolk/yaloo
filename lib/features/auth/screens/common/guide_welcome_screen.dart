// lib/features/auth/presentation/screens/guide_welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class GuideWelcomeScreen extends StatelessWidget {
  const GuideWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 28.h),

              // ── Logo ──
              Image.asset(
                'assets/images/yaloo_logo.png',
                width: 40.w,
                height: 40.h,
              ),

              // ── Illustration ──
              SizedBox(height: 36.h),
              Center(
                child: _IllustrationWidget(),
              ),

              // ── Headline ──
              SizedBox(height: 32.h),
              Text(
                'Welcome, Guide!',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10.h),

              // ── Sub-text ──
              Text(
                'We\'ll ask a few details about you so that tourists '
                    'can trust you and we can match you with the best experiences.',
                style: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray,
                  fontSize: 14.sp,
                  height: 1.55,
                ),
              ),

              // ── Info cards ──
              SizedBox(height: 28.h),
              _InfoCard(
                icon: Icons.verified_user_outlined,
                title: 'Identity Verification',
                reason: 'So tourists can trust you',
              ),
              SizedBox(height: 12.h),
              _InfoCard(
                icon: Icons.explore_outlined,
                title: 'Your Expertise',
                reason: 'So we match you perfectly',
              ),
              SizedBox(height: 12.h),
              _InfoCard(
                icon: Icons.shield_outlined,
                title: 'Documents',
                reason: 'To keep the platform safe',
              ),

              // ── Spacer pushes CTA to bottom ──
              const Spacer(),

              // ── Time note ──
              Center(
                child: Text(
                  'This only takes a few minutes',
                  style: AppTextStyles.textSmall.copyWith(
                    color: AppColors.primaryGray,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // ── CTA ──
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/guideProfileCompletion',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Info card — icon on left, title + reason on right
// Same shadow style as the rest of the app
// ─────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String reason;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon badge
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 22.w,
              ),
            ),
          ),
          SizedBox(width: 14.w),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  reason,
                  style: AppTextStyles.textSmall.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.primaryGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Asset-free illustration: a soft, layered composition of
// a map-pin with a small person silhouette, built entirely
// from Flutter primitives — no image assets required.
// ─────────────────────────────────────────────────────────
class _IllustrationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160.w,
      height: 160.h,
      child: CustomPaint(
        painter: _IllustrationPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _IllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Outer glow circle ──
    final glowPaint = Paint()
      ..color = AppColors.primaryBlue.withAlpha(10)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.48, glowPaint);

    // ── Mid circle ──
    final midPaint = Paint()
      ..color = AppColors.primaryBlue.withAlpha(18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.36, midPaint);

    // ── Inner circle (base) ──
    final basePaint = Paint()
      ..color = AppColors.primaryBlue.withAlpha(30)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.24, basePaint);

    // ── Map pin body ──
    final pinPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    final pinTop = cy - size.height * 0.28;
    final pinCx = cx;
    final pinRadius = size.width * 0.095;

    // Circle at pin top
    canvas.drawCircle(Offset(pinCx, pinTop + pinRadius), pinRadius, pinPaint);

    // Triangle pointer below circle
    final trianglePath = Path()
      ..moveTo(pinCx - pinRadius, pinTop + pinRadius * 1.2)
      ..lineTo(pinCx + pinRadius, pinTop + pinRadius * 1.2)
      ..lineTo(pinCx, pinTop + pinRadius * 2.8)
      ..close();
    canvas.drawPath(trianglePath, pinPaint);

    // ── Hole in pin ──
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(pinCx, pinTop + pinRadius),
      pinRadius * 0.42,
      holePaint,
    );

    // ── Small person silhouette (right of pin) ──
    final personX = cx + size.width * 0.18;
    final personY = cy + size.height * 0.04;
    final personPaint = Paint()
      ..color = AppColors.primaryGray.withAlpha(80)
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(personX, personY - 14.h), 7.h, personPaint);

    // Body (rounded rect)
    final bodyRect = RRect.fromLTRBR(
      personX - 9.w,
      personY - 6.h,
      personX + 9.w,
      personY + 18.h,
      Radius.circular(8.r),
    );
    canvas.drawRRect(bodyRect, personPaint);

    // ── Tiny sparkle dots (decorative) ──
    final sparklePaint = Paint()
      ..color = AppColors.primaryBlue.withAlpha(50)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx - size.width * 0.30, cy - size.height * 0.28), 3.w, sparklePaint);
    canvas.drawCircle(Offset(cx + size.width * 0.32, cy - size.height * 0.18), 2.w, sparklePaint);
    canvas.drawCircle(Offset(cx - size.width * 0.22, cy + size.height * 0.30), 2.5.w, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}