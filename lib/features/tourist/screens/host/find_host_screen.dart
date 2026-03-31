// lib/features/tourist/screens/host/find_host_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import '../../providers/stay_booking_provider.dart';

const _blue  = Color(0xFF2563EB);
const _bg    = Color(0xFFF8FAFC);
const _dark  = Color(0xFF1F2937);
const _gray  = Color(0xFF6B7280);
const _amber = Color(0xFFF59E0B);
const _green = Color(0xFF10B981);

final _slides = [
  {'image': 'assets/images/host_1.png',  'title': 'Village Homestays',  'sub': 'Authentic local living'},
  {'image': 'assets/images/host_2.png',  'title': 'Farm Stays',         'sub': 'Nature & tranquility'},
  {'image': 'assets/images/host_3.jpg',  'title': 'Eco Lodges',         'sub': 'Sustainable travel'},
];

class FindHostScreen extends StatefulWidget {
  const FindHostScreen({super.key});
  @override State<FindHostScreen> createState() => _FindHostScreenState();
}

class _FindHostScreenState extends State<FindHostScreen> {
  final _pageCtrl = PageController();

  // ── Form state ────────────────────────────────────────────────────────────
  String?    _cityId;
  String     _cityName = '';
  DateTime?  _checkin;
  DateTime?  _checkout;
  int        _guests = 2;
  int        _rooms  = 1;
  String?    _type;

