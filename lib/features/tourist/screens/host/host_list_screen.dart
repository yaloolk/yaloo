// lib/features/tourist/screens/host/host_list_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/features/tourist/models/stay_booking_model.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';
import '../../../../core/services/yaloo_ai_service.dart';

const _blue   = Color(0xFF2563EB);
const _bg     = Color(0xFFF8FAFC);
const _dark   = Color(0xFF1F2937);
const _gray   = Color(0xFF6B7280);
const _amber  = Color(0xFFF59E0B);
const _violet = Color(0xFF7C3AED); // AI accent

class HostListScreen extends StatefulWidget {
  const HostListScreen({super.key});
  @override State<HostListScreen> createState() => _HostListScreenState();
}

class _HostListScreenState extends State<HostListScreen> {
  String _sort = 'ai';

  // AI recommendation state
  List<String> _aiRankedIds  = [];
  Set<String>  _aiPickSet    = {};
  bool         _aiLoading    = true;
  bool         _aiAvailable  = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAiRankings());
  }

  // ── Fetch AI stay rankings ─────────────────────────────────────────────────
  Future<void> _fetchAiRankings() async {
    final prov = context.read<StayBookingProvider>();

    final user       = Supabase.instance.client.auth.currentUser;
    final touristId  = user?.userMetadata?['tourist_profile_id'] as String?;

    if (touristId == null || touristId.isEmpty) {
      setState(() { _aiLoading = false; _aiAvailable = false; });
      return;
    }

    // Pass available stay IDs (availability already checked by Django)
    final availableIds = prov.searchResults.map((s) => s.stayId).toList();

    final result = await YalooAiService.instance.recommend(
      touristId:        touristId,
      city:             prov.lastCityName,
      availableStayIds: availableIds,
      topK:             availableIds.length,
    );

    if (!mounted) return;

    if (result != null && result.rankedStayIds.isNotEmpty) {
      setState(() {
        _aiRankedIds  = result.rankedStayIds;
        _aiPickSet    = result.rankedStayIds.take(3).toSet();
        _aiAvailable  = true;
        _aiLoading    = false;
        _sort         = 'ai';
      });
    } else {
      setState(() {
        _aiAvailable = false;
        _aiLoading   = false;
        _sort        = 'rating';
      });
    }
  }

  // ── Sort logic ─────────────────────────────────────────────────────────────
  List<StaySearchResult> _sorted(List<StaySearchResult> raw) {
    final list = [...raw];
    switch (_sort) {
      case 'ai':
        if (_aiRankedIds.isEmpty) {
          list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
        } else {
          final posMap = { for (var i = 0; i < _aiRankedIds.length; i++) _aiRankedIds[i]: i };
          list.sort((a, b) {
            final pa = posMap[a.stayId] ?? 999;
            final pb = posMap[b.stayId] ?? 999;
            return pa.compareTo(pb);
          });
        }
      case 'price_low':
        list.sort((a, b) => a.pricePerNight.compareTo(b.pricePerNight));
      case 'price_high':
        list.sort((a, b) => b.pricePerNight.compareTo(a.pricePerNight));
      default:
        list.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    }
    return list;
  }

  void _goToProfile(BuildContext ctx, StayBookingProvider prov,
      StaySearchResult stay) {
    prov.loadStayProfile(stay.stayId);
    Navigator.pushNamed(ctx, '/touristHostProfile', arguments: {
      'stay':     stay,
      'checkin':  prov.lastCheckin,
      'checkout': prov.lastCheckout,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StayBookingProvider>(
      builder: (_, prov, __) => Scaffold(
        backgroundColor: _bg,
        appBar: CustomAppBar(title: 'Available Stays'),
        body: prov.searchLoading
            ? const Center(child: CircularProgressIndicator(color: _blue))
            : prov.searchError.isNotEmpty
            ? _errView(prov)
            : prov.searchResults.isEmpty
            ? _emptyView(prov)
            : Column(children: [
          _searchSummary(prov),
          _sortRow(),
          if (_aiLoading) _aiLoadingBanner(),
          Expanded(child: _list(context, prov)),
        ]),
      ),
    );
  }

  // ── AI loading banner ──────────────────────────────────────────────────────
  Widget _aiLoadingBanner() => Container(
    color: _violet.withOpacity(0.06),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    child: Row(children: [
      SizedBox(
        width: 14.w, height: 14.h,
        child: CircularProgressIndicator(color: _violet, strokeWidth: 2),
      ),
      SizedBox(width: 10.w),
      Text('AI is personalising your results…',
          style: TextStyle(color: _violet, fontSize: 12.sp,
              fontWeight: FontWeight.w600)),
    ]),
  );

  // ── Search summary ─────────────────────────────────────────────────────────
  Widget _searchSummary(StayBookingProvider p) => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
    child: Row(children: [
      Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
              color: _blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r)),
          child: Icon(CupertinoIcons.house_fill, color: _blue, size: 14.w)),
      SizedBox(width: 10.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${p.lastCheckin}  →  ${p.lastCheckout}',
                style: TextStyle(color: _dark, fontWeight: FontWeight.w700,
                    fontSize: 12.sp)),
            if (p.lastCityName.isNotEmpty)
              Text(p.lastCityName,
                  style: TextStyle(color: _gray, fontSize: 11.sp)),
          ])),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
            color: _blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20.r)),
        child: Text('${p.searchResults.length} found',
            style: TextStyle(color: _blue, fontSize: 12.sp,
                fontWeight: FontWeight.w700)),
      ),
    ]),
  );

  // ── Sort row ───────────────────────────────────────────────────────────────
  Widget _sortRow() => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(0, 0, 0, 10.h),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(children: [
        if (_aiAvailable) ...[
          _chip('✨ AI Pick', 'ai', accent: _violet),
          SizedBox(width: 8.w),
        ],
        _chip('⭐ Top Rated', 'rating'),
        SizedBox(width: 8.w),
        _chip('Price ↑', 'price_low'),
        SizedBox(width: 8.w),
        _chip('Price ↓', 'price_high'),
      ]),
    ),
  );

  Widget _chip(String label, String val, {Color? accent}) {
    final sel   = _sort == val;
    final color = accent ?? _blue;
    return GestureDetector(
      onTap: () => setState(() => _sort = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
            color: sel ? color : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
                color: sel ? color : color.withOpacity(0.3), width: 1.5)),
        child: Text(label, style: TextStyle(
            color: sel ? Colors.white : _dark,
            fontSize: 12.sp, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── Stays list ─────────────────────────────────────────────────────────────
  Widget _list(BuildContext ctx, StayBookingProvider prov) {
    final stays = _sorted(prov.searchResults);
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      physics: const BouncingScrollPhysics(),
      itemCount: stays.length,
      itemBuilder: (_, i) {
        final isAiPick = _aiPickSet.contains(stays[i].stayId);
        final aiRank   = _aiRankedIds.indexOf(stays[i].stayId);
        return _StayCard(
          stay:     stays[i],
          isAiPick: isAiPick && _sort == 'ai',
          aiRank:   (_sort == 'ai' && aiRank >= 0) ? aiRank + 1 : null,
          onTap:    () => _goToProfile(ctx, prov, stays[i]),
        );
      },
    );
  }

  Widget _errView(StayBookingProvider prov) => Center(child: Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(CupertinoIcons.exclamationmark_circle,
          color: Colors.red.shade400, size: 52.w),
      SizedBox(height: 14.h),
      Text(prov.searchError, textAlign: TextAlign.center,
          style: TextStyle(color: _dark, fontSize: 14.sp)),
      SizedBox(height: 20.h),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r))),
        child: const Text('Go Back', style: TextStyle(color: Colors.white)),
      ),
    ]),
  ));

  Widget _emptyView(StayBookingProvider prov) => Center(child: Padding(
    padding: EdgeInsets.all(32.w),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
              color: _blue.withOpacity(0.08), shape: BoxShape.circle),
          child: Icon(CupertinoIcons.house, color: _blue, size: 48.w)),
      SizedBox(height: 18.h),
      Text('No Stays Found', style: TextStyle(
          fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark)),
      SizedBox(height: 8.h),
      Text('No available stays for your criteria.\nTry different dates or filters.',
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h)),
      ),
    ]),
  ));
}

