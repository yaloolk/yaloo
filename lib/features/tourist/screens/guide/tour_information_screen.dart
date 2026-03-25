// lib/features/tourist/screens/guide/tour_information_screen.dart
//
// Pickup Location — three modes inside _LocationPickerDialog:
//   1. Google Maps   → google_maps_flutter  (draggable marker + address resolve)
//   2. DB Locations  → searchable table from your backend / static list
//   3. Manual Coords → latitude / longitude text fields
//
// Dependencies to add in pubspec.yaml:
//   google_maps_flutter: ^2.6.1
//   geocoding: ^3.0.0          (reverse-geocode the map pin)
//   (everything else was already present)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import '../../providers/guide_booking_provider.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _blue     = Color(0xFF2563EB);
const _blueDark = Color(0xFF1D4ED8);
const _bgPage   = Color(0xFFF8FAFC);
const _dark     = Color(0xFF1F2937);
const _gray     = Color(0xFF6B7280);
const _green    = Color(0xFF10B981);
const _amber    = Color(0xFFF59E0B);

enum _Who { solo, couple, group }

// ── DB Location model ─────────────────────────────────────────────────────────
// Replace with your real model / API call.
class _DbLocation {
  final String id;
  final String name;
  final String region;
  final String category; // e.g. Beach, Heritage, City …
  final double lat;
  final double lng;

  const _DbLocation({
    required this.id,
    required this.name,
    required this.region,
    required this.category,
    required this.lat,
    required this.lng,
  });
}

// ── Static DB seed (swap with real fetch) ────────────────────────────────────
const List<_DbLocation> _kDbLocations = [
  _DbLocation(id:'1',  name:'Colombo Fort',       region:'Western',   category:'City',     lat:6.9345,  lng:79.8428),
  _DbLocation(id:'2',  name:'Galle Fort',          region:'Southern',  category:'Heritage', lat:6.0328,  lng:80.2170),
  _DbLocation(id:'3',  name:'Kandy City Centre',   region:'Central',   category:'City',     lat:7.2906,  lng:80.6337),
  _DbLocation(id:'4',  name:'Sigiriya Rock',       region:'North C.',  category:'Heritage', lat:7.9570,  lng:80.7603),
  _DbLocation(id:'5',  name:'Ella Town',           region:'Uva',       category:'Nature',   lat:6.8667,  lng:81.0467),
  _DbLocation(id:'6',  name:'Mirissa Beach',       region:'Southern',  category:'Beach',    lat:5.9485,  lng:80.4716),
  _DbLocation(id:'7',  name:'Nuwara Eliya',        region:'Central',   category:'Nature',   lat:6.9497,  lng:80.7891),
  _DbLocation(id:'8',  name:'Trincomalee Harbour', region:'Eastern',   category:'Beach',    lat:8.5874,  lng:81.2152),
  _DbLocation(id:'9',  name:'Negombo Beach',       region:'Western',   category:'Beach',    lat:7.2008,  lng:79.8380),
  _DbLocation(id:'10', name:'Polonnaruwa',         region:'North C.',  category:'Heritage', lat:7.9403,  lng:81.0188),
  _DbLocation(id:'11', name:'Anuradhapura',        region:'North C.',  category:'Heritage', lat:8.3114,  lng:80.4037),
  _DbLocation(id:'12', name:'Arugam Bay',          region:'Eastern',   category:'Beach',    lat:6.8403,  lng:81.8313),
  _DbLocation(id:'13', name:'Yala National Park',  region:'Southern',  category:'Nature',   lat:6.3729,  lng:81.5209),
  _DbLocation(id:'14', name:'Wilpattu NP Gate',    region:'North W.',  category:'Nature',   lat:8.4000,  lng:80.0300),
  _DbLocation(id:'15', name:'Bandaranaike Airport',region:'Western',   category:'Airport',  lat:7.1803,  lng:79.8844),
];

// ─────────────────────────────────────────────────────────────────────────────
// TourInformationScreen
// ─────────────────────────────────────────────────────────────────────────────
class TourInformationScreen extends StatefulWidget {
  const TourInformationScreen({super.key});

