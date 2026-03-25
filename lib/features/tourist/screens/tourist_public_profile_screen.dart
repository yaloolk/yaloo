// lib/features/guide/screens/tourist_public_profile_screen.dart
//
// Shown when a guide taps "View Profile →" from GuideTourRequestDetailsScreen.
// Receives: {'userId': int}  via ModalRoute arguments.
// Loads the tourist's real profile from the backend via TouristPublicProfileService.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/tourist/models/tourist_public_profile_model.dart';
import 'package:yaloo/features/tourist/services/tourist_public_profile_service.dart';

// ── Design tokens (matches guide home / request detail) ───────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _amber      = Color(0xFFF59E0B);
const _green      = Color(0xFF22C55E);
const _red        = Color(0xFFEF4444);
const _pink       = Color(0xFFEC4899);
const _cyan       = Color(0xFF06B6D4);
const _bg         = Color(0xFFF8FAFC);

class TouristPublicProfileScreen extends StatefulWidget {
  const TouristPublicProfileScreen({super.key});

  @override
  State<TouristPublicProfileScreen> createState() =>
      _TouristPublicProfileScreenState();
}

class _TouristPublicProfileScreenState
    extends State<TouristPublicProfileScreen> {
  final _service = TouristPublicProfileService();

  TouristPublicProfileModel? _profile;
  bool   _loading = true;
  String _error   = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    final args = ModalRoute.of(context)?.settings.arguments
    as Map<String, dynamic>? ?? {};
    final userId = args['userId'] as String?;

    if (userId == null) {
      setState(() { _error = 'No tourist ID provided.'; _loading = false; });
      return;
    }

    setState(() { _loading = true; _error = ''; });
    try {
      final profile = await _service.fetchProfile(userId);
      if (mounted) setState(() { _profile = profile; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: CustomAppBar(title: 'Tourist Profile'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: _blue));
    }

    if (_error.isNotEmpty) {
      return Center(child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(CupertinoIcons.exclamationmark_circle,
              color: _red, size: 48.w),
          SizedBox(height: 16.h),
          Text(_error, textAlign: TextAlign.center,
              style: TextStyle(color: _dark, fontSize: 14.sp)),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r))),
          ),
        ]),
      ));
    }

    if (_profile == null) {
      return Center(child: Text('Profile not available.',
          style: TextStyle(color: _gray, fontSize: 15.sp)));
    }

    final p = _profile!;
    return RefreshIndicator(
      onRefresh: _load,
      color: _blue,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          SliverToBoxAdapter(child: _heroCard(p)),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverToBoxAdapter(child: _statsRow(p)),
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          if (p.bio.isNotEmpty) ...[
            SliverToBoxAdapter(child: _section(
              icon: Icons.person_outline_rounded, iconColor: _blue,
              title: 'About',
              child: Text(p.bio, style: TextStyle(
                  fontSize: 14.sp, color: _dark, height: 1.6)),
            )),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
          SliverToBoxAdapter(child: _detailsCard(p)),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          if (p.interests.isNotEmpty) ...[
            SliverToBoxAdapter(child: _section(
              icon: Icons.favorite_rounded, iconColor: _pink,
              title: 'Interests',
              child: Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: p.interests
                    .map((i) => _chip(i, _pink))
                    .toList(),
              ),
            )),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
          if (p.languages.isNotEmpty) ...[
            SliverToBoxAdapter(child: _section(
              icon: Icons.language_rounded, iconColor: _cyan,
              title: 'Languages',
              child: Wrap(
                spacing: 8.w, runSpacing: 8.h,
                children: p.languages
                    .map((l) => _langChip(l))
                    .toList(),
              ),
            )),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
          if (p.reviews.isNotEmpty) ...[
            SliverToBoxAdapter(child: _reviewsSection(p)),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
          SliverToBoxAdapter(child: _verificationCard(p)),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────────────────────────
  Widget _heroCard(TouristPublicProfileModel p) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [_blue, _blueDark, _blueDarker],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
              color: _blue.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -6),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 28.h),
        child: Column(children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.45), width: 3.5),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ]),
            child: CircleAvatar(
              radius: 52.r,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: p.profilePic.isNotEmpty
                  ? CachedNetworkImageProvider(p.profilePic)
                  : null,
              child: p.profilePic.isEmpty
                  ? Text(
                  p.fullName.isNotEmpty
                      ? p.fullName[0].toUpperCase()
                      : 'T',
                  style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white))
                  : null,
            ),
          ),
          SizedBox(height: 16.h),

          // Name
          Text(
            p.fullName.isEmpty ? 'Traveler' : p.fullName,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          // Country badge
          if (p.country.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_on_rounded,
                    color: Colors.white.withOpacity(0.9), size: 14.w),
                SizedBox(width: 5.w),
                Text(p.country,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          SizedBox(height: 12.h),

          // Rating row
          if (p.avgRating > 0)
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(CupertinoIcons.star_fill, color: _amber, size: 16.w),
              SizedBox(width: 5.w),
              Text(p.avgRating.toStringAsFixed(1),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
              SizedBox(width: 6.w),
              Text('(${p.reviewCount} review${p.reviewCount != 1 ? 's' : ''})',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13.sp)),
            ]),
        ]),
      ),
    );
  }

  // ── STATS ROW ─────────────────────────────────────────────────────────────
  Widget _statsRow(TouristPublicProfileModel p) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(children: [
        Expanded(child: _statCard(
            Icons.flight_takeoff_rounded,
            '${p.toursCompleted}', 'Trips', const Color(0xFF8B5CF6))),
        SizedBox(width: 12.w),
        Expanded(child: _statCard(
            Icons.language_rounded,
            '${p.languages.length}', 'Languages', _cyan)),
        SizedBox(width: 12.w),
        Expanded(child: _statCard(
            Icons.favorite_rounded,
            '${p.interests.length}', 'Interests', _pink)),
      ]),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -4)
          ]),
      child: Column(children: [
        Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: color, size: 22)),
        SizedBox(height: 8.h),
        Text(value,
            style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: _dark)),
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                color: _gray,
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── DETAILS CARD ──────────────────────────────────────────────────────────
  Widget _detailsCard(TouristPublicProfileModel p) {
    return _section(
      icon: Icons.info_outline_rounded, iconColor: _blue,
      title: 'Profile Details',
      child: Column(children: [
        if (p.travelStyle.isNotEmpty) ...[
          _detailRow(Icons.luggage_rounded, 'Travel Style',
              p.travelStyle, const Color(0xFF8B5CF6)),
          Divider(height: 20.h, color: Colors.black.withOpacity(0.06)),
        ],
        _detailRow(Icons.calendar_today_rounded, 'Member Since',
            p.memberSince, _blue),
        Divider(height: 20.h, color: Colors.black.withOpacity(0.06)),
        _detailRow(Icons.check_circle_outline_rounded, 'Tours Completed',
            '${p.toursCompleted} tour${p.toursCompleted != 1 ? 's' : ''}',
            _green),
        if (p.languages.isNotEmpty) ...[
          Divider(height: 20.h, color: Colors.black.withOpacity(0.06)),
          _detailRow(Icons.language_rounded, 'Languages',
              p.languages
                  .map((l) => l.isNative ? '${l.name} (native)' : l.name)
                  .join(', '),
              _cyan),
        ],
      ]),
    );
  }

  Widget _detailRow(
      IconData icon, String label, String value, Color color) {
    return Row(children: [
      Container(
          padding: EdgeInsets.all(9.r),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, color: color, size: 18)),
      SizedBox(width: 14.w),
      Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11.sp,
                    color: _gray,
                    fontWeight: FontWeight.w500)),
            SizedBox(height: 2.h),
            Text(value,
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _dark)),
          ])),
    ]);
  }

  // ── REVIEWS SECTION ───────────────────────────────────────────────────────
  Widget _reviewsSection(TouristPublicProfileModel p) {
    return _section(
      icon: Icons.star_rounded, iconColor: _amber,
      title: 'Ratings & Reviews',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(p.avgRating.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w800,
                  color: _dark,
                  height: 1)),
          SizedBox(width: 12.w),
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _starRow(p.avgRating),
                  SizedBox(height: 4.h),
                  Text('Based on ${p.reviewCount} review${p.reviewCount != 1 ? 's' : ''}',
                      style: TextStyle(fontSize: 12.sp, color: _gray)),
                ]),
          ),
        ]),
        SizedBox(height: 16.h),

        // Rating bars
        for (int star = 5; star >= 1; star--) ...[
          _ratingBar(star, p.ratingBreakdown[star] ?? 0, p.reviewCount),
          SizedBox(height: 4.h),
        ],
        SizedBox(height: 20.h),

        // Review cards
        ...p.reviews.take(2).map((r) => _reviewCard(r)),

        if (p.reviewCount > 2) ...[
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: _blue.withOpacity(0.08),
                  foregroundColor: _blue,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r))),
              child: Text(
                  'See All ${p.reviewCount} Reviews',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: _blue)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _starRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(CupertinoIcons.star_fill, color: _amber, size: 15.w);
        } else if (i < rating) {
          return Icon(CupertinoIcons.star_lefthalf_fill,
              color: _amber, size: 15.w);
        }
        return Icon(CupertinoIcons.star, color: _amber, size: 15.w);
      }),
    );
  }

  Widget _ratingBar(int star, int count, int total) {
    final pct = total == 0 ? 0.0 : count / total;
    return Row(children: [
      SizedBox(
          width: 18.w,
          child: Text('$star',
              style: TextStyle(fontSize: 12.sp, color: _gray))),
      SizedBox(width: 8.w),
      Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
                value: pct,
                backgroundColor: Colors.grey.shade200,
                color: _amber,
                minHeight: 7.h),
          )),
      SizedBox(width: 8.w),
      SizedBox(
          width: 20.w,
          child: Text('$count',
              style: TextStyle(
                  fontSize: 11.sp, color: _gray),
              textAlign: TextAlign.right)),
    ]);
  }

  Widget _reviewCard(TouristReview r) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black.withOpacity(0.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: _blue.withOpacity(0.1),
            backgroundImage: r.reviewerPhoto.isNotEmpty
                ? CachedNetworkImageProvider(r.reviewerPhoto)
                : null,
            child: r.reviewerPhoto.isEmpty
                ? Icon(Icons.person_rounded, size: 16.w, color: _blue)
                : null,
          ),
          SizedBox(width: 10.w),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.reviewerName,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: _dark)),
                Text(r.date,
                    style: TextStyle(fontSize: 11.sp, color: _gray)),
              ])),
          _starRow(r.rating.toDouble()),
        ]),
        if (r.comment.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Text(r.comment,
              style: TextStyle(
                  fontSize: 13.sp, color: _gray, height: 1.5)),
        ],
      ]),
    );
  }

  // ── VERIFICATION CARD ─────────────────────────────────────────────────────
  Widget _verificationCard(TouristPublicProfileModel p) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: _green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: _green.withOpacity(0.25))),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
                color: _green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12.r)),
            child: Icon(CupertinoIcons.checkmark_shield_fill,
                color: _green, size: 22),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Status',
                    style: TextStyle(
                        fontSize: 11.sp, color: _gray,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 2.h),
                Text(p.isVerified ? 'Verified by Yaloo' : 'Unverified',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: p.isVerified ? _green : _gray)),
              ])),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
                color: (p.isVerified ? _green : _gray).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r)),
            child: Text(
                p.isVerified ? 'Verified' : 'Unverified',
                style: TextStyle(
                    color: p.isVerified ? _green : _gray,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  // ── SHARED HELPERS ────────────────────────────────────────────────────────

  Widget _section({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: iconColor, size: 20)),
          SizedBox(width: 12.w),
          Text(title,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: _dark)),
        ]),
        SizedBox(height: 16.h),
        child,
      ]),
    );
  }

  Widget _chip(String label, Color color) => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.favorite_rounded, size: 12.w, color: color),
        SizedBox(width: 5.w),
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color)),
      ]));

  Widget _langChip(TouristLanguage l) => Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
          color: _cyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _cyan.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.language_rounded, size: 12.w, color: _cyan),
        SizedBox(width: 5.w),
        Text(l.name,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _cyan)),
        if (l.isNative) ...[
          SizedBox(width: 6.w),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(4.r)),
              child: Text('Native',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700))),
        ],
      ]));
}