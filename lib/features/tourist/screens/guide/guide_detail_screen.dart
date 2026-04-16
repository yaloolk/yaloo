// lib/features/tourist/screens/guide/guide_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/guide_booking_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue     = Color(0xFF2563EB);
const _blueDark = Color(0xFF1D4ED8);
const _bgPage   = Color(0xFFF8FAFC);
const _dark     = Color(0xFF1F2937);
const _gray     = Color(0xFF6B7280);
const _green    = Color(0xFF10B981);
const _amber    = Color(0xFFF59E0B);
const _purple   = Color(0xFF8B5CF6);
const _orange   = Color(0xFFF97316);
const _teal     = Color(0xFF0D9488);
const _rose     = Color(0xFFE11D48);

// ── Slot model ────────────────────────────────────────────────────────────────
class _Slot {
  final String id;
  final String start;
  final String end;

  const _Slot({required this.id, required this.start, required this.end});

  factory _Slot.fromJson(Map<String, dynamic> m) => _Slot(
    id:    m['id']?.toString()         ?? '',
    start: m['start_time']?.toString() ?? '',
    end:   m['end_time']?.toString()   ?? '',
  );

  String get startClean {
    final p = start.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : start;
  }

  String get endClean {
    final p = end.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : end;
  }

  String _fmt(String raw) {
    try {
      final p  = raw.split(':');
      int h    = int.parse(p[0]);
      final m  = p[1].padLeft(2, '0');
      final ap = h >= 12 ? 'PM' : 'AM';
      if (h == 0) h = 12; else if (h > 12) h -= 12;
      return '$h:$m $ap';
    } catch (_) {
      return raw;
    }
  }

  String get displayStart => _fmt(start);
  String get displayEnd   => _fmt(end);
}

// ── Local Activity model ──────────────────────────────────────────────────────
class _LocalActivity {
  final String id;
  final String activityId;
  final String activityName;
  final String activityDescription;
  final String activityCategory;
  final double setPrice;
  final String specialNote;

  const _LocalActivity({
    required this.id,
    required this.activityId,
    required this.activityName,
    required this.activityDescription,
    required this.activityCategory,
    required this.setPrice,
    required this.specialNote,
  });

  factory _LocalActivity.fromJson(Map<String, dynamic> m) {
    // Checks for both flat structure and nested 'activity' object
    final act = (m['activity'] as Map<String, dynamic>?) ?? {};
    return _LocalActivity(
      id:                  m['local_activity_id']?.toString() ?? m['id']?.toString() ?? '',
      activityId:          m['activity_id']?.toString() ?? act['id']?.toString() ?? '',
      activityName:        m['name']?.toString() ?? act['name']?.toString() ?? 'Unnamed Activity',
      activityDescription: m['description']?.toString() ?? act['description']?.toString() ?? '',
      activityCategory:    m['category']?.toString() ?? act['category']?.toString() ?? '',
      setPrice:            (m['set_price'] as num?)?.toDouble() ?? 0.0,
      specialNote:         m['special_note']?.toString() ?? '',
    );
  }
}

// ── Guide Specialization model ────────────────────────────────────────────────
class _GuideSpecialization {
  final String id;
  final String name;
  final String category;

  const _GuideSpecialization({
    required this.id,
    required this.name,
    required this.category,
  });

  factory _GuideSpecialization.fromJson(Map<String, dynamic> m) {
    // Checks for both flat structure and nested 'specialization' object
    final spec = (m['specialization'] as Map<String, dynamic>?) ?? {};
    return _GuideSpecialization(
      id:       m['id']?.toString() ?? spec['id']?.toString() ?? '',
      name:     m['label']?.toString() ?? m['name']?.toString() ?? spec['label']?.toString() ?? spec['name']?.toString() ?? '',
      category: m['category']?.toString() ?? spec['category']?.toString() ?? '',
    );
  }
}

// ── Tourist Interest model ────────────────────────────────────────────────────
class _Interest {
  final String id;
  final String name;
  final String category;

  const _Interest({
    required this.id,
    required this.name,
    required this.category,
  });

