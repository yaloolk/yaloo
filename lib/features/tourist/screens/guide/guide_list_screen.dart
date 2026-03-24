// lib/features/tourist/screens/guide/guide_list_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import '../../models/guide_search_result.dart';
import '../../providers/guide_booking_provider.dart';

const _blue   = Color(0xFF2563EB);
const _bgPage = Color(0xFFF8FAFC);
const _dark   = Color(0xFF1F2937);
const _gray   = Color(0xFF6B7280);
const _green  = Color(0xFF10B981);
const _amber  = Color(0xFFF59E0B);

class GuideListScreen extends StatefulWidget {
  const GuideListScreen({super.key});
  @override State<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends State<GuideListScreen> {
  String _sort = 'rating';

  List<GuideSearchResult> _sorted(List<GuideSearchResult> raw) {
    final list = [...raw];
    switch (_sort) {
      case 'price_low':  list.sort((a, b) => a.ratePerHour.compareTo(b.ratePerHour));
      case 'price_high': list.sort((a, b) => b.ratePerHour.compareTo(a.ratePerHour));
      default:           list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GuideBookingProvider>(
      builder: (_, prov, __) => Scaffold(
        backgroundColor: _bgPage,
        appBar: CustomAppBar(title: 'Available Guides'),
        body: prov.searchLoading ? const Center(child: CircularProgressIndicator())
            : prov.searchError.isNotEmpty ? _errView(prov.searchError)
            : prov.searchResults.isEmpty   ? _emptyView(context, prov)
            : Column(children: [
          _searchSummary(prov),
          _sortRow(),
          Expanded(child: _list(context, prov)),
        ]),
      ),
    );
  }

  // ── Search summary banner ────────────────────────────────────────────────
  Widget _searchSummary(GuideBookingProvider p) => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
    child: Row(children: [
      Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
              color: _blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r)),
          child: Icon(CupertinoIcons.location_solid, color: _blue, size: 14.w)),
      SizedBox(width: 10.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.lastCityName, style: TextStyle(
            color: _dark, fontWeight: FontWeight.w700, fontSize: 13.sp)),
        Text('${p.lastSearchDate}  ·  ${p.lastStartTime}', style: TextStyle(
            color: _gray, fontSize: 11.sp)),
      ])),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
            color: _blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20.r)),
        child: Text('${p.searchResults.length} found',
            style: TextStyle(color: _blue, fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ),
    ]),
  );

  // ── Sort row ─────────────────────────────────────────────────────────────
  Widget _sortRow() => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
    child: Row(children: [
      _chip('⭐ Top Rated', 'rating'),
      SizedBox(width: 8.w),
      _chip('Price ↑', 'price_low'),
      SizedBox(width: 8.w),
      _chip('Price ↓', 'price_high'),
    ]),
  );

  Widget _chip(String label, String val) {
    final sel = _sort == val;
    return GestureDetector(
      onTap: () => setState(() => _sort = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
        decoration: BoxDecoration(
            color: sel ? _blue : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
                color: sel ? _blue : _blue.withOpacity(0.25), width: 1.5)),
        child: Text(label, style: TextStyle(
            color: sel ? Colors.white : _dark,
            fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Guide list ────────────────────────────────────────────────────────────
  Widget _list(BuildContext context, GuideBookingProvider prov) {
    final guides = _sorted(prov.searchResults);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      physics: const BouncingScrollPhysics(),
      itemCount: guides.length,
      itemBuilder: (_, i) => _GuideCard(
        guide: guides[i],
        onTap: () {
          prov.loadGuideDetail(guides[i].guideProfileId);
          Navigator.pushNamed(context, '/guideDetail', arguments: {
            'guide_profile_id': guides[i].guideProfileId,
            'search_date':      prov.lastSearchDate,
            'start_time':       prov.lastStartTime,
            'available_slots':  guides[i].availableSlots,
          });
        },
      ),
    );
  }

  Widget _errView(String msg) => Center(child: Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(CupertinoIcons.exclamationmark_circle, color: Colors.red.shade400, size: 52.w),
      SizedBox(height: 14.h),
      Text('Something went wrong', style: TextStyle(
          fontSize: 16.sp, fontWeight: FontWeight.w700, color: _dark)),
      SizedBox(height: 8.h),
      Text(msg, textAlign: TextAlign.center,
          style: TextStyle(color: _gray, fontSize: 13.sp)),
    ]),
  ));

  Widget _emptyView(BuildContext context, GuideBookingProvider p) => Center(child: Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
              color: _blue.withOpacity(0.08),
              shape: BoxShape.circle),
          child: Icon(CupertinoIcons.person_2, color: _blue, size: 48.w)),
      SizedBox(height: 18.h),
      Text('No Guides Found', style: TextStyle(
          fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
      SizedBox(height: 8.h),
      Text('No available guides in ${p.lastCityName}\non ${p.lastSearchDate}',
          textAlign: TextAlign.center,
          style: TextStyle(color: _gray, fontSize: 13.sp)),
      SizedBox(height: 24.h),
      OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: Icon(CupertinoIcons.arrow_left, size: 16.w),
        label: const Text('Change Search'),
        style: OutlinedButton.styleFrom(
            foregroundColor: _blue,
            side: const BorderSide(color: _blue, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h)),
      ),
    ]),
  ));
}

