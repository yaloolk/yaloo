// lib/features/tourist/widgets/city_detail_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/city_model.dart';

// ── Design tokens (mirrors tourist_home_screen) ───────────────────────────────
const _blue     = Color(0xFF2563EB);
const _textDark = Color(0xFF1F2937);
const _textGray = Color(0xFF6B7280);
const _amber    = Color(0xFFF59E0B);

/// Call this to show the city detail popup.
void showCityDetail(BuildContext context, CityModel city) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,       // allows taller sheet
    backgroundColor: Colors.transparent,
    builder: (_) => _CityDetailSheet(city: city),
  );
}

class _CityDetailSheet extends StatelessWidget {
  final CityModel city;
  const _CityDetailSheet({required this.city});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.82,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          // ── Hero image ────────────────────────────────────────────────────
          _HeroImage(city: city),

          // ── Scrollable content ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Country row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              city.name,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: _textDark,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(children: [
                              Icon(CupertinoIcons.map_pin,
                                  color: _blue, size: 13.w),
                              SizedBox(width: 4.w),
                              Text(
                                city.country,
                                style: TextStyle(
                                    color: _textGray,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      // Rating chip
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_rounded, color: _amber, size: 16.w),
                          SizedBox(width: 4.w),
                          Text('Top Rated',
                              style: TextStyle(
                                  color: _amber,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp)),
                        ]),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Description
                  if (city.description != null &&
                      city.description!.trim().isNotEmpty) ...[
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      city.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _textGray,
                        height: 1.65,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ] else ...[
                    // Placeholder when no description
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: _blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: _blue.withOpacity(0.15)),
                      ),
                      child: Row(children: [
                        Icon(CupertinoIcons.info_circle,
                            color: _blue, size: 18.w),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'No description added yet for ${city.name}.',
                            style: TextStyle(
                                color: _textGray, fontSize: 13.sp),
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(height: 24.h),
                  ],

                  // Quick info chips
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _InfoChip(
                          icon: CupertinoIcons.globe,
                          label: city.country),
                      _InfoChip(
                          icon: CupertinoIcons.checkmark_shield,
                          label: 'Safe to visit'),
                      _InfoChip(
                          icon: CupertinoIcons.camera,
                          label: 'Photo worthy'),
                    ],
                  ),

                  SizedBox(height: 28.h),

                  // Explore button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Navigate to full city detail page
                        // Navigator.pushNamed(context, '/cityDetail',
                        //     arguments: city);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      icon: const Icon(Icons.explore_rounded, size: 20),
                      label: Text(
                        'Explore ${city.name}',
                        style: TextStyle(
                            fontSize: 15.sp, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero image with drag handle + close button ────────────────────────────────
class _HeroImage extends StatelessWidget {
  final CityModel city;
  const _HeroImage({required this.city});

  Widget _imagePlaceholder() => Container(
    height: 230.h,
    color: _blue.withOpacity(0.12),
    child: const Center(
      child: Icon(Icons.image_not_supported_rounded, color: _blue, size: 40),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          child: city.imageUrl != null && city.imageUrl!.isNotEmpty
              ? Image.network(
            city.imageUrl!,
            height: 230.h,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 230.h,
                color: _blue.withOpacity(0.07),
                child: const Center(
                  child: CircularProgressIndicator(color: _blue),
                ),
              );
            },
          )
              : _imagePlaceholder(),
        ),

        // Dark gradient at bottom of image
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // Drag handle
        Positioned(
          top: 10.h,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),

        // Close button
        Positioned(
          top: 12.h,
          right: 14.w,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.xmark,
                  color: Colors.white, size: 16.w),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Small info chip ───────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _blue.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _blue, size: 13.w),
        SizedBox(width: 5.w),
        Text(label,
            style: TextStyle(
                color: _textDark,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}