// lib/features/tourist/screens/tourist_home_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_icon_button.dart';
import '../providers/tourist_provider.dart';
import '../providers/guide_booking_provider.dart';
import '../providers/city_provider.dart';
import '../models/guide_booking_model.dart';
import '../models/city_model.dart';
import '../widgets/city_detail_sheet.dart';

// ── Mock data (featured — keep as-is until real API) ─────────────────────────
final List<Map<String, String>> featuredDestinations = [
  {"name": "Sri Lanka",   "image": "assets/images/yaloo_banner_1.jpg"},
  {"name": "Yala", "image": "assets/images/yaloo_banner_2.jpg"},
];

final List<Map<String, dynamic>> categories = [
  {"name": "Beach",    "icon": FontAwesomeIcons.umbrellaBeach},
  {"name": "Mountains","icon": FontAwesomeIcons.mountain},
  {"name": "Jungle",   "icon": FontAwesomeIcons.tree},
  {"name": "Culture",  "icon": FontAwesomeIcons.landmark},
];

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bgPage     = Color(0xFFF8FAFC);
const _textDark   = Color(0xFF1F2937);
const _textGray   = Color(0xFF6B7280);
const _pink       = Color(0xFFEC4899);
const _amber      = Color(0xFFF59E0B);
const _purple     = Color(0xFF8B5CF6);
const _green      = Color(0xFF10B981);

class TouristHomeScreen extends StatefulWidget {
  const TouristHomeScreen({super.key});

  @override
  State<TouristHomeScreen> createState() => _TouristHomeScreenState();
}