// ── Guide card ────────────────────────────────────────────────────────────────
class _GuideCard extends StatelessWidget {
  final GuideSearchResult guide;
  final VoidCallback onTap;
  const _GuideCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _photo(),
            SizedBox(width: 14.w),
            Expanded(child: _info()),
          ]),
        ),
      ),
    );
  }

  Widget _photo() => ClipRRect(
    borderRadius: BorderRadius.circular(16.r),
    child: guide.profilePic.isNotEmpty
        ? CachedNetworkImage(
        imageUrl: guide.profilePic, width: 88.w, height: 105.h,
        fit: BoxFit.cover,
        placeholder: (_, __) => _photoFallback(),
        errorWidget:  (_, __, ___) => _photoFallback())
        : _photoFallback(),
  );

  Widget _photoFallback() => Container(
    width: 88.w, height: 105.h,
    decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue.withOpacity(0.15), _blue.withOpacity(0.08)],
            begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: Icon(CupertinoIcons.person_fill,
        color: _blue.withOpacity(0.4), size: 36.w),
  );

  Widget _info() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    // Name + badges
    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(child: Text(guide.fullName, style: TextStyle(
          fontSize: 14.sp, fontWeight: FontWeight.w800, color: _dark),
          overflow: TextOverflow.ellipsis)),
      if (guide.isSltdaVerified) ...[
        SizedBox(width: 6.w),
        _badge('SLTDA', _green),
      ],
    ]),
    SizedBox(height: 3.h),

    // City · rating
    Row(children: [
      Icon(CupertinoIcons.map_pin, color: _gray, size: 11.w),
      SizedBox(width: 3.w),
      Text(guide.cityName, style: TextStyle(
          color: _gray, fontSize: 11.sp)),
      const Spacer(),
      Icon(Icons.star_rounded, color: _amber, size: 13.w),
      SizedBox(width: 2.w),
      Text(guide.avgRating.toStringAsFixed(1), style: TextStyle(
          fontSize: 12.sp, fontWeight: FontWeight.w700, color: _dark)),
      Text(' (${guide.totalCompletedBookings})', style: TextStyle(
          fontSize: 11.sp, color: _gray)),
    ]),
    SizedBox(height: 7.h),

    // Languages
    if (guide.languages.isNotEmpty)
      Wrap(spacing: 5.w, runSpacing: 4.h,
          children: guide.languages.take(3)
              .map((l) => _tag(l.name, _blue.withOpacity(0.08), _blue))
              .toList()),

    if (guide.specialties.isNotEmpty) ...[
      SizedBox(height: 4.h),
      Wrap(spacing: 5.w, runSpacing: 4.h,
          children: guide.specialties.take(2)
              .map((s) => _tag(s.name, _green.withOpacity(0.08), _green))
              .toList()),
    ],
    SizedBox(height: 10.h),

    // Price + slots pill
    Row(children: [
      Text('LKR ${guide.ratePerHour.toStringAsFixed(0)}',
          style: TextStyle(
              fontSize: 15.sp, fontWeight: FontWeight.w800, color: _blue)),
      Text('/hr', style: TextStyle(fontSize: 11.sp, color: _gray)),
      const Spacer(),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(12.r)),
        child: Text('${guide.availableSlots.length} slot${guide.availableSlots.length != 1 ? "s" : ""}',
            style: TextStyle(
                color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700)),
      ),
    ]),
  ]);

  Widget _tag(String label, Color bg, Color fg) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6.r)),
    child: Text(label, style: TextStyle(color: fg, fontSize: 10.sp, fontWeight: FontWeight.w600)),
  );

  Widget _badge(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.5))),
    child: Text(label, style: TextStyle(
        color: color, fontSize: 9.sp, fontWeight: FontWeight.w800)),
  );
}