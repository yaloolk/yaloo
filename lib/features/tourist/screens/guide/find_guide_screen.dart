// lib/features/tourist/screens/guide/find_guide_screen.dart

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/custom_icon_button.dart';
import '../../providers/guide_booking_provider.dart';

// ── Design tokens — exact match with home screen ───────────────────────────────
const _blue      = Color(0xFF2563EB);
const _blueDark  = Color(0xFF1D4ED8);
const _bgPage    = Color(0xFFF8FAFC);
const _textDark  = Color(0xFF1F2937);
const _textGray  = Color(0xFF6B7280);
const _amber     = Color(0xFFF59E0B);

final List<Map<String, String>> _slides = [
  {'image': 'assets/images/sigiriya.jpg', 'title': 'Sigiriya',  'sub': 'Ancient Rock Fortress'},
  {'image': 'assets/images/galle.jpg',    'title': 'Galle',     'sub': 'Colonial Old Town'},
  {'image': 'assets/images/ella.jpg',     'title': 'Ella',      'sub': 'Scenic Highlands'},
];

class FindGuideScreen extends StatefulWidget {
  const FindGuideScreen({super.key});
  @override State<FindGuideScreen> createState() => _FindGuideScreenState();
}

class _FindGuideScreenState extends State<FindGuideScreen> {
  final _pageCtrl = PageController();

  String?    _cityId;
  String     _cityName = '';
  DateTime?  _date;
  TimeOfDay? _time;

  List<Map<String, dynamic>> _cities     = [];
  bool                       _loadingCities = true;

  @override void initState() { super.initState(); _loadCities(); }
  @override void dispose()   { _pageCtrl.dispose(); super.dispose(); }