// ── Stay card ──────────────────────────────────────────────────────────────────

class _StayCard extends StatelessWidget {
  final StaySearchResult stay;
  final VoidCallback     onTap;
  final bool  isAiPick;
  final int?  aiRank;

  const _StayCard({
    required this.stay,
    required this.onTap,
    this.isAiPick = false,
    this.aiRank,
  });

  String _typeLabel(String t) {
    switch (t) {
      case 'homestay':   return 'Homestay';
      case 'farm_stay':  return 'Farm Stay';
      case 'villa':      return 'Villa';
      case 'guesthouse': return 'Guesthouse';
      case 'eco_lodge':  return 'Eco Lodge';
      case 'hostel':     return 'Hostel';
      default:           return t;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: isAiPick
              ? Border.all(
              color: const Color(0xFF7C3AED).withOpacity(0.45), width: 1.5)
              : null,
          boxShadow: [BoxShadow(
              color: isAiPick
                  ? const Color(0xFF7C3AED).withOpacity(0.10)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isAiPick ? 20 : 16,
              offset: const Offset(0, 4))],
        ),
        child: Column(children: [
          // Cover image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: Stack(children: [
              stay.coverPhoto.isNotEmpty
                  ? CachedNetworkImage(
                  imageUrl: stay.coverPhoto,
                  height: 180.h, width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(height: 180.h, color: Colors.grey.shade100),
                  errorWidget: (_, __, ___) => _photoFb())
                  : _photoFb(),
              // Type badge
              Positioned(
                top: 12.h, left: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                      color: _blue.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8.r)),
                  child: Text(_typeLabel(stay.type),
                      style: TextStyle(color: Colors.white,
                          fontSize: 11.sp, fontWeight: FontWeight.w700)),
                ),
              ),
              // AI badge (top-right, replaces/alongside rating)
              if (isAiPick)
                Positioned(
                  top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 11.w),
                      SizedBox(width: 4.w),
                      Text(
                        aiRank != null ? 'AI #$aiRank' : 'AI Pick',
                        style: TextStyle(color: Colors.white,
                            fontSize: 11.sp, fontWeight: FontWeight.w700),
                      ),
                    ]),
                  ),
                )
              else if (stay.avgRating > 0)
                Positioned(
                  top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8.r)),
                    child: Row(children: [
                      Icon(Icons.star_rounded, color: _amber, size: 13.w),
                      SizedBox(width: 3.w),
                      Text(stay.avgRating.toStringAsFixed(1),
                          style: TextStyle(color: Colors.white,
                              fontSize: 12.sp, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
          ),
          // Info section
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stay.name, style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Row(children: [
                    Icon(CupertinoIcons.map_pin, color: _gray, size: 12.w),
                    SizedBox(width: 4.w),
                    Text(stay.cityName,
                        style: TextStyle(color: _gray, fontSize: 12.sp)),
                    if (stay.hostName.isNotEmpty) ...[
                      SizedBox(width: 10.w),
                      Text('· by ${stay.hostName}',
                          style: TextStyle(color: _gray, fontSize: 12.sp)),
                    ],
                  ]),
                  SizedBox(height: 10.h),
                  Row(children: [
                    _chip2(CupertinoIcons.person_2, '${stay.maxGuests} guests'),
                    SizedBox(width: 8.w),
                    _chip2(CupertinoIcons.bed_double, '${stay.roomCount} rooms'),
                    SizedBox(width: 8.w),
                    _chip2(Icons.bathtub_outlined, '${stay.bathroomCount} baths'),
                  ]),
                  SizedBox(height: 12.h),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('From', style: TextStyle(color: _gray, fontSize: 10.sp)),
                      RichText(text: TextSpan(children: [
                        TextSpan(
                            text: 'LKR ${stay.pricePerNight.toStringAsFixed(0)}',
                            style: TextStyle(color: _blue, fontSize: 18.sp,
                                fontWeight: FontWeight.w800)),
                        TextSpan(text: '/night',
                            style: TextStyle(color: _gray, fontSize: 11.sp)),
                      ])),
                    ]),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _blue, elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 10.h)),
                      child: Text('View Stay', style: TextStyle(
                          color: Colors.white, fontSize: 13.sp,
                          fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ]),
          ),
        ]),
      ),
    );
  }

  Widget _photoFb() => Container(
      height: 180.h, width: double.infinity,
      color: Colors.grey.shade100,
      child: Icon(CupertinoIcons.house, size: 48,
          color: Colors.grey.shade300));

  Widget _chip2(IconData icon, String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: _gray, size: 12.w),
      SizedBox(width: 4.w),
      Text(label, style: TextStyle(
          color: _dark, fontSize: 11.sp, fontWeight: FontWeight.w600)),
    ]),
  );
}