  @override
  void initState() {
    super.initState();
    // Load cities on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StayBookingProvider>().loadCities();
    });
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _fmtDisplay(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  Future<void> _pickCheckin() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _checkin ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme: const ColorScheme.light(primary: _blue, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (p != null) {
      setState(() {
        _checkin = p;
        if (_checkout != null && !_checkout!.isAfter(p)) _checkout = null;
      });
    }
  }

  Future<void> _pickCheckout() async {
    if (_checkin == null) { _snack('Please select check-in date first'); return; }
    final p = await showDatePicker(
      context: context,
      initialDate: _checkout ?? _checkin!.add(const Duration(days: 1)),
      firstDate: _checkin!.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
            colorScheme: const ColorScheme.light(primary: _blue, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _checkout = p);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: const Color(0xFF1F2937),
    ));
  }

  Future<void> _search() async {
    // ── Validation: both dates required ──────────────────────────────────────
    if (_cityId == null || _cityId!.isEmpty) {
      _snack('Please select a destination city');
      return;
    }

    // 2. Date check
    if (_checkin == null || _checkout == null) {
      _snack('Please select both Check-in and Check-out dates');
      return;
    }

    final prov = context.read<StayBookingProvider>();
    await prov.searchStays(
      cityId:   _cityId,
      cityName: _cityName,
      checkin:  _fmt(_checkin!),
      checkout: _fmt(_checkout!),
      guests:   _guests,
      rooms:    _rooms,
      type:     _type,
    );
    if (mounted) Navigator.pushNamed(context, '/hostList');
  }

  int get _nights =>
      (_checkin != null && _checkout != null)
          ? _checkout!.difference(_checkin!).inDays
          : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: CustomAppBar(
        title: 'Find a Stay',
        actions: [
          CustomIconButton(
              onPressed: () => Navigator.pushNamed(context, '/notification'),
              icon: Icon(CupertinoIcons.bell, color: _dark, size: 22.w)),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          SizedBox(height: 16.h),
          _buildSlider(),
          SizedBox(height: 24.h),
          _buildSearchCard(),
          SizedBox(height: 32.h),
        ]),
      ),
    );
  }

  // ── Image slider ──────────────────────────────────────────────────────────
  Widget _buildSlider() => Column(children: [
    SizedBox(
      height: 185.h,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: _slides.length,
        itemBuilder: (_, i) {
          final s = _slides[i];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              image: DecorationImage(image: AssetImage(s['image']!), fit: BoxFit.cover),
              boxShadow: [BoxShadow(color: _blue.withOpacity(0.18), blurRadius: 16,
                  offset: const Offset(0, 6), spreadRadius: -4)],
            ),
            child: Stack(children: [
              Container(decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                      begin: Alignment.bottomCenter, end: Alignment.topCenter))),
              Positioned(top: 12.h, right: 12.w, child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.3))),
                child: Row(children: [
                  Icon(Icons.star_rounded, color: _amber, size: 13.w),
                  SizedBox(width: 3.w),
                  Text('Top Rated', style: TextStyle(color: Colors.white,
                      fontSize: 11.sp, fontWeight: FontWeight.w600)),
                ]),
              )),
              Positioned(bottom: 16.h, left: 16.w, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['title']!, style: TextStyle(color: Colors.white,
                    fontSize: 15.sp, fontWeight: FontWeight.w700)),
                Text(s['sub']!, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp)),
              ])),
            ]),
          );
        },
      ),
    ),
    SizedBox(height: 12.h),
    SmoothPageIndicator(
        controller: _pageCtrl, count: _slides.length,
        effect: WormEffect(dotHeight: 7.h, dotWidth: 7.w,
            activeDotColor: _blue, dotColor: Colors.grey.shade300)),
  ]);

  // ── Search card ───────────────────────────────────────────────────────────
  Widget _buildSearchCard() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(CupertinoIcons.house_fill, color: _blue, size: 22.w)),
          SizedBox(width: 12.w),
          Text('Find Your Stay', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
        ]),
        SizedBox(height: 20.h),

        // City
        _lbl('City', req: false),
        _buildCityDropdown(),
        SizedBox(height: 16.h),

        // Dates — REQUIRED
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Check-in', req: true),
            _pickerBox(icon: CupertinoIcons.calendar_today,
                text: _checkin != null ? _fmtDisplay(_checkin!) : 'Select date',
                filled: _checkin != null, onTap: _pickCheckin),
          ])),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Check-out', req: true),
            _pickerBox(icon: CupertinoIcons.calendar,
                text: _checkout != null ? _fmtDisplay(_checkout!) : 'Select date',
                filled: _checkout != null, onTap: _pickCheckout),
          ])),
        ]),

        // Nights summary
        if (_nights > 0) ...[
          SizedBox(height: 8.h),
          Center(child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(color: _green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: _green.withOpacity(0.3))),
            child: Text('$_nights night${_nights > 1 ? 's' : ''}',
                style: TextStyle(color: _green, fontSize: 12.sp, fontWeight: FontWeight.w700)),
          )),
        ],
        SizedBox(height: 16.h),

        // Guests / Rooms
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Guests'),
            _counterBox(value: _guests,
                onDec: _guests > 1 ? () => setState(() => _guests--) : null,
                onInc: () => setState(() => _guests++)),
          ])),
          SizedBox(width: 12.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Rooms'),
            _counterBox(value: _rooms,
                onDec: _rooms > 1 ? () => setState(() => _rooms--) : null,
                onInc: () => setState(() => _rooms++)),
          ])),
        ]),
        SizedBox(height: 16.h),

        // Stay type
        _lbl('Stay Type (optional)'),
        _typeDropdown(),
        SizedBox(height: 24.h),

        // Search button
        Consumer<StayBookingProvider>(
          builder: (_, prov, __) => SizedBox(
            width: double.infinity, height: 52.h,
            child: ElevatedButton(
              onPressed: prov.searchLoading ? null : _search,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  elevation: 0),
              child: prov.searchLoading
                  ? SizedBox(width: 22.w, height: 22.h,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(CupertinoIcons.search, color: Colors.white, size: 18.w),
                SizedBox(width: 8.w),
                Text('Search Stays', style: TextStyle(
                    color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
      ]),
    ),
  );

  // ── City dropdown from API ────────────────────────────────────────────────
  Widget _buildCityDropdown() {
    return Consumer<StayBookingProvider>(
      builder: (_, prov, __) {
        if (prov.citiesLoading) {
          return Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [
              SizedBox(width: 16.w, height: 16.h, child: const CircularProgressIndicator(strokeWidth: 2, color: _blue)),
              SizedBox(width: 12.w),
              Text('Loading cities…', style: TextStyle(color: _gray, fontSize: 13.sp)),
            ]),
          );
        }
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
              color: _cityId != null ? _blue.withOpacity(0.04) : Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: _cityId != null ? _blue.withOpacity(0.3) : Colors.grey.shade200,
                  width: _cityId != null ? 1.5 : 1)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _cityId,
              hint: Row(children: [
                Icon(CupertinoIcons.map_pin, color: _gray, size: 16.w),
                SizedBox(width: 8.w),
                Text('All cities', style: TextStyle(color: _gray, fontSize: 13.sp)),
              ]),
              icon: Icon(CupertinoIcons.chevron_down, color: _gray, size: 16.w),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text('All cities', style: TextStyle(color: _dark, fontSize: 13.sp)),
                ),
                ...prov.cities.map((c) => DropdownMenuItem<String>(
                  value: c['id'] as String,
                  child: Text(c['name'] as String, style: TextStyle(color: _dark, fontSize: 13.sp)),
                )),
              ],
              onChanged: (v) {
                if (v == null) {
                  setState(() {
                    _cityId = null;
                    _cityName = '';
                  });
                } else {
                  final city = prov.cities.firstWhere((c) => c['id'] == v);
                  setState(() {
                    _cityId = v;
                    _cityName = city['name']?.toString() ?? '';
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────
  Widget _lbl(String t, {bool req = false}) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Text.rich(TextSpan(
      text: t,
      style: TextStyle(color: _dark, fontWeight: FontWeight.w700, fontSize: 13.sp),
      children: req ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red.shade400))] : [],
    )),
  );

  Widget _pickerBox({
    required IconData icon, required String text,
    required VoidCallback onTap, bool filled = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
          color: filled ? _blue.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: filled ? _blue.withOpacity(0.3) : Colors.grey.shade200,
              width: filled ? 1.5 : 1)),
      child: Row(children: [
        Icon(icon, color: filled ? _blue : _gray, size: 16.w),
        SizedBox(width: 8.w),
        Expanded(child: Text(text, style: TextStyle(
            color: filled ? _dark : _gray, fontSize: 13.sp,
            fontWeight: filled ? FontWeight.w600 : FontWeight.normal),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    ),
  );

  Widget _counterBox({required int value, required VoidCallback? onDec, required VoidCallback onInc}) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade200)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(onTap: onDec, child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                  color: onDec != null ? _blue.withOpacity(0.1) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Icons.remove, size: 14.w,
                  color: onDec != null ? _blue : Colors.grey.shade400))),
          Text('$value', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _dark)),
          GestureDetector(onTap: onInc, child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(color: _blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Icons.add, size: 14.w, color: _blue))),
        ]),
      );

  Widget _typeDropdown() => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        isExpanded: true, value: _type,
        hint: Text('All types', style: TextStyle(color: _gray, fontSize: 14.sp)),
        icon: Icon(CupertinoIcons.chevron_down, color: _gray, size: 16.w),
        items: [
          DropdownMenuItem(value: null, child: Text('All types', style: TextStyle(color: _dark, fontSize: 13.sp))),
          ...['homestay','farm_stay','villa','guesthouse','eco_lodge','hostel'].map((t) =>
              DropdownMenuItem(value: t, child: Text(_typeLabel(t), style: TextStyle(color: _dark, fontSize: 13.sp)))),
        ],
        onChanged: (v) => setState(() => _type = v),
      ),
    ),
  );

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
}