  factory _Interest.fromJson(Map<String, dynamic> m) {
    final intObj = (m['interest'] as Map<String, dynamic>?) ?? {};
    return _Interest(
      id:       m['id']?.toString() ?? intObj['id']?.toString() ?? '',
      name:     m['name']?.toString() ?? intObj['name']?.toString() ?? '',
      category: m['category']?.toString() ?? intObj['category']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class GuideDetailScreen extends StatefulWidget {
  const GuideDetailScreen({super.key});
  @override
  State<GuideDetailScreen> createState() => _State();
}

class _State extends State<GuideDetailScreen> {
  String? _searchDate;
  bool    _argsApplied = false;

  // ── Slot state ────────────────────────────────────────────────────────────
  List<_Slot> _slots          = [];
  List<int>   _selected       = [];
  int         _slotsHash      = 0;

  // ── Local Activities state ────────────────────────────────────────────────
  List<_LocalActivity> _localActivities = [];
  int                  _activitiesHash  = 0;

  // ── Guide Specializations state ───────────────────────────────────────────
  List<_GuideSpecialization> _specializations = [];
  int                        _specializationsHash = 0;

  // ── Tourist Interests state ───────────────────────────────────────────────
  List<_Interest> _interests      = [];
  int             _interestsHash  = 0;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsApplied) return;
    _argsApplied = true;

    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    _searchDate = args['search_date']?.toString();

    final id = args['guide_profile_id']?.toString() ?? '';
    if (id.isNotEmpty) {
      context.read<GuideBookingProvider>().loadGuideDetail(id);
    }
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  void _syncSlots(Map<String, dynamic> g) {
    if (_searchDate == null) return;
    final avail = (g['availability'] as Map<String, dynamic>?) ?? {};
    final raw   = (avail[_searchDate] as List?) ?? [];
    final hash  = raw.toString().hashCode;
    if (hash == _slotsHash) return;
    setState(() {
      _slots     = raw.map((s) => _Slot.fromJson(s as Map<String, dynamic>)).toList();
      _selected  = [];
      _slotsHash = hash;
    });
  }

  void _syncLocalActivities(Map<String, dynamic> g) {
    // Looks for every possible backend key formulation
    final raw  = (g['local_activities'] as List?) ??
        (g['local_activity'] as List?) ??
        (g['guide_local_activities'] as List?) ?? [];

    final hash = raw.toString().hashCode;
    if (hash == _activitiesHash) return;

    setState(() {
      _localActivities = raw
          .map((a) => _LocalActivity.fromJson(a as Map<String, dynamic>))
          .toList();
      _activitiesHash = hash;
    });
  }

  void _syncSpecializations(Map<String, dynamic> g) {
    // Looks for every possible backend key formulation
    final raw  = (g['specializations'] as List?) ??
        (g['guide_specializations'] as List?) ??
        (g['guide_specialization'] as List?) ?? [];

    final hash = raw.toString().hashCode;
    if (hash == _specializationsHash) return;

    setState(() {
      _specializations = raw
          .map((s) => _GuideSpecialization.fromJson(s as Map<String, dynamic>))
          .where((s) => s.name.isNotEmpty)
          .toList();
      _specializationsHash = hash;
    });
  }

  void _syncInterests(Map<String, dynamic> g) {
    final raw = (g['specialties'] as List?) ?? (g['interests'] as List?) ?? [];
    final hash = raw.toString().hashCode;
    if (hash == _interestsHash) return;

    setState(() {
      _interests = raw
          .map((i) => _Interest.fromJson(i as Map<String, dynamic>))
          .where((i) => i.name.isNotEmpty)
          .toList();
      _interestsHash = hash;
    });
  }

  // ── Slot selection logic ──────────────────────────────────────────────────
  void _tapSlot(int idx) {
    setState(() {
      if (_selected.contains(idx)) {
        _selected.removeWhere((i) => i >= idx);
      } else {
        if (_selected.isEmpty) { _selected = [idx]; return; }
        final first = _selected.first;
        final last  = _selected.last;
        if (idx == last + 1) {
          _slotsAdjacent(last, idx) ? _selected.add(idx) : _showGapWarning();
        } else if (idx == first - 1) {
          _slotsAdjacent(idx, first) ? _selected.insert(0, idx) : _showGapWarning();
        } else {
          _selected = [idx];
        }
      }
    });
  }

  bool _slotsAdjacent(int a, int b) =>
      _slots[a].endClean == _slots[b].startClean;

  void _showGapWarning() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('There is a gap between those slots — '
          'please select adjacent slots only'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  bool    get _hasSelection    => _selected.isNotEmpty;
  String? get _selStart        => _selected.isNotEmpty ? _slots[_selected.first].startClean  : null;
  String? get _selEnd          => _selected.isNotEmpty ? _slots[_selected.last].endClean      : null;
  String? get _selStartDisplay => _selected.isNotEmpty ? _slots[_selected.first].displayStart : null;
  String? get _selEndDisplay   => _selected.isNotEmpty ? _slots[_selected.last].displayEnd    : null;

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<GuideBookingProvider>(
      builder: (_, prov, __) {
        if (prov.detailLoading) {
          return const Scaffold(
              backgroundColor: _bgPage,
              body: Center(child: CircularProgressIndicator()));
        }
        if (prov.detailError.isNotEmpty) {
          return _errScaffold(prov.detailError);
        }
        final g = prov.guideDetail;
        if (g == null) {
          return const Scaffold(
              backgroundColor: _bgPage,
              body: Center(child: CircularProgressIndicator()));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncSlots(g);
          _syncLocalActivities(g);
          _syncSpecializations(g);
          _syncInterests(g);
        });

        return Scaffold(
          backgroundColor: _bgPage,
          body: Stack(children: [
            CustomScrollView(slivers: [
              _heroBanner(g),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 130.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _headerCard(g),
                      SizedBox(height: 14.h),
                      _verificationCard(g),
                      SizedBox(height: 14.h),
                      _statsRow(g),
                      SizedBox(height: 18.h),

                      // About
                      if ((g['profile_bio'] ?? '').toString().isNotEmpty) ...[
                        _section('About', _bioWidget(g)),
                        SizedBox(height: 18.h),
                      ],

                      // Languages
                      if ((g['languages'] as List? ?? []).isNotEmpty) ...[
                        _section('Languages', _languagesWidget(g)),
                        SizedBox(height: 18.h),
                      ],

                      // ── Available Time Slots ─────────────────────────────
                      _section(
                        'Available Time Slots',
                        _slotPicker(),
                        hint: _searchDate != null
                            ? 'All free slots for $_searchDate'
                            : null,
                      ),
                      SizedBox(height: 18.h),

                      // ── Guide Specializations ─────────────────────────────
                      if (_specializations.isNotEmpty) ...[
                        _section(
                          'Guide Specialization',
                          _specializationsWidget(),
                          hint: '${_specializations.length} areas',
                        ),
                        SizedBox(height: 18.h),
                      ],

                      // ── Guide Interests (Specialties) ─────────────────────
                      if (_interests.isNotEmpty) ...[
                        _section(
                          'Guide Interests',
                          _interestsWidget(),
                          hint: '${_interests.length} topics',
                        ),
                        SizedBox(height: 18.h),
                      ],

                      // ── Activities Offered ────────────────────────────────
                      if (_localActivities.isNotEmpty) ...[
                        _section(
                          'Tours & Activities',
                          _localActivitiesWidget(),
                          hint: '${_localActivities.length} available',
                        ),
                        SizedBox(height: 18.h),
                      ],

                      // Reviews
                      if ((g['reviews'] as List? ?? []).isNotEmpty) ...[
                        _section(
                            'Reviews (${g['review_count'] ?? 0})',
                            _reviewsWidget(g)),
                        SizedBox(height: 18.h),
                      ],

                      // Gallery
                      if ((g['gallery'] as List? ?? []).isNotEmpty)
                        _section('Gallery', _galleryWidget(g)),
                    ],
                  ),
                ),
              ),
            ]),
            Positioned(
                bottom: 0, left: 0, right: 0,
                child: _bookBar(context, g)),
          ]),
        );
      },
    );
  }

  // ── Hero banner ───────────────────────────────────────────────────────────
  Widget _heroBanner(Map<String, dynamic> g) {
    final pic = (g['profile_pic'] ?? '').toString();
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      backgroundColor: _blue,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(fit: StackFit.expand, children: [
          pic.isNotEmpty
              ? CachedNetworkImage(
              imageUrl: pic,
              fit: BoxFit.cover,
              placeholder:  (_, __) => _heroBg(),
              errorWidget: (_, __, ___) => _heroBg())
              : _heroBg(),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
          ),
        ]),
      ),
    );
  }

  Widget _heroBg() => Container(
    decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [_blue, _blueDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight)),
    child: Icon(CupertinoIcons.person_fill,
        color: Colors.white.withOpacity(0.3), size: 80.w),
  );

  // ── Header card ───────────────────────────────────────────────────────────
  Widget _headerCard(Map<String, dynamic> g) => Container(
    margin: EdgeInsets.only(top: 16.h),
    padding: EdgeInsets.all(16.w),
    decoration: _cardDeco(),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text((g['full_name'] ?? '').toString(),
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: _dark)),
            SizedBox(height: 4.h),
            Row(children: [
              Icon(CupertinoIcons.map_pin, color: _gray, size: 12.w),
              SizedBox(width: 4.w),
              Text(((g['city'] as Map?)?['name'] ?? '').toString(),
                  style: TextStyle(color: _gray, fontSize: 12.sp)),
              SizedBox(width: 12.w),
              Icon(CupertinoIcons.calendar, color: _gray, size: 12.w),
              SizedBox(width: 4.w),
              Text('Since ${g['member_since'] ?? ''}',
                  style: TextStyle(color: _gray, fontSize: 12.sp)),
            ]),
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_blue, _blueDark]),
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(children: [
          Text(
              'LKR ${(g['rate_per_hour'] ?? 0).toStringAsFixed(0)}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800)),
          Text('per hour',
              style: TextStyle(color: Colors.white70, fontSize: 9.sp)),
        ]),
      ),
    ]),
  );

  // ── Verification card ─────────────────────────────────────────────────────
  Widget _verificationCard(Map<String, dynamic> g) {
    final isSltda = g['is_SLTDA_verified'] == true;
    final isAvail = g['is_available']      == true;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                  color: _blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r)),
              child: Icon(CupertinoIcons.checkmark_shield_fill,
                  color: _blue, size: 16.w)),
          SizedBox(width: 10.w),
          Text('Verification Status',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: _dark)),
        ]),
        SizedBox(height: 14.h),
        Row(children: [
          Expanded(child: _verBadge('Platform\nVerified',
              CupertinoIcons.checkmark_shield_fill, _blue)),
          SizedBox(width: 10.w),
          Expanded(child: _verBadge(
              isSltda ? 'SLTDA\nVerified' : 'SLTDA\nNot Verified',
              isSltda
                  ? CupertinoIcons.star_circle_fill
                  : CupertinoIcons.xmark_circle_fill,
              isSltda ? _green : _gray)),
          SizedBox(width: 10.w),
          Expanded(child: _verBadge(
              isAvail ? 'Currently\nAvailable' : 'Not\nAvailable',
              isAvail
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.xmark_circle,
              isAvail ? _green : Colors.orange.shade400)),
        ]),
      ]),
    );
  }

  Widget _verBadge(String label, IconData icon, Color color) => Container(
    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
    decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.25))),
    child: Column(children: [
      Icon(icon, color: color, size: 22.w),
      SizedBox(height: 6.h),
      Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              height: 1.3)),
    ]),
  );

  // ── Stats row ─────────────────────────────────────────────────────────────
  Widget _statsRow(Map<String, dynamic> g) => Row(children: [
    Expanded(child: _stat(
        '${(g['avg_rating'] ?? 0).toStringAsFixed(1)}',
        'Rating', CupertinoIcons.star_fill, _amber)),
    SizedBox(width: 8.w),
    Expanded(child: _stat(
        '${g['total_completed_bookings'] ?? 0}',
        'Trips', CupertinoIcons.checkmark_circle_fill, _green)),
    SizedBox(width: 8.w),
    Expanded(child: _stat(
        '${g['experience_years'] ?? 0}yr',
        'Exp', CupertinoIcons.clock_fill, _orange)),
    SizedBox(width: 8.w),
    Expanded(child: _stat(
        '${(g['booking_response_rate'] ?? 0).toStringAsFixed(0)}%',
        'Response', CupertinoIcons.arrow_2_circlepath, _purple)),
  ]);

  Widget _stat(String val, String lbl, IconData icon, Color c) => Container(
    padding: EdgeInsets.symmetric(vertical: 12.h),
    decoration: _cardDeco(),
    child: Column(children: [
      Icon(icon, color: c, size: 18.w),
      SizedBox(height: 4.h),
      Text(val,
          style: TextStyle(
              fontSize: 13.sp, fontWeight: FontWeight.w800, color: _dark)),
      SizedBox(height: 2.h),
      Text(lbl, style: TextStyle(fontSize: 9.sp, color: _gray)),
    ]),
  );

  // ── Bio / Languages ───────────────────────────────────────────────────────
  Widget _bioWidget(Map<String, dynamic> g) => Text(
      (g['profile_bio'] ?? '').toString(),
      style: TextStyle(color: _dark, fontSize: 13.sp, height: 1.6));

  Widget _languagesWidget(Map<String, dynamic> g) => Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: (g['languages'] as List? ?? []).map((l) {
        final m      = l as Map<String, dynamic>;
        final native = m['is_native'] == true;
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
                color: native ? _blue.withOpacity(0.08) : _bgPage,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                    color: native
                        ? _blue.withOpacity(0.4)
                        : Colors.grey.shade200)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (native) ...[
                Icon(Icons.star_rounded, color: _blue, size: 11.w),
                SizedBox(width: 4.w),
              ],
              Text('${m['name']} · ${m['proficiency']}',
                  style: TextStyle(
                      color: native ? _blue : _dark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
            ]));
      }).toList());

  // ── SLOT PICKER ───────────────────────────────────────────────────────────
  Widget _slotPicker() {
    if (_slots.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.orange.withOpacity(0.3))),
        child: Row(children: [
          Icon(CupertinoIcons.calendar_badge_minus,
              color: Colors.orange.shade400, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
                _searchDate != null
                    ? 'No free time slots for $_searchDate.\n'
                    'Try a different date from the search screen.'
                    : 'No slots loaded yet.',
                style: TextStyle(color: _dark, fontSize: 13.sp, height: 1.5)),
          ),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (_hasSelection)
        Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: _green.withOpacity(0.35))),
          child: Row(children: [
            Icon(CupertinoIcons.time, color: _green, size: 14.w),
            SizedBox(width: 8.w),
            Text(
                '$_selStartDisplay – $_selEndDisplay  '
                    '(${_selected.length} hr${_selected.length > 1 ? "s" : ""})',
                style: TextStyle(
                    color: _green,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700)),
          ]),
        ),
      Wrap(
        spacing: 8.w,
        runSpacing: 10.h,
        children: List.generate(_slots.length, (i) {
          final sel = _selected.contains(i);
          final canExtend = _selected.isEmpty ||
              (i == _selected.last + 1  && _slotsAdjacent(_selected.last, i)) ||
              (i == _selected.first - 1 && _slotsAdjacent(i, _selected.first));

          return GestureDetector(
            onTap: () => _tapSlot(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                gradient: sel
                    ? const LinearGradient(colors: [_blue, _blueDark])
                    : null,
                color: sel
                    ? null
                    : canExtend && _hasSelection
                    ? _blue.withOpacity(0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: sel
                      ? _blue
                      : canExtend && _hasSelection
                      ? _blue.withOpacity(0.4)
                      : Colors.grey.shade200,
                  width: (sel || (canExtend && _hasSelection)) ? 1.5 : 1,
                ),
                boxShadow: sel
                    ? [BoxShadow(
                    color: _blue.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4))]
                    : [BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (sel) ...[
                  Icon(CupertinoIcons.checkmark,
                      color: Colors.white, size: 11.w),
                  SizedBox(width: 5.w),
                ],
                Text(
                    '${_slots[i].displayStart} – ${_slots[i].displayEnd}',
                    style: TextStyle(
                      color: sel ? Colors.white : _dark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    )),
              ]),
            ),
          );
        }),
      ),
      SizedBox(height: 10.h),
      Row(children: [
        Icon(CupertinoIcons.info_circle, color: _gray, size: 12.w),
        SizedBox(width: 5.w),
        Expanded(
            child: Text(
                'Tap a slot to select it. '
                    'Tap an adjacent slot to extend the booking window. '
                    'Tap a selected slot to deselect from that point.',
                style: TextStyle(color: _gray, fontSize: 11.sp, height: 1.4))),
      ]),
    ]);
  }

  // ── GUIDE SPECIALIZATIONS ─────────────────────────────────────────────────
  Widget _specializationsWidget() {
    final palette = [_purple, _teal, _rose, _orange, _blue, _green, _amber];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: _specializations.asMap().entries.map((entry) {
        final color = palette[entry.key % palette.length];
        final spec  = entry.value;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.bookmark_fill,
                  color: color, size: 10.w),
            ),
            SizedBox(width: 8.w),
            Text(spec.name,
                style: TextStyle(
                    color: color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700)),
          ]),
        );
      }).toList(),
    );
  }

  // ── LOCAL ACTIVITIES ──────────────────────────────────────────────────────
  Widget _localActivitiesWidget() {
    if (_localActivities.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
            color: _bgPage,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200)),
        child: Text('No activities listed yet.',
            style: TextStyle(color: _gray, fontSize: 13.sp)),
      );
    }

    return Column(
      children: _localActivities.asMap().entries.map((entry) {
        final a = entry.value;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: _cardDeco(),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Card header
            Container(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _teal.withOpacity(0.08),
                    _blue.withOpacity(0.04),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: _teal.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Icon(CupertinoIcons.map,
                        color: _teal, size: 20.w),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.activityName,
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: _dark),
                        ),
                        if (a.activityCategory.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: _teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(a.activityCategory,
                                style: TextStyle(
                                    color: _teal,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ]),
                ),
                // Price badge
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_teal, Color(0xFF0F766E)]),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(children: [
                    Text(
                      'LKR ${a.setPrice.toStringAsFixed(0)}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800),
                    ),
                    Text('per person',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 8.sp)),
                  ]),
                ),
              ]),
            ),

            // Card body
            if (a.activityDescription.isNotEmpty || a.specialNote.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.activityDescription.isNotEmpty) ...[
                        Text(a.activityDescription,
                            style: TextStyle(
                                color: _gray,
                                fontSize: 12.sp,
                                height: 1.5)),
                        if (a.specialNote.isNotEmpty) SizedBox(height: 10.h),
                      ],
                      if (a.specialNote.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                              color: _amber.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: _amber.withOpacity(0.3))),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: _amber,
                                    size: 13.w),
                                SizedBox(width: 7.w),
                                Expanded(
                                  child: Text(a.specialNote,
                                      style: TextStyle(
                                          color: _dark,
                                          fontSize: 11.sp,
                                          height: 1.5)),
                                ),
                              ]),
                        ),
                    ]),
              )
            else
              SizedBox(height: 14.h),
          ]),
        );
      }).toList(),
    );
  }

  // ── GUIDE INTERESTS ─────────────────────────────────────────────────────
  Widget _interestsWidget() {
    final palette = [_purple, _blue, _teal, _rose, _orange, _green, _amber];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _interests.asMap().entries.map((entry) {
        final color    = palette[entry.key % palette.length];
        final interest = entry.value;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(CupertinoIcons.heart_fill, color: color, size: 11.w),
            SizedBox(width: 6.w),
            Text(
              interest.name,
              style: TextStyle(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700),
            ),
          ]),
        );
      }).toList(),
    );
  }

  // ── Reviews ───────────────────────────────────────────────────────────────
  Widget _reviewsWidget(Map<String, dynamic> g) => Column(
      children: (g['reviews'] as List? ?? []).take(5).map((r) {
        final m     = r as Map<String, dynamic>;
        final photo = (m['tourist_photo'] ?? '').toString();
        return Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.all(14.w),
          decoration: _cardDeco(),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                  radius: 18.r,
                  backgroundColor: _blue.withOpacity(0.1),
                  backgroundImage: photo.isNotEmpty
                      ? CachedNetworkImageProvider(photo)
                      : null,
                  child: photo.isEmpty
                      ? Icon(CupertinoIcons.person, color: _blue, size: 14.w)
                      : null),
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(
                      (m['tourist_name'] ?? 'Anonymous').toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.sp))),
              Row(children: [
                Icon(Icons.star_rounded, color: _amber, size: 13.w),
                SizedBox(width: 2.w),
                Text('${(m['rating'] ?? 0).toStringAsFixed(1)}',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 12.sp)),
              ]),
            ]),
            if ((m['review'] ?? '').toString().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text((m['review']).toString(),
                  style:
                  TextStyle(color: _dark, fontSize: 12.sp, height: 1.5)),
            ],
          ]),
        );
      }).toList());

  // ── Gallery ───────────────────────────────────────────────────────────────
  Widget _galleryWidget(Map<String, dynamic> g) {
    final photos = g['gallery'] as List? ?? [];
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: photos.length,
          itemBuilder: (_, i) {
            final url = ((photos[i] as Map)['url'] ?? '').toString();
            return Container(
                width: 95.w,
                margin: EdgeInsets.only(right: 10.w),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: _blue.withOpacity(0.08)),
                        errorWidget: (_, __, ___) =>
                            Container(color: _blue.withOpacity(0.08)))));
          }),
    );
  }

  // ── Book button bar ───────────────────────────────────────────────────────
  Widget _bookBar(BuildContext context, Map<String, dynamic> g) => Container(
    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
    decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ]),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (_hasSelection) ...[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(CupertinoIcons.time, color: _gray, size: 13.w),
              SizedBox(width: 5.w),
              Text('$_selStartDisplay – $_selEndDisplay',
                  style: TextStyle(
                      color: _dark,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700)),
            ]),
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r)),
              child: Text(
                  '${_selected.length} '
                      'hr${_selected.length > 1 ? "s" : ""} selected',
                  style: TextStyle(
                      color: _green,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
      SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: _hasSelection
              ? () => Navigator.pushNamed(
            context,
            '/tourInformation',
            arguments: {
              'guide':        g,
              'booking_date': _searchDate,
              'start_time':   _selStart,
              'end_time':     _selEnd,
              'slot_count':   _selected.length,
            },
          )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _blue,
            disabledBackgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r)),
            elevation: 0,
          ),
          child: Text(
              _hasSelection
                  ? 'Book  ·  $_selStartDisplay – $_selEndDisplay'
                  : 'Select Time Slots Above',
              style: TextStyle(
                  color: _hasSelection ? Colors.white : _gray,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    ]),
  );

  // ── Shared helpers ────────────────────────────────────────────────────────
  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 16,
          offset: const Offset(0, 4))
    ],
  );

  Widget _section(String title, Widget child, {String? hint}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Container(
                width: 3.w,
                height: 18.h,
                decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(2.r))),
            SizedBox(width: 8.w),
            Text(title,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: _dark)),
            if (hint != null) ...[
              SizedBox(width: 6.w),
              Expanded(
                  child: Text(hint,
                      style: TextStyle(color: _gray, fontSize: 10.sp),
                      overflow: TextOverflow.ellipsis)),
            ],
          ],
        ),
        SizedBox(height: 12.h),
        child,
      ]);

  Widget _errScaffold(String msg) => Scaffold(
    backgroundColor: _bgPage,
    appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(msg,
            textAlign: TextAlign.center,
            style:
            TextStyle(color: Colors.red.shade400, fontSize: 14.sp)),
      ),
    ),
  );
}