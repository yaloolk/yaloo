// lib/features/tourist/screens/host/tourist_host_profile.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/features/tourist/models/stay_booking_model.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';
import 'package:yaloo/features/tourist/providers/tourist_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue       = Color(0xFF2563EB);
const _blueDark   = Color(0xFF1D4ED8);
const _blueDarker = Color(0xFF1E40AF);
const _bg         = Color(0xFFF8FAFC);
const _dark       = Color(0xFF1F2937);
const _gray       = Color(0xFF6B7280);
const _green      = Color(0xFF10B981);
const _amber      = Color(0xFFF59E0B);
const _red        = Color(0xFFEF4444);

// Facility icon map
const Map<String, IconData> _facilityIcons = {
  'wifi':      FontAwesomeIcons.wifi,
  'pool':      FontAwesomeIcons.personSwimming,
  'breakfast': FontAwesomeIcons.mugSaucer,
  'parking':   FontAwesomeIcons.squareParking,
  'kitchen':   FontAwesomeIcons.utensils,
  'laundry':   FontAwesomeIcons.shirt,
  'farm':      FontAwesomeIcons.tractor,
  'hiking':    FontAwesomeIcons.personHiking,
  'cooking':   FontAwesomeIcons.bowlFood,
  'tour':      FontAwesomeIcons.treeCity,
  'ac':        FontAwesomeIcons.snowflake,
  'tv':        FontAwesomeIcons.tv,
  'default':   FontAwesomeIcons.circleCheck,
};

IconData _iconFor(String name) {
  final lower = name.toLowerCase();
  for (final k in _facilityIcons.keys) {
    if (lower.contains(k)) return _facilityIcons[k]!;
  }
  return _facilityIcons['default']!;
}

// ─────────────────────────────────────────────────────────────────────────────
class TouristHostProfileScreen extends StatefulWidget {
  const TouristHostProfileScreen({super.key});
  @override State<TouristHostProfileScreen> createState() => _TouristHostProfileScreenState();
}

class _TouristHostProfileScreenState extends State<TouristHostProfileScreen> {
  StaySearchResult? _stay;
  String _checkin  = '';
  String _checkout = '';
  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return; // Only run once

    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    if (rawArgs == null) return;

    _argsLoaded = true;

    StaySearchResult? parsed;
    String ci = '', co = '';

    if (rawArgs is Map) {
      final rawStay = rawArgs['stay'];
      if (rawStay is StaySearchResult) {
        parsed = rawStay;
      } else if (rawStay is Map) {
        try {
          parsed = StaySearchResult.fromJson(Map<String, dynamic>.from(rawStay));
        } catch (e) {
          debugPrint('TouristHostProfile: failed to parse stay args: $e');
        }
      }
      ci = rawArgs['checkin']?.toString()  ?? '';
      co = rawArgs['checkout']?.toString() ?? '';
    } else if (rawArgs is StaySearchResult) {
      parsed = rawArgs;
    }

