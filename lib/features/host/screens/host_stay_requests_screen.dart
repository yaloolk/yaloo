// lib/features/host/screens/host_stay_requests_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:yaloo/features/tourist/models/stay_booking_model.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const _blue     = Color(0xFF2563EB);
const _blueDark = Color(0xFF1D4ED8);
const _bg       = Color(0xFFF8FAFC);
const _dark     = Color(0xFF1F2937);
const _gray     = Color(0xFF6B7280);
const _green    = Color(0xFF10B981);
const _amber    = Color(0xFFF59E0B);
const _red      = Color(0xFFEF4444);

class HostStayRequestsScreen extends StatefulWidget {
  const HostStayRequestsScreen({super.key});
  @override State<HostStayRequestsScreen> createState() =>
      _HostStayRequestsScreenState();
}

class _HostStayRequestsScreenState extends State<HostStayRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StayBookingProvider>().loadHostRequests();
      context.read<StayBookingProvider>().loadHostAllBookings();
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  // ── Respond ───────────────────────────────────────────────────────────────
  Future<void> _respond(String bookingId, String action) async {
    String? note;
    if (action == 'reject') {
      note = await _askNote('Reason for rejection (optional)');
    }
    final prov = context.read<StayBookingProvider>();
    final ok   = await prov.respondToBooking(
        bookingId: bookingId, action: action, hostResponseNote: note);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Booking ${action == "accept" ? "accepted ✓" : "declined"}'
            : prov.hostError),
        backgroundColor: ok ? (action == 'accept' ? _green : _gray) : _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _complete(String bookingId) async {
    final prov = context.read<StayBookingProvider>();
    final ok   = await prov.completeBooking(bookingId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Stay marked as completed ✓' : prov.hostError),
        backgroundColor: ok ? _green : _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<String?> _askNote(String hint) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(hint),
        content: TextField(controller: ctrl, maxLines: 3,
            decoration: const InputDecoration(hintText: 'Optional…')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Skip')),
          ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
              child: const Text('Send')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StayBookingProvider>(
      builder: (_, prov, __) {
        final requests  = prov.hostRequests;
        final confirmed = prov.hostBookings.where((b) => b.bookingStatus == 'confirmed').toList();
        final history   = prov.hostBookings.where((b) => b.bookingStatus != 'confirmed' && b.bookingStatus != 'pending').toList();

        return Scaffold(
          backgroundColor: _bg,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(110.h),
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [_blue, _blueDark],
                      begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: SafeArea(bottom: false, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0), child: Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10.r)),
                          child: Icon(CupertinoIcons.chevron_left, color: Colors.white, size: 18.w)),
                    ),
                    SizedBox(width: 12.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Stay Bookings', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      Text('Manage your guest requests',
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.sp)),
                    ]),
                    const Spacer(),
                    if (requests.isNotEmpty)
                      Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.white.withOpacity(0.3))),
                          child: Text('${requests.length} new',
                              style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w700))),
                  ])),
                  SizedBox(height: 8.h),
                  TabBar(
                    controller: _tab, isScrollable: false,
                    labelColor: Colors.white, unselectedLabelColor: Colors.white.withOpacity(0.55),
                    labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
                    indicator: UnderlineTabIndicator(
                        borderSide: const BorderSide(width: 2.5, color: Colors.white),
                        insets: EdgeInsets.symmetric(horizontal: 20.w)),
                    tabs: [
                      Tab(child: _tabLabel('Requests', requests.length, _amber)),
                      Tab(child: _tabLabel('Upcoming', confirmed.length, _green)),
                      Tab(child: _tabLabel('History', history.length, _gray)),
                    ],
                  ),
                ],
              )),
            ),
          ),
          body: prov.hostLoading
              ? const Center(child: CircularProgressIndicator(color: _blue))
              : TabBarView(controller: _tab, children: [
            // ── Requests ───────────────────────────────────────────────
            _buildListTab(requests, emptyTitle: 'No pending requests',
                emptySubtitle: 'New booking requests will appear here',
                itemBuilder: (b) => _RequestCard(booking: b,
                    onAccept: () => _respond(b.id, 'accept'),
                    onReject: () => _respond(b.id, 'reject'))),

            // ── Upcoming ───────────────────────────────────────────────
            _buildListTab(confirmed, emptyTitle: 'No upcoming bookings',
                emptySubtitle: 'Confirmed bookings will appear here',
                itemBuilder: (b) => _ConfirmedCard(booking: b,
                    onComplete: () => _complete(b.id))),

            // ── History ────────────────────────────────────────────────
            _buildListTab(history, emptyTitle: 'No booking history yet',
                emptySubtitle: 'Completed and past bookings will appear here',
                itemBuilder: (b) => _HistoryCard(booking: b)),
          ]),
        );
      },
    );
  }

  Widget _tabLabel(String label, int count, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label),
      if (count > 0) ...[
        SizedBox(width: 5.w),
        Container(padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
            decoration: BoxDecoration(color: color.withOpacity(0.25), borderRadius: BorderRadius.circular(10.r)),
            child: Text('$count', style: TextStyle(fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.w800))),
      ],
    ]);
  }

  Widget _buildListTab(List<StayBookingModel> items, {
    required String emptyTitle,
    required String emptySubtitle,
    required Widget Function(StayBookingModel) itemBuilder,
  }) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(color: _blue.withOpacity(0.07), shape: BoxShape.circle),
            child: Icon(CupertinoIcons.calendar, color: _blue, size: 40.w)),
        SizedBox(height: 16.h),
        Text(emptyTitle, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _dark)),
        SizedBox(height: 6.h),
        Text(emptySubtitle, style: TextStyle(color: _gray, fontSize: 13.sp), textAlign: TextAlign.center),
      ]));
    }
    return RefreshIndicator(
      color: _blue,
      onRefresh: () async {
        await context.read<StayBookingProvider>().loadHostRequests();
        await context.read<StayBookingProvider>().loadHostAllBookings();
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 32.h),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, i) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: itemBuilder(items[i])),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Card (pending → accept / reject)
// ─────────────────────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final StayBookingModel booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _RequestCard({required this.booking, required this.onAccept, required this.onReject});

  String _fd(String d) { try { return DateFormat('dd MMM yyyy').format(DateTime.parse(d)); } catch (_) { return d; } }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Tourist row
        Row(children: [
          CircleAvatar(radius: 22,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: booking.touristPhoto.isNotEmpty ? CachedNetworkImageProvider(booking.touristPhoto) : null,
              child: booking.touristPhoto.isEmpty ? Text(
                  booking.touristFullName.isNotEmpty ? booking.touristFullName[0].toUpperCase() : 'G',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _dark)) : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(booking.touristFullName.isNotEmpty ? booking.touristFullName : 'Guest',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark), overflow: TextOverflow.ellipsis),
            if (booking.touristPhone.isNotEmpty)
              Text(booking.touristPhone, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _amber.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: const Text('Pending', style: TextStyle(color: _amber, fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 12),

        // Details block
        Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7FAFF), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _row(CupertinoIcons.house, '${booking.stayName}'),
              const SizedBox(height: 5),
              _row(CupertinoIcons.calendar, '${_fd(booking.checkinDate)} → ${_fd(booking.checkoutDate)}  (${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''})'),
              const SizedBox(height: 5),
              _row(CupertinoIcons.person_2, '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}  ·  ${booking.roomCount} room${booking.roomCount > 1 ? 's' : ''}  ·  ${_cap(booking.mealPreference)} meal'),
              if (booking.specialNote?.isNotEmpty == true) ...[
                const SizedBox(height: 5),
                _row(CupertinoIcons.doc_text, booking.specialNote!),
              ],
            ])),
        const SizedBox(height: 10),

        Row(children: [
          Text('LKR ${booking.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _blue)),
          const Spacer(),
          OutlinedButton(onPressed: onReject,
              style: OutlinedButton.styleFrom(foregroundColor: _red, side: const BorderSide(color: _red),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: onAccept,
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
        ]),
      ])),
    );
  }

  Widget _row(IconData icon, String t) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 13, color: _gray), const SizedBox(width: 8),
    Expanded(child: Text(t, style: const TextStyle(fontSize: 12, color: _dark))),
  ]);
  String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirmed Card (upcoming → mark complete)
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmedCard extends StatelessWidget {
  final StayBookingModel booking;
  final VoidCallback onComplete;
  const _ConfirmedCard({required this.booking, required this.onComplete});

  String _fd(String d) { try { return DateFormat('dd MMM').format(DateTime.parse(d)); } catch (_) { return d; } }

  bool get _isToday {
    try {
      final ci = DateTime.parse(booking.checkinDate);
      final now = DateTime.now();
      return ci.year == now.year && ci.month == now.month && ci.day == now.day;
    } catch (_) { return false; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(children: [
        // Date header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _isToday ? _blue.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Row(children: [
            if (_isToday) Container(margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(6)),
                child: const Text('TODAY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
            Icon(CupertinoIcons.calendar, size: 13, color: _isToday ? _blue : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text('${_fd(booking.checkinDate)} → ${_fd(booking.checkoutDate)}  · ${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _isToday ? _blue : Colors.grey.shade700)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Text('Confirmed', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
        ),
        Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade100,
              backgroundImage: booking.touristPhoto.isNotEmpty ? CachedNetworkImageProvider(booking.touristPhoto) : null,
              child: booking.touristPhoto.isEmpty
                  ? Text(booking.touristFullName.isNotEmpty ? booking.touristFullName[0].toUpperCase() : 'G',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _dark)) : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(booking.touristFullName.isNotEmpty ? booking.touristFullName : 'Guest',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark), overflow: TextOverflow.ellipsis),
            Text('${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''} · ${booking.roomCount} room${booking.roomCount > 1 ? 's' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            if (booking.touristPhone.isNotEmpty)
              Row(children: [
                Icon(CupertinoIcons.phone, size: 11, color: _green), const SizedBox(width: 4),
                Text(booking.touristPhone, style: const TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600)),
              ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('LKR ${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _dark)),
            Text('total', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ]),
        ])),
        Padding(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Mark as Completed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History Card (completed / rejected / cancelled)
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final StayBookingModel booking;
  const _HistoryCard({required this.booking});

  Color get _statusColor {
    switch (booking.bookingStatus) {
      case 'completed': return _blue;
      case 'rejected': return _red;
      case 'cancelled': return _gray;
      default: return _amber;
    }
  }

  String get _statusLabel {
    switch (booking.bookingStatus) {
      case 'completed': return 'Completed';
      case 'rejected':  return 'Declined';
      case 'cancelled': return 'Cancelled';
      default: return booking.bookingStatus;
    }
  }

  String _fd(String d) { try { return DateFormat('dd MMM yyyy').format(DateTime.parse(d)); } catch (_) { return d; } }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))]),
      child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
        CircleAvatar(radius: 22, backgroundColor: Colors.grey.shade100,
            backgroundImage: booking.touristPhoto.isNotEmpty ? CachedNetworkImageProvider(booking.touristPhoto) : null,
            child: booking.touristPhoto.isEmpty
                ? Text(booking.touristFullName.isNotEmpty ? booking.touristFullName[0].toUpperCase() : 'G',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _dark)) : null),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.touristFullName.isNotEmpty ? booking.touristFullName : 'Guest',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark), overflow: TextOverflow.ellipsis),
          Text('${_fd(booking.checkinDate)} → ${_fd(booking.checkoutDate)}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          Text('LKR ${booking.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _blue)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor.withOpacity(0.3))),
            child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700))),
      ])),
    );
  }
}