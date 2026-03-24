// lib/features/tourist/screens/guide/tour_information_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import '../../providers/guide_booking_provider.dart';

const _blue      = Color(0xFF2563EB);
const _blueDark  = Color(0xFF1D4ED8);
const _bgPage    = Color(0xFFF8FAFC);
const _dark      = Color(0xFF1F2937);
const _gray      = Color(0xFF6B7280);
const _green     = Color(0xFF10B981);
const _amber     = Color(0xFFF59E0B);

enum _Who { solo, couple, group }

class TourInformationScreen extends StatefulWidget {
  const TourInformationScreen({super.key});
  @override State<TourInformationScreen> createState() =>
      _TourInformationScreenState();
}

class _TourInformationScreenState extends State<TourInformationScreen> {
  // ── Args from guide detail screen ──────────────────────────────────────────
  Map<String, dynamic> _guide       = {};
  String               _bookingDate = '';
  String               _startTime   = '';
  String               _endTime     = '';
  int                  _slotCount   = 1;

  // ── Form state ─────────────────────────────────────────────────────────────
  _Who _who = _Who.solo;
  final _addressCtrl = TextEditingController();
  final _noteCtrl    = TextEditingController();
  double? _lat;
  double? _lng;

  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsLoaded) return;
    _argsLoaded = true;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _guide       = (args['guide'] as Map?)?.cast<String, dynamic>() ?? {};
      _bookingDate = args['booking_date']?.toString() ?? '';
      _startTime   = args['start_time']?.toString() ?? '';
      _endTime     = args['end_time']?.toString() ?? '';
      _slotCount   = (args['slot_count'] as num?)?.toInt() ?? 1;
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────
  int    get _guests => _who == _Who.solo ? 1 : _who == _Who.couple ? 2 : 5;
  double get _rate   => (_guide['rate_per_hour'] as num?)?.toDouble() ?? 0;
  double get _hours  => _slotCount.toDouble();
  double get _total  => _rate * _hours;

  String _fmt(String t) {
    try {
      final p = t.split(':');
      int h = int.parse(p[0]);
      final m = p[1];
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) { return t; }
  }

  // ── Confirm ────────────────────────────────────────────────────────────────
  Future<void> _confirm() async {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty && _lat == null) {
      _snack('Please enter or pin a pickup location');
      return;
    }

    final prov = context.read<GuideBookingProvider>();
    final ok = await prov.createBooking(
      guideProfileId:  (_guide['guide_profile_id'] ?? '').toString(),
      bookingDate:     _bookingDate,
      startTime:       _startTime,
      endTime:         _endTime,
      guestCount:      _guests,
      pickupLatitude:  _lat,
      pickupLongitude: _lng,
      pickupAddress:   address.isNotEmpty ? address : null,
      specialNote:     _noteCtrl.text.trim().isNotEmpty
          ? _noteCtrl.text.trim() : null,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, '/bookingConfirmation',
          arguments: {'booking': prov.lastCreatedBooking});
    } else {
      _snack(prov.bookingsError.isNotEmpty
          ? prov.bookingsError
          : 'Booking failed. Please try again.');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  Future<void> _openMapPicker() async {
    final res = await showDialog<Map<String, double>>(
      context: context,
      builder: (_) => _MapPickerDialog(initialLat: _lat, initialLng: _lng),
    );
    if (res != null) {
      setState(() {
        _lat = res['lat'];
        _lng = res['lng'];
        _addressCtrl.text =
        'Lat: ${_lat!.toStringAsFixed(5)}, Lng: ${_lng!.toStringAsFixed(5)}';
      });
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
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
          _sectionTitle('Who\'s Traveling?'),
          SizedBox(height: 10.h),
          _travelerRow(),
          SizedBox(height: 20.h),
          _sectionTitle('Pickup Location'),
          SizedBox(height: 10.h),
          _pickupField(),
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

  // ── Guide card ─────────────────────────────────────────────────────────────
  Widget _guideCard() {
    final pic  = (_guide['profile_pic'] ?? '').toString();
    final name = (_guide['full_name'] ?? '').toString();
    final city = ((_guide['city'] as Map?)?['name'] ?? '').toString();
    final avg  = (_guide['avg_rating'] as num?)?.toDouble() ?? 0;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _card(),
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
            Text(avg.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp, color: _dark)),
          ]),
        ])),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_blue, _blueDark]),
              borderRadius: BorderRadius.circular(12.r)),
          child: Column(children: [
            Text('LKR ${_rate.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.white, fontSize: 13.sp,
                    fontWeight: FontWeight.w800)),
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

  // ── Booking info ───────────────────────────────────────────────────────────
  Widget _bookingInfoCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue.withOpacity(0.08), _blue.withOpacity(0.04)]),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _blue.withOpacity(0.15))),
    child: Column(children: [
      _infoRow(CupertinoIcons.calendar,       'Date',     _bookingDate),
      SizedBox(height: 10.h),
      _infoRow(CupertinoIcons.time,           'Time',
          '${_fmt(_startTime)} – ${_fmt(_endTime)}'),
      SizedBox(height: 10.h),
      _infoRow(FontAwesomeIcons.hourglassHalf,'Duration',
          '$_hours hr${_hours > 1 ? "s" : ""}'),
    ]),
  );

  Widget _infoRow(dynamic icon, String label, String value) => Row(children: [
    Icon(icon, color: _blue, size: 15.w),
    SizedBox(width: 10.w),
    Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
    const Spacer(),
    Text(value, style: TextStyle(
        color: _dark, fontSize: 13.sp, fontWeight: FontWeight.w700)),
  ]);

  // ── Traveler toggle ────────────────────────────────────────────────────────
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
          gradient: sel
              ? const LinearGradient(colors: [_blue, _blueDark])
              : null,
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

  // ── Pickup field ───────────────────────────────────────────────────────────
  Widget _pickupField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: TextField(
            controller: _addressCtrl,
            maxLines: 2,
            style: TextStyle(fontSize: 13.sp, color: _dark),
            decoration: InputDecoration(
              hintText: 'Type your pickup address…',
              hintStyle: TextStyle(color: _gray, fontSize: 13.sp),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 12.w, right: 8.w, top: 14.h),
                  child: Icon(CupertinoIcons.map_pin, color: _blue, size: 18.w)),
              prefixIconConstraints: const BoxConstraints(),
              contentPadding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 14.h),
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
          ),
        ),
        SizedBox(width: 10.w),
        // Map button — same glassy style as home header icons
        GestureDetector(
          onTap: _openMapPicker,
          child: Container(
            width: 54.w, height: 54.h,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_blue, _blueDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(
                    color: _blue.withOpacity(0.38),
                    blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)]),
            child: Icon(CupertinoIcons.map, color: Colors.white, size: 22.w),
          ),
        ),
      ]),
      SizedBox(height: 8.h),
      if (_lat != null)
        Row(children: [
          Icon(CupertinoIcons.checkmark_circle_fill, color: _green, size: 14.w),
          SizedBox(width: 5.w),
          Text('Location pinned from map ✓',
              style: TextStyle(color: _green, fontSize: 11.sp,
                  fontWeight: FontWeight.w700)),
        ])
      else
        Row(children: [
          Icon(CupertinoIcons.info_circle, color: _gray, size: 12.w),
          SizedBox(width: 5.w),
          Expanded(child: Text(
              'Tap the map button to pin your exact location',
              style: TextStyle(color: _gray, fontSize: 11.sp))),
        ]),
    ],
  );

  // ── Note field ─────────────────────────────────────────────────────────────
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

  // ── Price summary ──────────────────────────────────────────────────────────
  Widget _summaryCard() => Container(
    padding: EdgeInsets.all(16.w),
    decoration: _card(),
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
                color: color ?? _dark, fontSize: bold ? 16.sp : 13.sp,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ]));

  Widget _divider() => Divider(
      color: Colors.grey.shade100, height: 16.h, thickness: 1);

  Widget _sectionTitle(String t) => Text(t, style: TextStyle(
      fontSize: 15.sp, fontWeight: FontWeight.w800, color: _dark));

  BoxDecoration _card() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.045),
        blurRadius: 16, offset: const Offset(0, 4))],
  );

  // ── Bottom confirm bar ─────────────────────────────────────────────────────
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
              style: TextStyle(
                  color: _blue, fontSize: 20.sp, fontWeight: FontWeight.w800)),
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

