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

// ── Slot model (internal only) ────────────────────────────────────────────────
class _Slot {
  final String id;
  final String start; // "HH:MM:SS" or "HH:MM" — raw from API
  final String end;

  const _Slot({required this.id, required this.start, required this.end});

  factory _Slot.fromJson(Map<String, dynamic> m) => _Slot(
    id:    m['id']?.toString()         ?? '',
    start: m['start_time']?.toString() ?? '',
    end:   m['end_time']?.toString()   ?? '',
  );

  // Strip seconds so "09:00:00" → "09:00" (used when sending to backend)
  String get startClean {
    final p = start.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : start;
  }

  String get endClean {
    final p = end.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : end;
  }

  /// Display label: "9:00 AM"
  String _fmt(String raw) {
    try {
      final p = raw.split(':');
      int h   = int.parse(p[0]);
      final m = p[1].padLeft(2, '0');
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

class GuideDetailScreen extends StatefulWidget {
  const GuideDetailScreen({super.key});
  @override State<GuideDetailScreen> createState() => _State();
}

class _State extends State<GuideDetailScreen> {
  String? _searchDate;
  bool    _argsApplied = false;

  // ── Slot state ────────────────────────────────────────────────────────────
  // Populated from guideDetail['availability'][_searchDate] after load.
  // We do NOT use the availability_slots passed in navigate arguments —
  // those are search-time-filtered. We always use the full-day list from
  // the profile API so tourists see every available slot on that date.
  List<_Slot> _slots    = [];
  List<int>   _selected = []; // ordered indices, always contiguous

  // Track which profile version the slots were built from (prevents loop)
  int _slotsBuiltFromHash = 0;

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

  // ── Sync slots from freshly loaded profile ────────────────────────────────
  void _syncSlots(Map<String, dynamic> g) {
    if (_searchDate == null) return;

    final avail = (g['availability'] as Map<String, dynamic>?) ?? {};
    final raw   = (avail[_searchDate] as List?) ?? [];
    final hash  = raw.length ^ _searchDate.hashCode ^ g['guide_profile_id'].hashCode;

    if (hash == _slotsBuiltFromHash) return; // already up to date

    final fresh = raw
        .map((s) => _Slot.fromJson(s as Map<String, dynamic>))
        .toList();

    setState(() {
      _slots              = fresh;
      _selected           = [];
      _slotsBuiltFromHash = hash;
    });
  }

  // ── Contiguous multi-slot selection ───────────────────────────────────────
  //
  // Rules:
  //  • Tap an unselected slot adjacent to the current range → extend range
  //  • Tap a non-adjacent slot → start a fresh single-slot selection
  //  • Tap the last selected slot → deselect it (shrink range from the end)
  //  • Tap any slot inside the range → deselect from that slot onward
  //  • Slots must share a boundary (slot[i].end == slot[i+1].start) to be
  //    considered adjacent; a gap rejects the tap with a snackbar
  void _tapSlot(int idx) {
    setState(() {
      if (_selected.contains(idx)) {
        // Deselect from this index to end of selection (shrink)
        _selected.removeWhere((i) => i >= idx);
      } else {
        if (_selected.isEmpty) {
          _selected = [idx];
          return;
        }

        final first = _selected.first;
        final last  = _selected.last;

        if (idx == last + 1) {
          // Extend toward end — check boundary
          if (_slotsAdjacent(last, idx)) {
            _selected.add(idx);
          } else {
            _showGapWarning();
          }
        } else if (idx == first - 1) {
          // Extend toward start — check boundary
          if (_slotsAdjacent(idx, first)) {
            _selected.insert(0, idx);
          } else {
            _showGapWarning();
          }
        } else {
          // Non-adjacent → start fresh
          _selected = [idx];
        }
      }
    });
  }

  bool _slotsAdjacent(int a, int b) {
    // Compare HH:MM only (strip seconds from DB values like "09:00:00")
    return _slots[a].endClean == _slots[b].startClean;
  }

  void _showGapWarning() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('There is a gap between those slots — '
          'please select adjacent slots only'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  bool    get _hasSelection => _selected.isNotEmpty;
  String? get _selStart =>
      _selected.isNotEmpty ? _slots[_selected.first].startClean : null;
  String? get _selEnd =>
      _selected.isNotEmpty ? _slots[_selected.last].endClean : null;
  String? get _selStartDisplay =>
      _selected.isNotEmpty ? _slots[_selected.first].displayStart : null;
  String? get _selEndDisplay =>
      _selected.isNotEmpty ? _slots[_selected.last].displayEnd : null;

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

        // Sync slots after each rebuild (post-frame to avoid setState-in-build)
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _syncSlots(g));

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
                      if ((g['profile_bio'] ?? '').toString().isNotEmpty) ...[
                        _section('About', _bioWidget(g)),
                        SizedBox(height: 18.h),
                      ],
                      if ((g['languages'] as List? ?? []).isNotEmpty) ...[
                        _section('Languages', _languagesWidget(g)),
                        SizedBox(height: 18.h),
                      ],
                      if ((g['specialties'] as List? ?? []).isNotEmpty) ...[
                        _section('Specialties', _specialtiesWidget(g)),
                        SizedBox(height: 18.h),
                      ],
                      // ── Slot picker ──────────────────────────────────────
                      _section(
                        'Available Time Slots',
                        _slotPicker(),
                        hint: _searchDate != null
                            ? 'All free slots for $_searchDate'
                            : null,
                      ),
                      SizedBox(height: 18.h),
                      if ((g['reviews'] as List? ?? []).isNotEmpty) ...[
                        _section(
                            'Reviews (${g['review_count'] ?? 0})',
                            _reviewsWidget(g)),
                        SizedBox(height: 18.h),
                      ],
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
              imageUrl: pic, fit: BoxFit.cover,
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

  // ── Header: name + rate ───────────────────────────────────────────────────
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
        padding:
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
            gradient:
            const LinearGradient(colors: [_blue, _blueDark]),
            borderRadius: BorderRadius.circular(12.r)),
        child: Column(children: [
          Text(
              'LKR ${(g['rate_per_hour'] ?? 0).toStringAsFixed(0)}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800)),
          Text('per hour',
              style:
              TextStyle(color: Colors.white70, fontSize: 9.sp)),
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

  Widget _verBadge(String label, IconData icon, Color color) =>
      Container(
        padding:
        EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
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

  // ── Stats ─────────────────────────────────────────────────────────────────
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

  Widget _stat(String val, String lbl, IconData icon, Color c) =>
      Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: _cardDeco(),
        child: Column(children: [
          Icon(icon, color: c, size: 18.w),
          SizedBox(height: 4.h),
          Text(val,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: _dark)),
          SizedBox(height: 2.h),
          Text(lbl, style: TextStyle(fontSize: 9.sp, color: _gray)),
        ]),
      );

  // ── Bio / Languages / Specialties ─────────────────────────────────────────
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
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
                color: native
                    ? _blue.withOpacity(0.08)
                    : _bgPage,
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

  Widget _specialtiesWidget(Map<String, dynamic> g) => Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: (g['specialties'] as List? ?? []).map((s) {
        final m = s as Map<String, dynamic>;
        return Container(
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
                color: _green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: _green.withOpacity(0.3))),
            child: Text((m['name'] ?? '').toString(),
                style: TextStyle(
                    color: _green,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600)));
      }).toList());

  // ── SLOT PICKER ───────────────────────────────────────────────────────────
  //
  // Shows ALL free slots for _searchDate loaded from
  // guideDetail['availability'][_searchDate].
  //
  // Selection rules (contiguous only):
  //  • First tap → select that slot
  //  • Next tap on adjacent slot → extend selection
  //  • Tap non-adjacent → start fresh single selection
  //  • Tap selected slot → deselect from that slot onward
  Widget _slotPicker() {
    // ── Loading / empty states ─────────────────────────────────────────
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
                style:
                TextStyle(color: _dark, fontSize: 13.sp, height: 1.5)),
          ),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Selection summary pill ─────────────────────────────────────────
      if (_hasSelection)
        Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
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