class _TouristHomeScreenState extends State<TouristHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        context.read<TouristProvider>().loadProfile();
        context.read<GuideBookingProvider>().loadMyBookings();
        context.read<CityProvider>().loadCities();   // ← load cities
      }
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<TouristProvider>().loadProfile(forceRefresh: true),
      context.read<CityProvider>().loadCities(forceRefresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Consumer<TouristProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: _blue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildHeroHeader(context, provider),
                    SizedBox(height: 12.h),
                    _ActiveBookingBanner(),
                    SizedBox(height: 12.h),
                    _buildSearchBar(),
                    SizedBox(height: 24.h),
                    _buildFeaturedSlider(),
                    SizedBox(height: 24.h),
                    _buildFindSection(context),
                    SizedBox(height: 24.h),
                    _buildSectionHeader(title: "Popular Destinations"),
                    SizedBox(height: 16.h),
                    _buildPopularSlider(),     // ← now uses real city data
                    SizedBox(height: 24.h),
                    _buildSectionHeader(title: "Choose Category"),
                    SizedBox(height: 16.h),
                    _buildCategorySlider(),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── HERO HEADER ───────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context, TouristProvider provider) {
    final profile = provider.profile;
    final isLoading = provider.profileLoading && profile == null;

    String displayName = 'Traveler';
    if (profile != null) {
      final parts = profile.fullName.trim().split(' ');
      displayName = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : profile.fullName;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_blue, _blueDark, _blueDarker],
        ),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: _blue.withOpacity(0.38),
            blurRadius: 32,
            offset: const Offset(0, 14),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (profile != null && profile.profilePic.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.45), width: 2.5),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: CircleAvatar(
                      radius: 22.r,
                      backgroundImage: NetworkImage(profile.profilePic),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 2.5),
                    ),
                    child: CircleAvatar(
                      radius: 22.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Image.asset('assets/images/yaloo_logo.png', width: 28.w, height: 28.h),
                    ),
                  ),

                SizedBox(width: 12.w),

                Expanded(
                  child: isLoading
                      ? Container(
                    height: 14.h, width: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good day! 👋',
                        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        displayName,
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                _glassIconBtn(CupertinoIcons.gear, () => Navigator.pushNamed(context, '/settings')),
                SizedBox(width: 8.w),

                Stack(
                  children: [
                    _glassIconBtn(CupertinoIcons.bell, () => Navigator.pushNamed(context, '/notification')),
                    Positioned(
                      top: 6.h, right: 6.w,
                      child: Container(
                        width: 8.w, height: 8.h,
                        decoration: const BoxDecoration(color: _amber, shape: BoxShape.circle),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.h),

            Text(
              'Explore Amazing',
              style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            Text(
              'Destinations !',
              style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 24.sp, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),

            SizedBox(height: 16.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.travel_explore, color: _amber, size: 16),
                  SizedBox(width: 6.w),
                  Text(
                    'Explorer Mode',
                    style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 12.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassIconBtn(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(9.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.28)),
        ),
        child: Icon(icon, color: Colors.white, size: 20.w),
      ),
    );
  }

  // ── SEARCH BAR ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search destinations…',
                  hintStyle: TextStyle(color: _textGray, fontSize: 14.sp),
                  prefixIcon: Icon(CupertinoIcons.search, color: _textGray, size: 20.w),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(CupertinoIcons.slider_horizontal_3, color: _blue, size: 20.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FEATURED SLIDER ───────────────────────────────────────────────────────
  Widget _buildFeaturedSlider() {
    return SizedBox(
      height: 180.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: featuredDestinations.length,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (context, index) {
          final item = featuredDestinations[index];
          return _buildFeaturedCard(
            imageUrl: item['image']!,
            name: item['name']!,
            isFirst: index == 0,
            isLast: index == featuredDestinations.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCard({required String imageUrl, required String name, bool isFirst = false, bool isLast = false}) {
    return Container(
      width: 300.w,
      margin: EdgeInsets.only(left: isFirst ? 16.w : 8.w, right: isLast ? 16.w : 8.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        image: DecorationImage(
          image: imageUrl.startsWith('assets/')
              ? AssetImage(imageUrl) as ImageProvider
              : NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)],
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 16.h, left: 16.w,
            child: Row(
              children: [
                Icon(CupertinoIcons.map_pin, color: Colors.white, size: 13.w),
                SizedBox(width: 4.w),
                Text(name, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Positioned(
            top: 12.h, right: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.star_rounded, color: _amber, size: 13.w),
                SizedBox(width: 3.w),
                Text('Top Pick', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── FIND SECTION ──────────────────────────────────────────────────────────
  Widget _buildFindSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: const Icon(Icons.explore_rounded, color: _blue, size: 22),
            ),
            SizedBox(width: 12.w),
            Text(
              "Find What You're Looking For",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _textDark),
            ),
          ]),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(child: _findBtn(context, "GUIDE",  CupertinoIcons.compass,   _blue,   () => Navigator.pushNamed(context, '/findGuide'))),
            SizedBox(width: 2.w),
            Expanded(child: _findBtn(context, "HOST",   CupertinoIcons.house_fill, _green,  () => Navigator.pushNamed(context, '/findHost'))),
          ]),
        ]),
      ),
    );
  }

  Widget _findBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18.r),
              boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -4)],
            ),
            child: Icon(icon, color: color, size: 22.w),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(color: _textDark, fontSize: 11.sp, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _buildSectionHeader({required String title}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: -0.3),
          overflow: TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'See All',
              style: TextStyle(color: _blue, fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ]),
    );
  }

  // ── POPULAR SLIDER — now driven by CityProvider ───────────────────────────
  Widget _buildPopularSlider() {
    return Consumer<CityProvider>(
      builder: (context, cityProvider, _) {
        // Loading skeleton
        if (cityProvider.loading && cityProvider.cities.isEmpty) {
          return SizedBox(
            height: 220.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              itemBuilder: (_, i) => _buildPopularCardSkeleton(
                isFirst: i == 0, isLast: i == 2,
              ),
            ),
          );
        }

        // Error state
        if (cityProvider.error != null && cityProvider.cities.isEmpty) {
          return SizedBox(
            height: 220.h,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(CupertinoIcons.exclamationmark_circle,
                    color: _textGray, size: 32.w),
                SizedBox(height: 8.h),
                Text('Could not load destinations',
                    style: TextStyle(color: _textGray, fontSize: 13.sp)),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: () => cityProvider.loadCities(forceRefresh: true),
                  child: const Text('Retry'),
                ),
              ]),
            ),
          );
        }

        final cities = cityProvider.cities;

        // Empty state
        if (cities.isEmpty) {
          return SizedBox(
            height: 80.h,
            child: Center(
              child: Text('No destinations available yet.',
                  style: TextStyle(color: _textGray, fontSize: 13.sp)),
            ),
          );
        }

        return SizedBox(
          height: 220.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cities.length,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemBuilder: (context, index) {
              final city = cities[index];
              return _buildCityCard(
                city: city,
                isFirst: index == 0,
                isLast: index == cities.length - 1,
              );
            },
          ),
        );
      },
    );
  }

  /// ── Real city card — tappable, opens bottom sheet popup ─────────────────
  Widget _buildCityCard({
    required CityModel city,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: () => showCityDetail(context, city),
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(
          left: isFirst ? 16.w : 8.w,
          right: isLast ? 16.w : 8.w,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(children: [
            // Network image
            Positioned.fill(
              child: city.imageUrl != null && city.imageUrl!.isNotEmpty
                  ? Image.network(
                city.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _blue.withOpacity(0.12),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_rounded,
                        color: _blue, size: 30),
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: _blue.withOpacity(0.07),
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: _blue, strokeWidth: 2),
                    ),
                  );
                },
              )
                  : Container(
                color: _blue.withOpacity(0.12),
                child: const Center(
                  child: Icon(Icons.image_not_supported_rounded,
                      color: _blue, size: 30),
                ),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.65),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),

            // Viewfinder icon top-right
            Positioned(
              top: 10.h, right: 10.w,
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Icon(CupertinoIcons.viewfinder,
                    color: Colors.white, size: 14.w),
              ),
            ),

            // City name + country bottom
            Positioned(
              bottom: 14.h, left: 12.w, right: 12.w,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(CupertinoIcons.map_pin,
                      color: Colors.white, size: 11.w),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      city.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                SizedBox(height: 3.h),
                Text(
                  city.country,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  /// Skeleton placeholder while loading
  Widget _buildPopularCardSkeleton({bool isFirst = false, bool isLast = false}) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(
          left: isFirst ? 16.w : 8.w, right: isLast ? 16.w : 8.w),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24.r),
      ),
    );
  }

  // ── CATEGORY SLIDER ───────────────────────────────────────────────────────
  Widget _buildCategorySlider() {
    return SizedBox(
      height: 52.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemBuilder: (context, index) {
          final item = categories[index];
          return _buildCategoryChip(
            label: item['name']!, icon: item['icon']!,
            isFirst: index == 0, isLast: index == categories.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({required String label, required IconData icon, bool isFirst = false, bool isLast = false}) {
    return Container(
      margin: EdgeInsets.only(left: isFirst ? 16.w : 8.w, right: isLast ? 16.w : 8.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _blue.withOpacity(0.25), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _blue, size: 15.w),
            SizedBox(width: 7.w),
            Text(label, style: TextStyle(color: _textDark, fontWeight: FontWeight.w700, fontSize: 13.sp)),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24.r),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 16, offset: const Offset(0, 4))],
  );
}


// ═══════════════════════════════════════════════════════════════════════════════
// Active Booking Banner (unchanged)
// ═══════════════════════════════════════════════════════════════════════════════
class _ActiveBookingBanner extends StatefulWidget {
  const _ActiveBookingBanner();
  @override State<_ActiveBookingBanner> createState() => _ActiveBookingBannerState();
}

class _ActiveBookingBannerState extends State<_ActiveBookingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double>    _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  GuideBookingModel? _activeBooking(List<GuideBookingModel> bookings) {
    final now = DateTime.now();
    for (final b in bookings) {
      if (b.bookingStatus != 'confirmed') continue;
      try {
        final sp = b.startTime.split(':');
        final ep = b.endTime.split(':');
        final d  = DateTime.parse(b.bookingDate);
        final start = DateTime(d.year, d.month, d.day, int.parse(sp[0]), int.parse(sp[1]));
        final end   = DateTime(d.year, d.month, d.day, int.parse(ep[0]), int.parse(ep[1]));
        if (now.isAfter(start) && now.isBefore(end)) return b;
      } catch (_) {}
    }
    return null;
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':'); int h = int.parse(p[0]);
      final m = p[1].padLeft(2,'0');
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<GuideBookingProvider>().myBookings;
    final active   = _activeBooking(bookings);
    if (active == null) return const SizedBox.shrink();

    final now   = DateTime.now();
    final ep    = active.endTime.split(':');
    final d     = DateTime.parse(active.bookingDate);
    final end   = DateTime(d.year, d.month, d.day, int.parse(ep[0]), int.parse(ep[1]));
    final remaining = end.difference(now);
    final hh = remaining.inHours.toString().padLeft(2,'0');
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2,'0');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/bookingStatus', arguments: active.toJson()),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 18, offset: const Offset(0, 6))],
          ),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
          child: Row(children: [
            FadeTransition(
              opacity: _pulseAnim,
              child: Container(
                  width: 10.w, height: 10.w,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle)),
            ),
            SizedBox(width: 10.w),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tour In Progress!', style: TextStyle(
                    color: Colors.white, fontSize: 14.sp,
                    fontWeight: FontWeight.w800)),
                SizedBox(height: 2.h),
                Text(
                    '${active.guideName.isNotEmpty ? active.guideName : "Guide"}'
                        ' · ${_fmtTime(active.startTime)} – ${_fmtTime(active.endTime)}',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 11.sp),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            )),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Text('$hh:$mm left', style: TextStyle(
                  color: Colors.white, fontSize: 12.sp,
                  fontWeight: FontWeight.w700)),
            ),
            SizedBox(width: 8.w),
            Icon(CupertinoIcons.chevron_right,
                color: Colors.white.withOpacity(0.8), size: 14.w),
          ]),
        ),
      ),
    );
  }
}