    if (parsed != null) {
      _stay     = parsed;
      _checkin  = ci;
      _checkout = co;

      // Trigger API in background immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StayBookingProvider>().loadStayProfile(parsed!.stayId);
      });
    }
  }

  void _openBookingForm(Map<String, dynamic>? profile) {
    if (_stay == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<StayBookingProvider>(),
        child: _BookingFormSheet(
          stay: _stay!, profile: profile,
          checkin: _checkin, checkout: _checkout,
        ),
      ),
    );
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const months = ['Jan','Feb','Mar','Apr','May','Jun', 'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  String _fmtTime(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m  = p[1].padLeft(2, '0');
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0)     h = 12;
      else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }

  // 🛡️ Ultra-safe type casters that prevent UI crashes
  String? _str(dynamic v) => (v != null && v.toString().isNotEmpty) ? v.toString() : null;
  num?    _num(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) : null);
  List    _list(dynamic v) => v is List ? v : [];
  Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : {};

  @override
  Widget build(BuildContext context) {
    if (_stay == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(backgroundColor: _blue, foregroundColor: Colors.white, title: const Text('Host Profile')),
        body: const Center(child: CircularProgressIndicator(color: _blue)),
      );
    }

    return Consumer<StayBookingProvider>(
      builder: (_, prov, __) {
        final profile      = prov.stayProfile;
        final isApiLoading = prov.profileLoading && profile == null;

        // Safely parse EVERY variable
        final name        = _str(profile?['name'])              ?? _stay!.name;
        final cityName    = _str(profile?['city_name'])         ?? _stay!.cityName;
        final desc        = _str(profile?['description'])       ?? _stay!.description;
        final hostName    = _str(profile?['host_name'])         ?? _stay!.hostName;
        final hostPhoto   = _str(profile?['host_photo'])        ?? _stay!.hostPhoto;
        final hostBio     = _str(profile?['host_bio'])          ?? '';
        final hostSince   = _str(profile?['host_member_since']) ?? '';
        final coverPhoto  = _str(profile?['cover_photo'])       ?? _stay!.coverPhoto;
        final avgRating   = _num(profile?['avg_rating'])?.toDouble()    ?? _stay!.avgRating;
        final reviewCount = _num(profile?['review_count'])?.toInt()     ?? 0;
        final maxGuests   = _num(profile?['max_guests'])?.toInt()       ?? _stay!.maxGuests;
        final roomCount   = _num(profile?['room_count'])?.toInt()       ?? _stay!.roomCount;
        final bathCount   = _num(profile?['bathroom_count'])?.toInt()   ?? _stay!.bathroomCount;
        final price       = _num(profile?['price_per_night'])?.toDouble() ?? _stay!.pricePerNight;

        final checkinTime = _str(profile?['standard_checkin_time'])  ?? '14:00';
        final checkoutTime= _str(profile?['standard_checkout_time']) ?? '11:00';
        final isVerified  = profile?['verification_status']?.toString() == 'verified';

        final photos     = _list(profile?['photos']);
        final facilities = _list(profile?['facilities']);
        final reviews    = _list(profile?['reviews']);
        final ratingMap  = _map(profile?['rating_breakdown']);

        return Scaffold(
          backgroundColor: _bg,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── HERO APP BAR ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260.h,
                pinned: true,
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
                    coverPhoto.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: coverPhoto, fit: BoxFit.cover,
                      placeholder: (_, __) => _heroBg(),
                      errorWidget:  (_, __, ___) => _heroBg(),
                    )
                        : _heroBg(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                          begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16.h, left: 16.w, right: 80.w,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (cityName.isNotEmpty)
                          Row(children: [
                            Icon(CupertinoIcons.map_pin, color: Colors.white.withOpacity(0.85), size: 12.w),
                            SizedBox(width: 4.w),
                            Flexible(child: Text(cityName, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                        SizedBox(height: 4.h),
                        Text(name, style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: -0.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                    if (isVerified)
                      Positioned(
                        bottom: 16.h, right: 16.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(color: _green.withOpacity(0.9), borderRadius: BorderRadius.circular(8.r)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.verified, color: Colors.white, size: 12.w),
                            SizedBox(width: 4.w),
                            Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                  ]),
                ),
              ),

              // ── BODY ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(height: 16.h),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(children: [
                      Expanded(child: _statChip(Icons.bed_outlined,    '$roomCount', 'Rooms')),
                      SizedBox(width: 8.w),
                      Expanded(child: _statChip(Icons.people_outline,  '$maxGuests', 'Guests')),
                      SizedBox(width: 8.w),
                      Expanded(child: _statChip(Icons.bathtub_outlined,'$bathCount', 'Baths')),
                      SizedBox(width: 8.w),
                      Expanded(child: _statChip(Icons.star_rounded, avgRating > 0 ? avgRating.toStringAsFixed(1) : 'New', 'Rating', color: _amber)),
                    ]),
                  ),
                  SizedBox(height: 16.h),

                  if (_checkin.isNotEmpty && _checkout.isNotEmpty) ...[
                    _card(
                      icon: CupertinoIcons.calendar, iconColor: _amber, title: 'Your Dates',
                      child: Row(children: [
                        Expanded(child: _dateBox('Check-in',  _fmtDate(_checkin),  _green)),
                        SizedBox(width: 12.w),
                        Expanded(child: _dateBox('Check-out', _fmtDate(_checkout), _red)),
                      ]),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  _pricingCard(profile, _stay),
                  SizedBox(height: 12.h),

                  if (isApiLoading) ...[
                    _shimmer(80.h),  SizedBox(height: 12.h),
                    _shimmer(120.h), SizedBox(height: 12.h),
                  ],

                  if (hostName.isNotEmpty) ...[
                    _card(
                      icon: Icons.person_outline_rounded, iconColor: _blue, title: 'Your Host',
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _avatar(hostPhoto, 28.r),
                        SizedBox(width: 12.w),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(hostName, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
                          if (hostSince.isNotEmpty) ...[ SizedBox(height: 2.h), Text('Hosting since $hostSince', style: TextStyle(fontSize: 11.sp, color: _gray)) ],
                          if (hostBio.isNotEmpty) ...[ SizedBox(height: 8.h), Text(hostBio, style: TextStyle(fontSize: 13.sp, color: _gray, height: 1.5)) ],
                        ])),
                      ]),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  if (desc.isNotEmpty) ...[
                    _card(
                      icon: Icons.home_outlined, iconColor: _blue, title: 'About This Stay',
                      child: Text(desc, style: TextStyle(fontSize: 14.sp, color: _dark, height: 1.6)),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  _card(
                    icon: CupertinoIcons.clock, iconColor: _green, title: 'Check-in / Check-out',
                    child: Row(children: [
                      Expanded(child: _timeBox('Check-in',  _fmtTime(checkinTime),  _green)),
                      SizedBox(width: 12.w),
                      Expanded(child: _timeBox('Check-out', _fmtTime(checkoutTime), _red)),
                    ]),
                  ),
                  SizedBox(height: 12.h),

                  if (photos.isNotEmpty) ...[
                    _sectionHeader('Gallery', Icons.photo_library_outlined, _blue),
                    SizedBox(height: 10.h),
                    SizedBox(
                      height: 120.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 16.w),
                        physics: const BouncingScrollPhysics(), itemCount: photos.length,
                        itemBuilder: (_, i) {
                          final item = photos[i];
                          String url = '';
                          if (item is Map) url = (item['photo_url'] ?? item['url'] ?? '').toString();
                          else if (item is String) url = item;

                          return Container(
                            width: 140.w, margin: EdgeInsets.only(right: 10.w),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14.r),
                              child: url.isNotEmpty
                                  ? CachedNetworkImage(imageUrl: url, fit: BoxFit.cover, errorWidget: (_, __, ___) => _photoFb())
                                  : _photoFb(),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  if (facilities.isNotEmpty) ...[
                    _card(
                      icon: Icons.room_service_outlined, iconColor: _blue, title: 'Facilities & Amenities',
                      child: GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, crossAxisSpacing: 10.w, mainAxisSpacing: 8.h, childAspectRatio: 3.5,
                        ),
                        itemCount: facilities.length,
                        itemBuilder: (_, i) {
                          final f = facilities[i];
                          final fname = (f is Map ? f['name'] : f.toString()) ?? '';
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Colors.grey.shade200)),
                            child: Row(children: [
                              Icon(_iconFor(fname.toString()), color: _blue, size: 14.w),
                              SizedBox(width: 6.w),
                              Expanded(child: Text(fname.toString(), style: TextStyle(fontSize: 11.sp, color: _dark, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                            ]),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],

                  if (avgRating > 0 || reviews.isNotEmpty) ...[
                    _reviewsSection(avgRating, reviewCount, ratingMap, reviews),
                    SizedBox(height: 12.h),
                  ],

                  _verificationCard(isVerified),
                  SizedBox(height: 100.h),
                ]),
              ),
            ],
          ),
          bottomNavigationBar: _bottomBar(profile, price),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // WIDGET HELPERS
  // ─────────────────────────────────────────────────────────

  Widget _heroBg() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [_blue, _blueDarker], begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: Icon(Icons.home_work_rounded, color: Colors.white.withOpacity(0.2), size: 80.w),
  );

  Widget _photoFb() => Container(
    color: _blue.withOpacity(0.08),
    child: Icon(Icons.image_outlined, color: _blue.withOpacity(0.3), size: 32.w),
  );

  Widget _avatar(String url, double radius) => CircleAvatar(
    radius: radius, backgroundColor: _blue.withOpacity(0.1),
    backgroundImage: url.isNotEmpty ? CachedNetworkImageProvider(url) : null,
    child: url.isEmpty ? Icon(CupertinoIcons.person, color: _blue, size: radius * 0.75) : null,
  );

  Widget _statChip(IconData icon, String value, String label, {Color color = _blue}) => Container(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r), boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4), spreadRadius: -2)]),
    child: Column(children: [
      Icon(icon, color: color, size: 16.w),
      SizedBox(height: 4.h),
      Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: _dark)),
      Text(label, style: TextStyle(fontSize: 9.sp, color: _gray)),
    ]),
  );

  Widget _timeBox(String label, String value, Color color) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600)),
      SizedBox(height: 4.h),
      Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: _dark)),
    ]),
  );

  Widget _dateBox(String label, String value, Color color) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: color.withOpacity(0.25))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600)),
      SizedBox(height: 3.h),
      Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: _dark)),
    ]),
  );

  Widget _pricingCard(Map<String, dynamic>? p, StaySearchResult? s) {
    final perNight    = _num(p?['price_per_night'])?.toDouble()    ?? s?.pricePerNight    ?? 0;
    final entirePlace = _num(p?['price_entire_place'])?.toDouble() ?? s?.priceEntirePlace ?? 0;
    final halfday     = _num(p?['price_per_halfday'])?.toDouble()  ?? s?.pricePerHalfday  ?? 0;
    final entireAvail  = (p?['entire_place_is_available']?.toString() == 'true') || (s?.entirePlaceIsAvailable == true);
    final halfdayAvail = (p?['halfday_available']?.toString()         == 'true') || (s?.halfdayAvailable == true);

    return _card(
      icon: FontAwesomeIcons.tag, iconColor: _blue, title: 'Pricing',
      child: Column(children: [
        _priceRow('Per Night', 'LKR ${perNight.toStringAsFixed(0)}', _blue),
        if (entireAvail && entirePlace > 0) ...[ SizedBox(height: 8.h), _priceRow('Entire Place / Night', 'LKR ${entirePlace.toStringAsFixed(0)}', _green) ],
        if (halfdayAvail && halfday > 0) ...[ SizedBox(height: 8.h), _priceRow('Half Day', 'LKR ${halfday.toStringAsFixed(0)}', const Color(0xFF8B5CF6)) ],
      ]),
    );
  }

  Widget _priceRow(String label, String price, Color color) => Row(children: [
    Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)), child: Text(label, style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w700))),
    const Spacer(),
    Text(price, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
  ]);

  Widget _reviewsSection(double avg, int count, Map<String, dynamic> breakdown, List reviews) {
    return _card(
      icon: Icons.star_rounded, iconColor: _amber, title: 'Ratings & Reviews ($count)',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(avg.toStringAsFixed(1), style: TextStyle(fontSize: 44.sp, fontWeight: FontWeight.w800, color: _dark, height: 1)),
          SizedBox(width: 12.w),
          Padding(padding: EdgeInsets.only(bottom: 6.h), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ _starRow(avg), SizedBox(height: 4.h), Text('$count review${count != 1 ? 's' : ''}', style: TextStyle(fontSize: 12.sp, color: _gray)) ])),
        ]),
        SizedBox(height: 12.h),
        for (int s = 5; s >= 1; s--) ...[ _ratingBar('$s', _num(breakdown['$s'])?.toInt() ?? 0, count), SizedBox(height: 4.h) ],
        if (reviews.isNotEmpty) ...[
          SizedBox(height: 14.h),
          ...reviews.take(3).map((r) => _reviewCard(r is Map ? Map<String, dynamic>.from(r) : {})),
        ],
      ]),
    );
  }

  Widget _starRow(double rating) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      if (i < rating.floor()) return Icon(CupertinoIcons.star_fill, color: _amber, size: 14.w);
      if (i < rating) return Icon(CupertinoIcons.star_lefthalf_fill, color: _amber, size: 14.w);
      return Icon(CupertinoIcons.star, color: _amber, size: 14.w);
    }),
  );

  Widget _ratingBar(String label, int count, int total) {
    final pct = total == 0 ? 0.0 : count / total;
    return Row(children: [
      SizedBox(width: 16.w, child: Text(label, style: TextStyle(fontSize: 11.sp, color: _gray))),
      SizedBox(width: 8.w),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6.r), child: LinearProgressIndicator(value: pct, backgroundColor: Colors.grey.shade200, color: _amber, minHeight: 7.h))),
      SizedBox(width: 8.w),
      SizedBox(width: 18.w, child: Text('$count', style: TextStyle(fontSize: 10.sp, color: _gray), textAlign: TextAlign.right)),
    ]);
  }

  Widget _reviewCard(Map<String, dynamic> r) {
    final photo  = _str(r['tourist_photo']) ?? '';
    final rname  = _str(r['tourist_name'])  ?? 'Guest';
    final text   = _str(r['review'])        ?? '';
    final rating = _num(r['rating'])?.toDouble() ?? 5.0;
    final date   = _str(r['created_at'])    ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 10.h), padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: Colors.black.withOpacity(0.06))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16.r, backgroundColor: _blue.withOpacity(0.1), backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null, child: photo.isEmpty ? Icon(CupertinoIcons.person, color: _blue, size: 14.w) : null),
          SizedBox(width: 10.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [ Text(rname, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _dark)), if (date.isNotEmpty) Text(_fmtDate(date), style: TextStyle(fontSize: 10.sp, color: _gray)) ])),
          _starRow(rating),
        ]),
        if (text.isNotEmpty) ...[ SizedBox(height: 8.h), Text(text, style: TextStyle(fontSize: 13.sp, color: _gray, height: 1.4)) ],
      ]),
    );
  }

  Widget _verificationCard(bool isVerified) {
    final color = isVerified ? _green : _amber;
    return Padding(padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: color.withOpacity(0.07), borderRadius: BorderRadius.circular(18.r), border: Border.all(color: color.withOpacity(0.25))),
        child: Row(children: [
          Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12.r)), child: Icon(isVerified ? CupertinoIcons.checkmark_shield_fill : CupertinoIcons.exclamationmark_shield, color: color, size: 22)),
          SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isVerified ? 'Verified Host' : 'Verification Pending', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color)),
            SizedBox(height: 3.h),
            Text(isVerified ? 'This stay is verified and trusted by Yaloo.' : 'This stay is currently under review.', style: TextStyle(fontSize: 12.sp, color: _gray)),
          ])),
        ]),
      ),
    );
  }

  Widget _shimmer(double h) => Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Container(height: h, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20.r))));

  Widget _sectionHeader(String title, IconData icon, Color color) => Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: Row(children: [ Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(icon, color: color, size: 18)), SizedBox(width: 10.w), Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)) ]));

  Widget _card({required IconData icon, required Color iconColor, required String title, required Widget child}) => Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w), padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 14, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [ Container(padding: EdgeInsets.all(8.r), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10.r)), child: Icon(icon, color: iconColor, size: 16)), SizedBox(width: 10.w), Flexible(child: Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark))) ]),
      SizedBox(height: 14.h),
      child,
    ]),
  );

  Widget _bottomBar(Map<String, dynamic>? profile, double price) => Container(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
    decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))]),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text('LKR ${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: _blue)),
        Text('per night', style: TextStyle(fontSize: 11.sp, color: _gray)),
      ])),
      SizedBox(height: 50.h, child: ElevatedButton.icon(
        onPressed: () => _openBookingForm(profile), icon: Icon(CupertinoIcons.calendar_badge_plus, size: 16.w),
        label: Text('Reserve Stay', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)), padding: EdgeInsets.symmetric(horizontal: 22.w)),
      )),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BOOKING FORM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _BookingFormSheet extends StatefulWidget {
  final StaySearchResult stay;
  final Map<String, dynamic>? profile;
  final String checkin;
  final String checkout;
  const _BookingFormSheet({
    required this.stay, this.profile,
    required this.checkin, required this.checkout,
  });
  @override State<_BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<_BookingFormSheet> {
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _noteCtrl     = TextEditingController();

  int    _guests     = 1;
  int    _rooms      = 1;
  String _meal       = 'none';
  String _bookType   = 'per_night';
  bool   _submitting = false;

  static const _meals = ['none', 'veg', 'non_veg', 'halal'];
  static const _mealLabels = {
    'none':    'No Preference',
    'veg':     'Vegetarian',
    'non_veg': 'Non-Vegetarian',
    'halal':   'Halal',
  };

  @override
  void initState() {
    super.initState();
    // Pre-fill tourist info if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final t = context.read<TouristProvider>().profile;
        if (t != null) {
          if (t.fullName.isNotEmpty)    _nameCtrl.text  = t.fullName;
          if (t.phoneNumber.isNotEmpty) _phoneCtrl.text = t.phoneNumber;
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _emailCtrl.dispose(); _passportCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  int get _nights {
    try {
      return DateTime.parse(widget.checkout)
          .difference(DateTime.parse(widget.checkin))
          .inDays;
    } catch (_) { return 1; }
  }

  double get _pricePerNight {
    final p = widget.profile;
    final s = widget.stay;
    switch (_bookType) {
      case 'entire_place':
        return (p?['price_entire_place'] as num?)?.toDouble() ?? s.priceEntirePlace;
      case 'halfday':
        return (p?['price_per_halfday'] as num?)?.toDouble()  ?? s.pricePerHalfday;
      default:
        return (p?['price_per_night'] as num?)?.toDouble()    ?? s.pricePerNight;
    }
  }

  double get _total {
    if (_bookType == 'halfday') return _pricePerNight;
    return _pricePerNight * _nights * _rooms;
  }

  String _fmtDate(String d) {
    try {
      final dt = DateTime.parse(d);
      const m  = ['Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${m[dt.month - 1]} ${dt.year}';
    } catch (_) { return d; }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    backgroundColor: _dark,
  ));

  Future<void> _confirm() async {
    if (_nameCtrl.text.trim().isEmpty)  { _snack('Please enter your full name');    return; }
    if (_phoneCtrl.text.trim().isEmpty) { _snack('Please enter your phone number'); return; }
    if (_emailCtrl.text.trim().isEmpty) { _snack('Please enter your email');        return; }
    if (_nights < 1)                    { _snack('Invalid check-in/out dates');      return; }

    setState(() => _submitting = true);

    final prov = context.read<StayBookingProvider>();
    final ok   = await prov.createBooking(
      stayId:          widget.stay.stayId,
      checkinDate:     widget.checkin,
      checkoutDate:    widget.checkout,
      bookingType:     _bookType,
      roomCount:       _rooms,
      guestCount:      _guests,
      mealPreference:  _meal,
      specialNote:     _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      touristFullName: _nameCtrl.text.trim(),
      touristPassport: _passportCtrl.text.trim().isNotEmpty ? _passportCtrl.text.trim() : null,
      touristPhone:    _phoneCtrl.text.trim(),
      touristEmail:    _emailCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.pop(context);
      Navigator.pushNamed(context, '/stayBookingConfirmation',
          arguments: prov.lastCreatedBooking?.toJson());
    } else {
      _snack(prov.createError.isNotEmpty
          ? prov.createError
          : 'Booking failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final s = widget.stay;
    final entireAvail  = (p?['entire_place_is_available'] as bool?) ?? s.entirePlaceIsAvailable;
    final halfdayAvail = (p?['halfday_available']         as bool?) ?? s.halfdayAvailable;

    return DraggableScrollableSheet(
      initialChildSize: 0.92, minChildSize: 0.5, maxChildSize: 0.95,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          // Drag handle
          Container(margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 48, height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
          // Header
          Padding(padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Reserve Stay', style: TextStyle(
                    fontSize: 20.sp, fontWeight: FontWeight.w800, color: _dark)),
                Text(s.name, style: TextStyle(fontSize: 13.sp, color: _gray)),
              ])),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                    child: Icon(Icons.close, color: Colors.grey.shade600)),
              ),
            ]),
          ),
          Divider(height: 16.h, indent: 20.w, endIndent: 20.w),

          Expanded(child: SingleChildScrollView(
            controller: sc,
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Dates summary
              Container(padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _blue.withOpacity(0.08), _blue.withOpacity(0.04)]),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: _blue.withOpacity(0.15))),
                  child: Row(children: [
                    Expanded(child: Column(children: [
                      Text('Check-in',
                          style: TextStyle(fontSize: 11.sp, color: _gray)),
                      SizedBox(height: 3.h),
                      Text(_fmtDate(widget.checkin), style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w800, color: _dark)),
                    ])),
                    Container(width: 1, height: 36.h, color: _blue.withOpacity(0.2)),
                    Expanded(child: Column(children: [
                      Text('Check-out',
                          style: TextStyle(fontSize: 11.sp, color: _gray)),
                      SizedBox(height: 3.h),
                      Text(_fmtDate(widget.checkout), style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w800, color: _dark)),
                    ])),
                    Container(width: 1, height: 36.h, color: _blue.withOpacity(0.2)),
                    Expanded(child: Column(children: [
                      Text('Nights',
                          style: TextStyle(fontSize: 11.sp, color: _gray)),
                      SizedBox(height: 3.h),
                      Text('$_nights', style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w800, color: _blue)),
                    ])),
                  ])),
              SizedBox(height: 20.h),

              // Booking type
              _lbl('Booking Type'),
              Wrap(spacing: 8.w, runSpacing: 8.h, children: [
                _typeBtn('per_night',    'Per Night'),
                if (entireAvail)  _typeBtn('entire_place', 'Entire Place'),
                if (halfdayAvail) _typeBtn('halfday',      'Half Day'),
              ]),
              SizedBox(height: 16.h),

              // Guests / Rooms
              Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _lbl('Guests'),
                  _counter(value: _guests,
                      onDec: _guests > 1 ? () => setState(() => _guests--) : null,
                      onInc: () => setState(() => _guests++)),
                ])),
                if (_bookType != 'entire_place' && _bookType != 'halfday') ...[
                  SizedBox(width: 12.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _lbl('Rooms'),
                    _counter(value: _rooms,
                        onDec: _rooms > 1 ? () => setState(() => _rooms--) : null,
                        onInc: () => setState(() => _rooms++)),
                  ])),
                ],
              ]),
              SizedBox(height: 16.h),

              // Meal
              _lbl('Meal Preference'),
              Wrap(spacing: 8.w, runSpacing: 8.h,
                  children: _meals.map((m) => GestureDetector(
                    onTap: () => setState(() => _meal = m),
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                            color: _meal == m ? _blue : Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: _meal == m ? _blue : Colors.grey.shade200,
                                width: _meal == m ? 1.5 : 1)),
                        child: Text(_mealLabels[m]!, style: TextStyle(
                            color: _meal == m ? Colors.white : _dark,
                            fontSize: 12.sp, fontWeight: FontWeight.w600))),
                  )).toList()),
              SizedBox(height: 20.h),

              // Tourist info
              _lbl('Your Information', req: true),
              _field(_nameCtrl,     'Full Name *',        TextInputType.text,         Icons.person_outline),
              SizedBox(height: 10.h),
              _field(_phoneCtrl,    'Phone Number *',     TextInputType.phone,        Icons.phone_outlined),
              SizedBox(height: 10.h),
              _field(_emailCtrl,    'Email Address *',    TextInputType.emailAddress, Icons.email_outlined),
              SizedBox(height: 10.h),
              _field(_passportCtrl, 'Passport No. (opt)', TextInputType.text,         Icons.document_scanner_outlined),
              SizedBox(height: 16.h),

              // Special note
              _lbl('Special Requests (optional)'),
              TextField(controller: _noteCtrl, maxLines: 3,
                  style: TextStyle(fontSize: 13.sp, color: _dark),
                  decoration: InputDecoration(
                    hintText: 'Any special requests or preferences…',
                    hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
                    filled: true, fillColor: _bg,
                    contentPadding: EdgeInsets.all(14.w),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: _blue, width: 1.5)),
                  )),
              SizedBox(height: 24.h),

              // Price summary
              Container(padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        _blue.withOpacity(0.07), _blue.withOpacity(0.03)]),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: _blue.withOpacity(0.15))),
                  child: Column(children: [
                    _priceRowForm(
                        'LKR ${_pricePerNight.toStringAsFixed(0)}',
                        _bookType == 'halfday'
                            ? 'Half day rate'
                            : '$_rooms room${_rooms > 1 ? 's' : ''} × $_nights night${_nights > 1 ? 's' : ''}'),
                    Divider(height: 16.h, color: _blue.withOpacity(0.15)),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total', style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
                      Text('LKR ${_total.toStringAsFixed(0)}', style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w800, color: _blue)),
                    ]),
                  ])),
              SizedBox(height: 24.h),

              // Confirm
              SizedBox(width: double.infinity, height: 52.h,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _blue, foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r))),
                  child: _submitting
                      ? SizedBox(width: 22.w, height: 22.h,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                      : Text('Confirm Booking',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _typeBtn(String val, String label) => GestureDetector(
    onTap: () => setState(() => _bookType = val),
    child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
            color: _bookType == val ? _blue : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: _bookType == val ? _blue : Colors.grey.shade200,
                width: _bookType == val ? 1.5 : 1)),
        child: Text(label, style: TextStyle(
            color: _bookType == val ? Colors.white : _dark,
            fontSize: 13.sp, fontWeight: FontWeight.w600))),
  );

  Widget _counter({required int value, VoidCallback? onDec,
    required VoidCallback onInc}) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12.r)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: onDec, child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                  color: onDec != null ? _blue.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Icons.remove, size: 14.w,
                  color: onDec != null ? _blue : Colors.grey.shade400))),
          Text('$value', style: TextStyle(
              fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
          GestureDetector(onTap: onInc, child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(color: _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Icons.add, size: 14.w, color: _blue))),
        ]),
      );

  Widget _field(TextEditingController ctrl, String hint,
      TextInputType type, IconData icon) =>
      TextField(controller: ctrl, keyboardType: type,
          style: TextStyle(fontSize: 14.sp, color: _dark),
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
            prefixIcon: Icon(icon, color: _gray, size: 18.w),
            filled: true, fillColor: _bg,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: _blue, width: 1.5)),
          ));

  Widget _lbl(String t, {bool req = false}) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text.rich(TextSpan(
      text: t,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _dark),
      children: req
          ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red.shade400))]
          : [],
    )),
  );

  Widget _priceRowForm(String price, String label) => Row(children: [
    Text(label, style: TextStyle(fontSize: 13.sp, color: _gray)),
    const Spacer(),
    Text(price, style: TextStyle(
        fontSize: 14.sp, fontWeight: FontWeight.w700, color: _dark)),
  ]);
}