  Future<void> _loadCities() async {
    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      final dio = Dio(BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api',
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ));
      final resp = await dio.get('/accounts/cities/');
      setState(() {
        _cities = (resp.data as List)
            .map((c) => {'id': c['id'].toString(), 'name': c['name'].toString()})
            .toList();
        _loadingCities = false;
      });
    } catch (_) { setState(() => _loadingCities = false); }
  }

  Future<void> _search() async {
    if (_cityId == null) { _snack('Please select a city'); return; }
    if (_date   == null) { _snack('Please select a date'); return; }
    if (_time   == null) { _snack('Please select a start time'); return; }

    await context.read<GuideBookingProvider>().searchGuides(
      cityId:    _cityId!,
      cityName:  _cityName,
      date:      '${_date!.year}-${_pad(_date!.month)}-${_pad(_date!.day)}',
      startTime: '${_pad(_time!.hour)}:${_pad(_time!.minute)}',
    );
    if (mounted) Navigator.pushNamed(context, '/guideList');
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime.now().add(const Duration(days: 365)),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(
            primary: _blue, onPrimary: Colors.white, onSurface: _textDark)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _date = p);
  }

  Future<void> _pickTime() async {
    final p = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(colorScheme: const ColorScheme.light(
            primary: _blue, onPrimary: Colors.white)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _time = p);
  }


  Future<void> _pickMinutePicker() async {
    final FixedExtentScrollController hourCtrl =
    FixedExtentScrollController(initialItem: _time?.hour ?? 0);

    // Only 2 options: 00 and 30
    final minutes = [0, 30];
    final int initMinIdx = (_time != null && _time!.minute >= 15) ? 1 : 0;
    final FixedExtentScrollController minCtrl =
    FixedExtentScrollController(initialItem: initMinIdx);

    int selectedHour = _time?.hour ?? 0;
    int selectedMinIdx = initMinIdx;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.only(bottom: 24.h),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel',
                          style: TextStyle(color: _textGray, fontSize: 15.sp)),
                    ),
                    Text('Start Time',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: _textDark)),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _time = TimeOfDay(
                              hour: selectedHour,
                              minute: minutes[selectedMinIdx]);
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text('Done',
                          style: TextStyle(
                              color: _blue,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              // Pickers row
              SizedBox(
                height: 200.h,
                child: Row(
                  children: [
                    // ── Hour drum ──────────────────────────────
                    Expanded(
                      child: Stack(alignment: Alignment.center, children: [
                        // Selection highlight
                        Container(
                          height: 44.h,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: _blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: _blue.withOpacity(0.2), width: 1.5),
                          ),
                        ),
                        ListWheelScrollView.useDelegate(
                          controller: hourCtrl,
                          itemExtent: 44.h,
                          perspective: 0.003,
                          diameterRatio: 1.4,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setSheet(() => selectedHour = i),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 24,
                            builder: (_, i) => Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: selectedHour == i ? 22.sp : 17.sp,
                                  fontWeight: selectedHour == i
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: selectedHour == i ? _blue : _textGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    // Colon separator
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Text(':',
                          style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w700,
                              color: _textDark)),
                    ),
                    // ── Minute drum (00 / 30 only) ─────────────
                    Expanded(
                      child: Stack(alignment: Alignment.center, children: [
                        Container(
                          height: 44.h,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: _blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: _blue.withOpacity(0.2), width: 1.5),
                          ),
                        ),
                        ListWheelScrollView.useDelegate(
                          controller: minCtrl,
                          itemExtent: 44.h,
                          perspective: 0.003,
                          diameterRatio: 1.4,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setSheet(() => selectedMinIdx = i),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: minutes.length,
                            builder: (_, i) => Center(
                              child: Text(
                                minutes[i].toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: selectedMinIdx == i ? 22.sp : 17.sp,
                                  fontWeight: selectedMinIdx == i
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color:
                                  selectedMinIdx == i ? _blue : _textGray,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ]),
          );
        });
      },
    );

    hourCtrl.dispose();
    minCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      appBar: CustomAppBar(
        title: 'Find a Guide',
        actions: [
          CustomIconButton(
              onPressed: () {},
              icon: Icon(CupertinoIcons.search, color: _textDark, size: 22.w)),
          SizedBox(width: 6.w),
          _NotifBell(),
          SizedBox(width: 12.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 16.h),
            _buildSlider(),
            SizedBox(height: 24.h),
            _buildSearchCard(),
            SizedBox(height: 32.h),
          ]),
        ),
      ),
    );
  }

  // ── Slider (same style as home featured slider) ───────────────────────────
  Widget _buildSlider() {
    return Column(children: [
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
                image: DecorationImage(
                    image: AssetImage(s['image']!), fit: BoxFit.cover),
                boxShadow: [BoxShadow(
                    color: _blue.withOpacity(0.18), blurRadius: 16,
                    offset: const Offset(0, 6), spreadRadius: -4)],
              ),
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                        begin: Alignment.bottomCenter, end: Alignment.topCenter),
                  ),
                ),
                // Top-right glassy badge
                Positioned(top: 12.h, right: 12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white.withOpacity(0.3))),
                    child: Row(children: [
                      Icon(Icons.star_rounded, color: _amber, size: 13.w),
                      SizedBox(width: 3.w),
                      Text('Top Pick', style: TextStyle(
                          color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                // Bottom name
                Positioned(bottom: 16.h, left: 16.w,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(CupertinoIcons.map_pin, color: Colors.white, size: 13.w),
                      SizedBox(width: 4.w),
                      Text(s['title']!, style: TextStyle(
                          color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ]),
                    Text(s['sub']!, style: TextStyle(
                        color: Colors.white.withOpacity(0.75), fontSize: 12.sp)),
                  ]),
                ),
              ]),
            );
          },
        ),
      ),
      SizedBox(height: 12.h),
      SmoothPageIndicator(
        controller: _pageCtrl,
        count: _slides.length,
        effect: WormEffect(
            dotHeight: 7.h, dotWidth: 7.w,
            activeDotColor: _blue, dotColor: Colors.grey.shade300),
      ),
    ]);
  }

  // ── Search card (same card style as home _buildFindSection) ──────────────
  Widget _buildSearchCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title row with icon — matches home _buildFindSection header
          Row(children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                  color: _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Icon(CupertinoIcons.compass, color: _blue, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Text('Book a Guide', style: TextStyle(
                fontSize: 16.sp, fontWeight: FontWeight.w800, color: _textDark)),
          ]),
          SizedBox(height: 20.h),

          // City
          _lbl('City', req: true),
          _loadingCities
              ? Padding(padding: EdgeInsets.symmetric(vertical: 14.h),
              child: const Center(child: CircularProgressIndicator()))
              : _cityDrop(),
          SizedBox(height: 16.h),

          // Date
          _lbl('Date', req: true),
          _pickerBox(
            icon: CupertinoIcons.calendar_today,
            text: _date != null
                ? '${_pad(_date!.month)} / ${_pad(_date!.day)} / ${_date!.year}'
                : 'MM / DD / YYYY',
            filled: _date != null,
            onTap: _pickDate,
          ),
          SizedBox(height: 16.h),

          // Time  — NO end time
          _lbl('Preferred Start Time', req: true),
          _pickerBox(
            icon: CupertinoIcons.time,
            text: _time != null ? _time!.format(context) : 'Select start time',
            filled: _time != null,
            onTap: _pickMinutePicker,
          ),
          SizedBox(height: 28.h),

          // Search button
          Consumer<GuideBookingProvider>(
            builder: (_, prov, __) => SizedBox(
              width: double.infinity, height: 52.h,
              child: ElevatedButton(
                onPressed: prov.searchLoading ? null : _search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r)),
                  elevation: 0,
                  shadowColor: _blue.withOpacity(0.38),
                ),
                child: prov.searchLoading
                    ? SizedBox(width: 22.w, height: 22.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(CupertinoIcons.search, color: Colors.white, size: 18.w),
                  SizedBox(width: 8.w),
                  Text('Search Guides', style: TextStyle(
                      color: Colors.white, fontSize: 15.sp,
                      fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _lbl(String t, {bool req = false}) => Padding(
    padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
    child: Text.rich(TextSpan(
      text: t,
      style: TextStyle(color: _textDark, fontWeight: FontWeight.w700,
          fontSize: 13.sp),
      children: req
          ? [TextSpan(text: ' *',
          style: TextStyle(color: AppColors.primaryRed))]
          : [],
    )),
  );

  Widget _pickerBox({
    required IconData icon, required String text,
    required VoidCallback onTap, bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: filled ? _blue.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
              color: filled ? _blue.withOpacity(0.3) : Colors.grey.shade200,
              width: filled ? 1.5 : 1),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Icon(icon, color: filled ? _blue : _textGray, size: 18.w),
          SizedBox(width: 12.w),
          Text(text, style: TextStyle(
              color: filled ? _textDark : _textGray,
              fontSize: 14.sp,
              fontWeight: filled ? FontWeight.w600 : FontWeight.normal)),
          const Spacer(),
          Icon(CupertinoIcons.chevron_right,
              color: filled ? _blue : _textGray, size: 14.w),
        ]),
      ),
    );
  }

  Widget _cityDrop() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: _cityId != null ? _blue.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: _cityId != null ? _blue.withOpacity(0.3) : Colors.grey.shade200,
            width: _cityId != null ? 1.5 : 1),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(children: [
            Icon(CupertinoIcons.map_pin, color: _textGray, size: 18.w),
            SizedBox(width: 12.w),
            Text('Select city', style: TextStyle(color: _textGray, fontSize: 14.sp)),
          ]),
          value: _cityId,
          icon: Icon(CupertinoIcons.chevron_down, color: _textGray, size: 16.w),
          items: _cities.map((c) => DropdownMenuItem<String>(
            value: c['id'] as String,
            child: Text(c['name'] as String, style: TextStyle(
                color: _textDark, fontSize: 14.sp, fontWeight: FontWeight.w500)),
          )).toList(),
          onChanged: (v) {
            if (v == null) return;
            final c = _cities.firstWhere((x) => x['id'] == v);
            setState(() { _cityId = v; _cityName = c['name'] as String; });
          },
        ),
      ),
    );
  }
}

class _NotifBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(alignment: Alignment.center, children: [
    CustomIconButton(
        onPressed: () => Navigator.pushNamed(context, '/notification'),
        icon: Icon(CupertinoIcons.bell, color: const Color(0xFF1F2937), size: 22.w)),
    Positioned(top: 10.h, right: 10.w,
        child: Container(width: 8.w, height: 8.h,
            decoration: const BoxDecoration(
                color: Color(0xFFF59E0B), shape: BoxShape.circle))),
  ]);
}