  @override
  State<TourInformationScreen> createState() => _TourInformationScreenState();
}

class _TourInformationScreenState extends State<TourInformationScreen> {
  // ── Route args ──────────────────────────────────────────────────────────────
  Map<String, dynamic> _guide       = {};
  String               _bookingDate = '';
  String               _startTime   = '';
  String               _endTime     = '';
  int                  _slotCount   = 1;
  bool                 _argsLoaded  = false;

  // ── Form state ──────────────────────────────────────────────────────────────
  _Who   _who = _Who.solo;
  final  _noteCtrl = TextEditingController();

  // Pickup result
  double? _lat;
  double? _lng;
  String  _pickupLabel = '';   // human-readable label shown in the chip

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _guide       = (args['guide'] as Map?)?.cast<String, dynamic>() ?? {};
      _bookingDate = args['booking_date']?.toString() ?? '';
      _startTime   = args['start_time']?.toString()  ?? '';
      _endTime     = args['end_time']?.toString()    ?? '';
      _slotCount   = (args['slot_count'] as num?)?.toInt() ?? 1;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Computed ─────────────────────────────────────────────────────────────────
  int    get _guests => _who == _Who.solo ? 1 : _who == _Who.couple ? 2 : 5;
  double get _rate   => (_guide['rate_per_hour'] as num?)?.toDouble() ?? 0;
  double get _hours  => _slotCount.toDouble();
  double get _total  => _rate * _hours;