      // ── Slot chips ────────────────────────────────────────────────────
      Wrap(
        spacing: 8.w,
        runSpacing: 10.h,
        children: List.generate(_slots.length, (i) {
          final sel = _selected.contains(i);

          // Highlight chips that can extend the current selection
          final canExtend = _selected.isEmpty ||
              (i == _selected.last + 1 && _slotsAdjacent(_selected.last, i)) ||
              (i == _selected.first - 1 && _slotsAdjacent(i, _selected.first));

          return GestureDetector(
            onTap: () => _tapSlot(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                gradient: sel
                    ? const LinearGradient(
                    colors: [_blue, _blueDark])
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
                    ? [
                  BoxShadow(
                      color: _blue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
                    : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
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

      // ── Usage hint ────────────────────────────────────────────────────
      SizedBox(height: 10.h),
      Row(children: [
        Icon(CupertinoIcons.info_circle, color: _gray, size: 12.w),
        SizedBox(width: 5.w),
        Expanded(child: Text(
            'Tap a slot to select it. '
                'Tap an adjacent slot to extend the booking window. '
                'Tap a selected slot to deselect from that point.',
            style: TextStyle(color: _gray, fontSize: 11.sp, height: 1.4))),
      ]),
    ]);
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
                      ? Icon(CupertinoIcons.person,
                      color: _blue, size: 14.w)
                      : null),
              SizedBox(width: 10.w),
              Expanded(
                  child: Text(
                      (m['tourist_name'] ?? 'Anonymous').toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp))),
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
                  style: TextStyle(
                      color: _dark, fontSize: 12.sp, height: 1.5)),
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
            final url =
            ((photos[i] as Map)['url'] ?? '').toString();
            return Container(
                width: 95.w,
                margin: EdgeInsets.only(right: 10.w),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder:  (_, __) =>
                            Container(color: _blue.withOpacity(0.08)),
                        errorWidget: (_, __, ___) =>
                            Container(color: _blue.withOpacity(0.08)))));
          }),
    );
  }

  // ── Book button bar ───────────────────────────────────────────────────────
  Widget _bookBar(BuildContext context, Map<String, dynamic> g) =>
      Container(
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
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
                  // Pass clean HH:MM (no seconds) for backend
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
            style: TextStyle(
                color: Colors.red.shade400, fontSize: 14.sp)),
      ),
    ),
  );
}