// ══════════════════════════════════════════════════════════════════════════════
// Map Picker Dialog
// Replace the body of this dialog with flutter_map / google_maps_flutter
// when you add the map plugin. For now: preset locations + manual coords.
// ══════════════════════════════════════════════════════════════════════════════
class _MapPickerDialog extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  const _MapPickerDialog({this.initialLat, this.initialLng});
  @override State<_MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<_MapPickerDialog> {
  late TextEditingController _latCtrl;
  late TextEditingController _lngCtrl;

  // Sri Lanka popular locations
  static const _presets = [
    {'label': 'Colombo Fort',    'lat': 6.9345,  'lng': 79.8428},
    {'label': 'Kandy Centre',    'lat': 7.2906,  'lng': 80.6337},
    {'label': 'Galle Fort',      'lat': 6.0328,  'lng': 80.2170},
    {'label': 'Sigiriya',        'lat': 7.9570,  'lng': 80.7603},
    {'label': 'Ella Town',       'lat': 6.8667,  'lng': 81.0467},
    {'label': 'Mirissa Beach',   'lat': 5.9485,  'lng': 80.4716},
    {'label': 'Nuwara Eliya',    'lat': 6.9497,  'lng': 80.7891},
    {'label': 'Trincomalee',     'lat': 8.5874,  'lng': 81.2152},
    {'label': 'Negombo',         'lat': 7.2008,  'lng': 79.8380},
    {'label': 'Polonnaruwa',     'lat': 7.9403,  'lng': 81.0188},
    {'label': 'Anuradhapura',    'lat': 8.3114,  'lng': 80.4037},
    {'label': 'Arugam Bay',      'lat': 6.8403,  'lng': 81.8313},
  ];

  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _latCtrl = TextEditingController(
        text: (widget.initialLat ?? 7.8731).toStringAsFixed(4));
    _lngCtrl = TextEditingController(
        text: (widget.initialLng ?? 80.7718).toStringAsFixed(4));
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(children: [
                Container(padding: EdgeInsets.all(9.r),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_blue, _blueDark]),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Icon(CupertinoIcons.map, color: Colors.white, size: 18.w)),
                SizedBox(width: 10.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pin Pickup Location', style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
                  Text('Choose a preset or enter coordinates',
                      style: TextStyle(color: _gray, fontSize: 11.sp)),
                ]),
              ]),
              SizedBox(height: 16.h),

              // Preset grid
              SizedBox(
                height: 168.h,
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.w,
                  mainAxisSpacing: 8.h,
                  childAspectRatio: 2.0,
                  physics: const BouncingScrollPhysics(),
                  children: _presets.map((p) {
                    final sel = _selectedPreset == p['label'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPreset = p['label'] as String;
                          _latCtrl.text =
                              (p['lat'] as double).toStringAsFixed(4);
                          _lngCtrl.text =
                              (p['lng'] as double).toStringAsFixed(4);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        decoration: BoxDecoration(
                            color: sel
                                ? _blue
                                : _blue.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                                color: sel ? _blue : _blue.withOpacity(0.15))),
                        child: Center(child: Text(
                            p['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: sel ? Colors.white : _dark,
                                fontSize: 10.sp, fontWeight: FontWeight.w700,
                                height: 1.2))),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 14.h),

              // Manual coords
              Text('Or enter coordinates manually:',
                  style: TextStyle(color: _gray, fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Row(children: [
                Expanded(child: _coord(_latCtrl, 'Latitude')),
                SizedBox(width: 10.w),
                Expanded(child: _coord(_lngCtrl, 'Longitude')),
              ]),
              SizedBox(height: 18.h),

              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: _gray,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h)),
                  child: Text('Cancel', style: TextStyle(
                      fontSize: 13.sp, fontWeight: FontWeight.w600)),
                )),
                SizedBox(width: 10.w),
                Expanded(child: ElevatedButton(
                  onPressed: () {
                    final lat = double.tryParse(_latCtrl.text);
                    final lng = double.tryParse(_lngCtrl.text);
                    if (lat == null || lng == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Enter valid coordinates')));
                      return;
                    }
                    Navigator.pop(context, {'lat': lat, 'lng': lng});
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r)),
                      padding: EdgeInsets.symmetric(vertical: 12.h)),
                  child: Text('Pin Location', style: TextStyle(
                      color: Colors.white, fontSize: 13.sp,
                      fontWeight: FontWeight.w700)),
                )),
              ]),
            ]),
      ),
    );
  }

  Widget _coord(TextEditingController c, String hint) => TextField(
    controller: c,
    keyboardType: const TextInputType.numberWithOptions(
        decimal: true, signed: true),
    style: TextStyle(fontSize: 12.sp, color: _dark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _gray, fontSize: 11.sp),
      filled: true, fillColor: _bgPage,
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: const BorderSide(color: _blue, width: 1.5)),
    ),
  );
}