  String _fmt(String t) {
    try {
      final p  = t.split(':');
      int   h  = int.parse(p[0]);
      final m  = p[1];
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }

  // ── Open location picker ──────────────────────────────────────────────────
  Future<void> _openLocationPicker() async {
    final res = await showDialog<_PickupResult>(
      context: context,
      useSafeArea: false,
      builder: (_) => _LocationPickerDialog(
        initialLat: _lat,
        initialLng: _lng,
      ),
    );
    if (res != null) {
      setState(() {
        _lat         = res.lat;
        _lng         = res.lng;
        _pickupLabel = res.label;
      });
    }
  }

  // ── Confirm booking ───────────────────────────────────────────────────────
  Future<void> _confirm() async {
    if (_lat == null) {
      _snack('Please choose a pickup location');
      return;
    }

    final prov = context.read<GuideBookingProvider>();
    final ok   = await prov.createBooking(
      guideProfileId:  (_guide['guide_profile_id'] ?? '').toString(),
      bookingDate:     _bookingDate,
      startTime:       _startTime,
      endTime:         _endTime,
      guestCount:      _guests,
      pickupLatitude:  _lat,
      pickupLongitude: _lng,
      pickupAddress:   _pickupLabel.isNotEmpty ? _pickupLabel : null,
      specialNote:     _noteCtrl.text.trim().isNotEmpty
          ? _noteCtrl.text.trim() : null,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/bookingConfirmation',
          arguments: {'booking': prov.lastCreatedBooking});
    } else {
      _snack(prov.bookingsError.isNotEmpty
          ? prov.bookingsError : 'Booking failed. Please try again.');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomAppBar(title: 'Tour Information'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 110.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _guideCard(),
          SizedBox(height: 16.h),
          _bookingInfoCard(),
          SizedBox(height: 20.h),
          _sectionTitle("Who's Traveling?"),
          SizedBox(height: 10.h),
          _travelerRow(),
          SizedBox(height: 20.h),
          _sectionTitle('Pickup Location'),
          Text('Choose from map, saved locations, or enter coordinates',
              style: TextStyle(color: _gray, fontSize: 11.sp)),
          SizedBox(height: 10.h),
          _pickupSection(),
          SizedBox(height: 20.h),
          _sectionTitle('Special Note'),
          Text('Optional — any requests or preferences',
              style: TextStyle(color: _gray, fontSize: 11.sp)),
          SizedBox(height: 8.h),
          _noteField(),
          SizedBox(height: 20.h),
          _summaryCard(),
        ]),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  // ── Guide card ────────────────────────────────────────────────────────────
  Widget _guideCard() {
    final pic  = (_guide['profile_pic'] ?? '').toString();
    final name = (_guide['full_name'] ?? '').toString();
    final city = ((_guide['city'] as Map?)?['name'] ?? '').toString();
    final avg  = (_guide['avg_rating'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDec(),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: pic.isNotEmpty
              ? CachedNetworkImage(imageUrl: pic,
              width: 62.w, height: 72.h, fit: BoxFit.cover,
              placeholder:  (_, __) => _avatarBox(),
              errorWidget: (_, __, ___) => _avatarBox())
              : _avatarBox(),
        ),
        SizedBox(width: 14.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: TextStyle(
              fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
          SizedBox(height: 3.h),
          if (city.isNotEmpty) Row(children: [
            Icon(CupertinoIcons.map_pin, color: _gray, size: 11.w),
            SizedBox(width: 3.w),
            Text(city, style: TextStyle(color: _gray, fontSize: 11.sp)),
          ]),
          SizedBox(height: 3.h),
          Row(children: [
            Icon(Icons.star_rounded, color: _amber, size: 13.w),
            SizedBox(width: 3.w),
            Text(avg.toStringAsFixed(1), style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 12.sp, color: _dark)),
          ]),
        ])),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_blue, _blueDark]),
              borderRadius: BorderRadius.circular(12.r)),
          child: Column(children: [
            Text('LKR ${_rate.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.white,
                    fontSize: 13.sp, fontWeight: FontWeight.w800)),
            Text('/hr', style: TextStyle(color: Colors.white70, fontSize: 9.sp)),
          ]),
        ),
      ]),
    );
  }

  Widget _avatarBox() => Container(
      width: 62.w, height: 72.h,
      decoration: BoxDecoration(color: _blue.withOpacity(0.08)),
      child: Icon(CupertinoIcons.person_fill,
          color: _blue.withOpacity(0.35), size: 26.w));

  // ── Booking info ──────────────────────────────────────────────────────────
  Widget _bookingInfoCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue.withOpacity(0.08), _blue.withOpacity(0.04)]),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _blue.withOpacity(0.15))),
    child: Column(children: [
      _infoRow(CupertinoIcons.calendar,        'Date',     _bookingDate),
      SizedBox(height: 10.h),
      _infoRow(CupertinoIcons.time,            'Time',
          '${_fmt(_startTime)} – ${_fmt(_endTime)}'),
      SizedBox(height: 10.h),
      _infoRow(FontAwesomeIcons.hourglassHalf, 'Duration',
          '$_hours hr${_hours > 1 ? "s" : ""}'),
    ]),
  );

  Widget _infoRow(dynamic icon, String label, String value) =>
      Row(children: [
        Icon(icon, color: _blue, size: 15.w),
        SizedBox(width: 10.w),
        Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
        const Spacer(),
        Text(value, style: TextStyle(
            color: _dark, fontSize: 13.sp, fontWeight: FontWeight.w700)),
      ]);

  // ── Traveler toggle ───────────────────────────────────────────────────────
  Widget _travelerRow() => Row(children: [
    Expanded(child: _whoCard(_Who.solo,   FontAwesomeIcons.user,      'Solo')),
    SizedBox(width: 10.w),
    Expanded(child: _whoCard(_Who.couple, FontAwesomeIcons.userGroup, 'Couple')),
    SizedBox(width: 10.w),
    Expanded(child: _whoCard(_Who.group,  FontAwesomeIcons.users,     'Group')),
  ]);

  Widget _whoCard(_Who type, IconData icon, String label) {
    final sel = _who == type;
    return GestureDetector(
      onTap: () => setState(() => _who = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: sel ? const LinearGradient(colors: [_blue, _blueDark]) : null,
          color: sel ? null : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: sel ? _blue : Colors.grey.shade200, width: 1.5),
          boxShadow: sel
              ? [BoxShadow(color: _blue.withOpacity(0.35),
              blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Icon(icon, color: sel ? Colors.white : _blue, size: 22.w),
          SizedBox(height: 6.h),
          Text(label, style: TextStyle(
              color: sel ? Colors.white : _dark,
              fontSize: 12.sp, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  // ── Pickup section ────────────────────────────────────────────────────────
  Widget _pickupSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Tap-to-open card
      GestureDetector(
        onTap: _openLocationPicker,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _lat != null ? _blue : Colors.grey.shade200,
              width: _lat != null ? 1.8 : 1.0,
            ),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_blue, _blueDark]),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Icon(CupertinoIcons.map_pin_ellipse,
                  color: Colors.white, size: 18.w),
            ),
            SizedBox(width: 12.w),
            Expanded(child: _lat == null
                ? Text('Tap to choose pickup location',
                style: TextStyle(color: _gray, fontSize: 13.sp))
                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_pickupLabel, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _dark, fontSize: 13.sp,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 2.h),
              Text('${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
                  style: TextStyle(color: _gray, fontSize: 10.sp)),
            ])),
            SizedBox(width: 8.w),
            Icon(
              _lat != null
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.chevron_right,
              color: _lat != null ? _green : _gray,
              size: _lat != null ? 20.w : 16.w,
            ),
          ]),
        ),
      ),
      SizedBox(height: 8.h),
      if (_lat != null)
        Row(children: [
          Icon(CupertinoIcons.checkmark_circle_fill, color: _green, size: 13.w),
          SizedBox(width: 5.w),
          Text('Pickup location confirmed ✓',
              style: TextStyle(color: _green, fontSize: 11.sp,
                  fontWeight: FontWeight.w700)),
          const Spacer(),
          GestureDetector(
            onTap: _openLocationPicker,
            child: Text('Change', style: TextStyle(
                color: _blue, fontSize: 11.sp, fontWeight: FontWeight.w700)),
          ),
        ])
      else
        Row(children: [
          Icon(CupertinoIcons.info_circle, color: _gray, size: 12.w),
          SizedBox(width: 5.w),
          Expanded(child: Text(
              'Choose from Google Maps, saved locations, or enter coords',
              style: TextStyle(color: _gray, fontSize: 11.sp))),
        ]),
    ],
  );

  // ── Note field ────────────────────────────────────────────────────────────
  Widget _noteField() => TextField(
    controller: _noteCtrl,
    maxLines: 3,
    style: TextStyle(fontSize: 13.sp, color: _dark),
    decoration: InputDecoration(
      hintText: 'Any preferences, languages, or requests…',
      hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
      filled: true, fillColor: Colors.white,
      contentPadding: EdgeInsets.all(14.w),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: _blue, width: 1.5)),
    ),
  );

  // ── Price summary ─────────────────────────────────────────────────────────
  Widget _summaryCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: _cardDec(),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
                color: _blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r)),
            child: Icon(FontAwesomeIcons.receipt, color: _blue, size: 15.w)),
        SizedBox(width: 10.w),
        Text('Price Summary', style: TextStyle(
            fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark)),
      ]),
      SizedBox(height: 14.h),
      _prRow('Rate per hour', 'LKR ${_rate.toStringAsFixed(0)}'),
      _divider(),
      _prRow('Duration', '${_hours.toStringAsFixed(1)} hr${_hours > 1 ? "s" : ""}'),
      _divider(),
      _prRow('Travelers', '$_guests person${_guests > 1 ? "s" : ""}'),
      _divider(),
      _prRow('Total', 'LKR ${_total.toStringAsFixed(2)}',
          bold: true, color: _blue),
    ]),
  );

  Widget _prRow(String l, String v, {bool bold = false, Color? color}) =>
      Padding(padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(children: [
            Text(l, style: TextStyle(color: _gray, fontSize: 12.sp)),
            const Spacer(),
            Text(v, style: TextStyle(
                color: color ?? _dark,
                fontSize: bold ? 16.sp : 13.sp,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ]));

  Widget _divider() =>
      Divider(color: Colors.grey.shade100, height: 16.h, thickness: 1);

  Widget _sectionTitle(String t) => Text(t, style: TextStyle(
      fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark));

  BoxDecoration _cardDec() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.045),
        blurRadius: 16, offset: const Offset(0, 4))],
  );

  // ── Bottom bar ────────────────────────────────────────────────────────────
  Widget _bottomBar() => Consumer<GuideBookingProvider>(
    builder: (_, prov, __) => Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20, offset: const Offset(0, -4))]),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total', style: TextStyle(color: _gray, fontSize: 13.sp)),
          Text('LKR ${_total.toStringAsFixed(2)}',
              style: TextStyle(color: _blue, fontSize: 20.sp,
                  fontWeight: FontWeight.w800)),
        ]),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity, height: 52.h,
          child: ElevatedButton(
            onPressed: prov.createLoading ? null : _confirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r)),
              elevation: 0,
            ),
            child: prov.createLoading
                ? SizedBox(width: 22.w, height: 22.h,
                child: const CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(CupertinoIcons.checkmark_circle_fill,
                  color: Colors.white, size: 18.w),
              SizedBox(width: 8.w),
              Text('Confirm Booking', style: TextStyle(
                  color: Colors.white, fontSize: 15.sp,
                  fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Result model passed back from the dialog
// ─────────────────────────────────────────────────────────────────────────────
class _PickupResult {
  final double lat;
  final double lng;
  final String label;
  const _PickupResult({required this.lat, required this.lng, required this.label});
}

// ─────────────────────────────────────────────────────────────────────────────
// _LocationPickerDialog  — 3-tab modal sheet
// ─────────────────────────────────────────────────────────────────────────────
class _LocationPickerDialog extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const _LocationPickerDialog({this.initialLat, this.initialLng});

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog>
    with SingleTickerProviderStateMixin {

  late TabController _tabs;

  // ── Google Maps tab state ─────────────────────────────────────────────────
  GoogleMapController? _mapCtrl;
  LatLng _mapPin = const LatLng(7.8731, 80.7718); // Sri Lanka centre
  String _resolvedAddress = '';
  bool   _geocoding = false;

  // ── DB Locations tab state ────────────────────────────────────────────────
  final _searchCtrl = TextEditingController();
  String           _searchQuery    = '';
  String?          _filterCategory;
  _DbLocation?     _selectedDbLoc;

  // ── Manual tab state ──────────────────────────────────────────────────────
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  static const _categories = ['All', 'City', 'Heritage', 'Beach', 'Nature', 'Airport'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);

    if (widget.initialLat != null && widget.initialLng != null) {
      _mapPin = LatLng(widget.initialLat!, widget.initialLng!);
      _latCtrl.text = widget.initialLat!.toStringAsFixed(6);
      _lngCtrl.text = widget.initialLng!.toStringAsFixed(6);
    }

    _searchCtrl.addListener(() =>
        setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _mapCtrl?.dispose();
    _searchCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  // ── Geocode the current map pin ───────────────────────────────────────────
  Future<void> _geocodePin(LatLng pos) async {
    setState(() { _geocoding = true; _resolvedAddress = ''; });
    try {
      final placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty && mounted) {
        final p = placemarks.first;
        final parts = [p.name, p.locality, p.administrativeArea]
            .where((s) => s != null && s.isNotEmpty)
            .toList();
        setState(() => _resolvedAddress = parts.join(', '));
      }
    } catch (_) {
      if (mounted) setState(() => _resolvedAddress = '');
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  // ── Confirm button per tab ────────────────────────────────────────────────
  void _confirm() {
    switch (_tabs.index) {
      case 0: // Google Maps
        final label = _resolvedAddress.isNotEmpty
            ? _resolvedAddress
            : 'Lat: ${_mapPin.latitude.toStringAsFixed(5)}, '
            'Lng: ${_mapPin.longitude.toStringAsFixed(5)}';
        Navigator.pop(context, _PickupResult(
            lat: _mapPin.latitude, lng: _mapPin.longitude, label: label));
        break;

      case 1: // DB location
        if (_selectedDbLoc == null) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a location from the list')));
          return;
        }
        Navigator.pop(context, _PickupResult(
            lat: _selectedDbLoc!.lat,
            lng: _selectedDbLoc!.lng,
            label: _selectedDbLoc!.name));
        break;

      case 2: // Manual
        final lat = double.tryParse(_latCtrl.text);
        final lng = double.tryParse(_lngCtrl.text);
        if (lat == null || lng == null ||
            lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter valid latitude and longitude')));
          return;
        }
        Navigator.pop(context, _PickupResult(
            lat: lat, lng: lng,
            label: 'Lat: ${lat.toStringAsFixed(5)}, '
                'Lng: ${lng.toStringAsFixed(5)}'));
        break;
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.fromLTRB(12.w, 60.h, 12.w, 20.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Header ─────────────────────────────────────────────────────────
        _dialogHeader(),

        // ── Tabs ───────────────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TabBar(
            controller: _tabs,
            labelColor: _blue,
            unselectedLabelColor: _gray,
            indicatorColor: _blue,
            indicatorWeight: 2.5,
            labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            tabs: const [
              Tab(icon: Icon(Icons.map_outlined, size: 18), text: 'Google Map'),
              Tab(icon: Icon(Icons.list_alt_outlined, size: 18), text: 'Saved'),
              Tab(icon: Icon(Icons.edit_location_alt_outlined, size: 18), text: 'Manual'),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade100, height: 1),

        // ── Tab views ──────────────────────────────────────────────────────
        SizedBox(
          height: 400.h,
          child: TabBarView(
            controller: _tabs,
            children: [
              _googleMapTab(),
              _dbLocationsTab(),
              _manualTab(),
            ],
          ),
        ),

        // ── Action buttons ─────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _gray,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                  padding: EdgeInsets.symmetric(vertical: 13.h)),
              child: Text('Cancel',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            )),
            SizedBox(width: 10.w),
            Expanded(child: ElevatedButton.icon(
              onPressed: _confirm,
              icon: Icon(CupertinoIcons.checkmark_circle_fill,
                  color: Colors.white, size: 16.w),
              label: Text('Confirm Location', style: TextStyle(
                  color: Colors.white, fontSize: 13.sp,
                  fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                  padding: EdgeInsets.symmetric(vertical: 13.h)),
            )),
          ]),
        ),
      ]),
    );
  }

  // ── Dialog header ─────────────────────────────────────────────────────────
  Widget _dialogHeader() => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 16.h, 12.w, 12.h),
    child: Row(children: [
      Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_blue, _blueDark]),
            borderRadius: BorderRadius.circular(14.r)),
        child: Icon(CupertinoIcons.map_pin_ellipse,
            color: Colors.white, size: 20.w),
      ),
      SizedBox(width: 12.w),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Pick Pickup Location', style: TextStyle(
            fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
        Text('Map · Saved places · Manual coordinates',
            style: TextStyle(color: _gray, fontSize: 11.sp)),
      ])),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(CupertinoIcons.xmark_circle_fill,
            color: Colors.grey.shade300, size: 24.w),
      ),
    ]),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 1 — Google Maps
  // ══════════════════════════════════════════════════════════════════════════
  Widget _googleMapTab() => Column(children: [
    // Map
    Expanded(
      child: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _mapPin, zoom: 12),
          onMapCreated: (ctrl) {
            _mapCtrl = ctrl;
            _geocodePin(_mapPin);
          },
          markers: {
            Marker(
              markerId: const MarkerId('pickup'),
              position: _mapPin,
              draggable: true,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              onDragEnd: (pos) {
                setState(() => _mapPin = pos);
                _geocodePin(pos);
              },
            ),
          },
          onTap: (pos) {
            setState(() => _mapPin = pos);
            _geocodePin(pos);
            _mapCtrl?.animateCamera(CameraUpdate.newLatLng(pos));
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // Instruction banner
        Positioned(
          top: 10.h, left: 12.w, right: 12.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8)]),
            child: Row(children: [
              Icon(CupertinoIcons.info_circle_fill, color: _blue, size: 14.w),
              SizedBox(width: 7.w),
              Expanded(child: Text('Tap on the map or drag the blue pin',
                  style: TextStyle(fontSize: 11.sp, color: _dark))),
            ]),
          ),
        ),
      ]),
    ),

    // Resolved address strip
    Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      color: _bgPage,
      child: Row(children: [
        Icon(CupertinoIcons.map_pin, color: _blue, size: 14.w),
        SizedBox(width: 8.w),
        Expanded(
          child: _geocoding
              ? Row(children: [
            SizedBox(width: 12.w, height: 12.h,
                child: const CircularProgressIndicator(
                    strokeWidth: 1.8, color: _blue)),
            SizedBox(width: 8.w),
            Text('Resolving address…',
                style: TextStyle(color: _gray, fontSize: 11.sp)),
          ])
              : Text(
              _resolvedAddress.isNotEmpty
                  ? _resolvedAddress
                  : 'Lat: ${_mapPin.latitude.toStringAsFixed(5)}, '
                  'Lng: ${_mapPin.longitude.toStringAsFixed(5)}',
              style: TextStyle(
                  color: _resolvedAddress.isNotEmpty ? _dark : _gray,
                  fontSize: 12.sp, fontWeight: FontWeight.w600),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ]),
    ),
  ]);

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 2 — DB / Saved Locations
  // ══════════════════════════════════════════════════════════════════════════
  Widget _dbLocationsTab() {
    final filtered = _kDbLocations.where((loc) {
      final matchSearch = _searchQuery.isEmpty ||
          loc.name.toLowerCase().contains(_searchQuery) ||
          loc.region.toLowerCase().contains(_searchQuery);
      final matchCat = _filterCategory == null ||
          _filterCategory == 'All' ||
          loc.category == _filterCategory;
      return matchSearch && matchCat;
    }).toList();

    return Column(children: [
      // Search bar + category chips
      Padding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _searchCtrl,
            style: TextStyle(fontSize: 13.sp, color: _dark),
            decoration: InputDecoration(
              hintText: 'Search locations…',
              hintStyle: TextStyle(color: _gray, fontSize: 12.sp),
              prefixIcon: Icon(CupertinoIcons.search, color: _blue, size: 16.w),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                  icon: Icon(CupertinoIcons.xmark_circle_fill,
                      color: _gray, size: 16.w),
                  onPressed: () => _searchCtrl.clear())
                  : null,
              filled: true,
              fillColor: _bgPage,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: _blue, width: 1.5)),
            ),
          ),
          SizedBox(height: 8.h),
          // Category filter chips
          SizedBox(
            height: 30.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => SizedBox(width: 6.w),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final sel = (_filterCategory ?? 'All') == cat;
                return GestureDetector(
                  onTap: () => setState(() =>
                  _filterCategory = cat == 'All' ? null : cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(
                        color: sel ? _blue : _bgPage,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: sel ? _blue : Colors.grey.shade200)),
                    child: Text(cat, style: TextStyle(
                        fontSize: 11.sp,
                        color: sel ? Colors.white : _gray,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
                  ),
                );
              },
            ),
          ),
        ]),
      ),

      Divider(color: Colors.grey.shade100, height: 1),

      // ── Table header ────────────────────────────────────────────────────
      Container(
        color: _bgPage,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        child: Row(children: [
          SizedBox(width: 26.w), // checkbox col
          Expanded(flex: 5,
              child: Text('Location', style: TextStyle(
                  fontSize: 10.sp, color: _gray, fontWeight: FontWeight.w700))),
          Expanded(flex: 3,
              child: Text('Region', style: TextStyle(
                  fontSize: 10.sp, color: _gray, fontWeight: FontWeight.w700))),
          Expanded(flex: 2,
              child: Text('Type', style: TextStyle(
                  fontSize: 10.sp, color: _gray, fontWeight: FontWeight.w700))),
        ]),
      ),
      Divider(color: Colors.grey.shade200, height: 1),

      // ── Table rows ──────────────────────────────────────────────────────
      Expanded(
        child: filtered.isEmpty
            ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.map, color: _gray.withOpacity(0.4),
                size: 36.w),
            SizedBox(height: 10.h),
            Text('No locations found',
                style: TextStyle(color: _gray, fontSize: 13.sp)),
          ],
        ))
            : ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.grey.shade100, height: 1),
          itemBuilder: (_, i) => _dbRow(filtered[i]),
        ),
      ),
    ]);
  }

  Widget _dbRow(_DbLocation loc) {
    final sel = _selectedDbLoc?.id == loc.id;
    return InkWell(
      onTap: () => setState(() => _selectedDbLoc = sel ? null : loc),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: sel ? _blue.withOpacity(0.06) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
        child: Row(children: [
          // Radio dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 18.w, height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: sel ? _blue : Colors.transparent,
              border: Border.all(
                  color: sel ? _blue : Colors.grey.shade300, width: 1.8),
            ),
            child: sel
                ? Icon(Icons.check, color: Colors.white, size: 11.w)
                : null,
          ),
          SizedBox(width: 8.w),

          // Name
          Expanded(flex: 5, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc.name, style: TextStyle(
                fontSize: 12.sp, color: _dark, fontWeight: FontWeight.w700)),
            Text('${loc.lat.toStringAsFixed(3)}, ${loc.lng.toStringAsFixed(3)}',
                style: TextStyle(fontSize: 9.sp, color: _gray)),
          ])),

          // Region
          Expanded(flex: 3, child: Text(loc.region, style: TextStyle(
              fontSize: 11.sp, color: _gray))),

          // Category chip
          Expanded(flex: 2, child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            decoration: BoxDecoration(
                color: _categoryColor(loc.category).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.r)),
            child: Text(loc.category, textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9.sp,
                    color: _categoryColor(loc.category),
                    fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Beach':    return const Color(0xFF0EA5E9);
      case 'Heritage': return const Color(0xFFF59E0B);
      case 'Nature':   return const Color(0xFF10B981);
      case 'Airport':  return const Color(0xFF8B5CF6);
      default:         return _blue;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TAB 3 — Manual Coordinates
  // ══════════════════════════════════════════════════════════════════════════
  Widget _manualTab() => SingleChildScrollView(
    padding: EdgeInsets.all(16.w),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 8.h),
      // Info box
      Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
            color: _blue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: _blue.withOpacity(0.15))),
        child: Row(children: [
          Icon(CupertinoIcons.info_circle_fill, color: _blue, size: 16.w),
          SizedBox(width: 10.w),
          Expanded(child: Text(
              'Enter the GPS coordinates of your pickup point. '
                  'Latitude: −90 to 90 · Longitude: −180 to 180',
              style: TextStyle(color: _dark, fontSize: 11.sp))),
        ]),
      ),
      SizedBox(height: 20.h),

      // Latitude
      Text('Latitude', style: TextStyle(
          fontSize: 12.sp, fontWeight: FontWeight.w700, color: _dark)),
      SizedBox(height: 6.h),
      _coordField(_latCtrl, 'e.g. 6.9345',
          hint: '−90 to 90'),
      SizedBox(height: 16.h),

      // Longitude
      Text('Longitude', style: TextStyle(
          fontSize: 12.sp, fontWeight: FontWeight.w700, color: _dark)),
      SizedBox(height: 6.h),
      _coordField(_lngCtrl, 'e.g. 79.8428',
          hint: '−180 to 180'),
      SizedBox(height: 24.h),

      // Quick-fill: popular coords
      Text('Quick fill — popular spots',
          style: TextStyle(fontSize: 12.sp, color: _gray,
              fontWeight: FontWeight.w600)),
      SizedBox(height: 10.h),
      Wrap(spacing: 8.w, runSpacing: 8.h,
          children: _kDbLocations.take(6).map((loc) =>
              GestureDetector(
                onTap: () => setState(() {
                  _latCtrl.text = loc.lat.toStringAsFixed(4);
                  _lngCtrl.text = loc.lng.toStringAsFixed(4);
                }),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                      color: _bgPage,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Text(loc.name, style: TextStyle(
                      fontSize: 10.sp, color: _dark,
                      fontWeight: FontWeight.w600)),
                ),
              )).toList()),
    ]),
  );

  Widget _coordField(TextEditingController c, String placeholder,
      {required String hint}) =>
      TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(
            decimal: true, signed: true),
        style: TextStyle(fontSize: 14.sp, color: _dark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
          helperText: hint,
          helperStyle: TextStyle(color: _gray.withOpacity(0.7), fontSize: 10.sp),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Padding(
              padding: EdgeInsets.only(left: 14.w, right: 10.w),
              child: Icon(CupertinoIcons.location, color: _blue, size: 17.w)),
          prefixIconConstraints: const BoxConstraints(),
          contentPadding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(color: _blue, width: 1.8)),
        ),
      );
}