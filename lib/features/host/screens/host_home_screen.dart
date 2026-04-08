// lib/features/host/screens/host_home_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';
import 'package:yaloo/features/host/models/host_models.dart';
import 'package:yaloo/features/host/screens/host_stay_edit_screen.dart';
import 'package:yaloo/features/host/screens/host_stay_availability_screen.dart';
import 'package:yaloo/features/tourist/models/stay_booking_model.dart';
import 'package:yaloo/features/tourist/providers/stay_booking_provider.dart';
import '../../auth/screens/host/host_stay_details_screen.dart';

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

class HostHomeScreen extends StatefulWidget {
  const HostHomeScreen({super.key});
  @override State<HostHomeScreen> createState() => _HostHomeScreenState();
}

class _HostHomeScreenState extends State<HostHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<HostProvider>().loadDashboard();
    await Future.wait([
      context.read<StayBookingProvider>().loadHostRequests(),
      context.read<StayBookingProvider>().loadHostAllBookings(status: 'confirmed'),
    ]);
    _animCtrl.forward();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await context.read<HostProvider>().loadDashboard(forceRefresh: true);
    await Future.wait([
      context.read<StayBookingProvider>().loadHostRequests(),
      context.read<StayBookingProvider>().loadHostAllBookings(status: 'confirmed'),
    ]);
  }

  void _showPropertySwitcher() {
    HapticFeedback.mediumImpact();
    final provider = context.read<HostProvider>();
    final stays = provider.dashboard?.stays ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PropertySwitcherSheet(
        stays: stays,
        selectedIndex: provider.selectedStayIndex,
        onSelect: (i) { provider.selectStay(i); Navigator.pop(context); },
      ),
    );
  }

  // ── Respond to stay request ───────────────────────────────────────────────
  Future<void> _respond(String bookingId, String action) async {
    HapticFeedback.mediumImpact();
    String? note;
    if (action == 'reject') {
      note = await _askNote(context, 'Reason for rejection (optional)');
    }
    final prov = context.read<StayBookingProvider>();
    final ok   = await prov.respondToBooking(
        bookingId: bookingId, action: action, hostResponseNote: note);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? 'Booking ${action == "accept" ? "accepted ✓" : "rejected"}'
            : prov.hostError),
        backgroundColor: ok ? (action == 'accept' ? _green : _gray) : _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<String?> _askNote(BuildContext ctx, String hint) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(hint),
        content: TextField(controller: ctrl, maxLines: 3,
            decoration: const InputDecoration(hintText: 'Optional note…')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Skip')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Consumer<HostProvider>(
          builder: (context, hostProv, _) {
            if (hostProv.dashboardLoading && hostProv.dashboard == null) {
              return _loadingState();
            }
            final dashboard = hostProv.dashboard;
            if (dashboard == null || dashboard.stays.isEmpty) {
              return _emptyState();
            }
            final selectedStay = hostProv.selectedStay;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: _blue,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(dashboard),
                  _buildPropertySwitcher(hostProv, selectedStay),
                  if (selectedStay != null) _buildQuickActions(selectedStay),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _buildStayRequestsSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _buildUpcomingSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
      // floatingActionButton: _addPropertyFab(),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildHeader(HostDashboard dashboard) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_blue, _blueDark, _blueDarker],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 30, offset: const Offset(0, 12), spreadRadius: -5)],
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(children: [
            Row(children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  backgroundImage: dashboard.profilePic != null
                      ? NetworkImage(dashboard.profilePic!) : null,
                  child: dashboard.profilePic == null
                      ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome back', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(dashboard.hostName.split(' ').first,
                    style: const TextStyle(color: Colors.white, fontSize: 24,
                        fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    overflow: TextOverflow.ellipsis),
              ])),
              _glassIconBtn(Icons.notifications_outlined, () =>
                  Navigator.pushNamed(context, '/notification')),
            ]),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _glassStat('${dashboard.totalStays}', 'Properties', Icons.home_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _glassStat('${dashboard.activeStays}', 'Active', Icons.check_circle_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _glassStat(
                  '\$${NumberFormat.compact().format(dashboard.totalEarned)}',
                  'Earned', Icons.account_balance_wallet_rounded)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _glassStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  Widget _glassIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  // ── Property Switcher ─────────────────────────────────────────────────────
  SliverToBoxAdapter _buildPropertySwitcher(HostProvider prov, Stay? selected) {
    if (selected == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final stays = prov.dashboard?.stays ?? [];

    return SliverToBoxAdapter(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
          Text('Your Properties', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600, letterSpacing: 0.5)),
          const Spacer(),
          if (stays.length > 1)
            TextButton.icon(
              onPressed: _showPropertySwitcher,
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Switch'),
              style: TextButton.styleFrom(foregroundColor: _blue, textStyle: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ])),
        const SizedBox(height: 12),
        SizedBox(height: 100, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: stays.length + 1,
          itemBuilder: (ctx, i) {
            if (i == stays.length) return _addStoryTile();
            final stay = stays[i];
            final isSel = i == prov.selectedStayIndex;
            return GestureDetector(
              onTap: () { if (!isSel) { HapticFeedback.selectionClick(); prov.selectStay(i); } },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                child: Column(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isSel ? _blue : Colors.grey.shade300, width: isSel ? 3 : 2),
                      boxShadow: isSel ? [BoxShadow(color: _blue.withOpacity(0.3), blurRadius: 12, spreadRadius: 2)] : null,
                    ),
                    child: ClipOval(child: stay.coverPhoto != null
                        ? Image.network(stay.coverPhoto!, fit: BoxFit.cover, width: 64, height: 64,
                        errorBuilder: (_, __, ___) => _stayIconFb())
                        : _stayIconFb()),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(width: 70, child: Text(stay.name,
                      style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                          color: isSel ? _blue : Colors.grey.shade600),
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
                ]),
              ),
            );
          },
        )),
        const SizedBox(height: 16),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _selectedPropertyCard(selected)),
      ]),
    );
  }

  Widget _stayIconFb() => Container(color: Colors.grey.shade100, child: Icon(Icons.home, color: Colors.grey.shade400));

  Widget _addStoryTile() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostStayDetailsScreen())),
      child: Column(children: [
        Container(width: 64, height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid)),
            child: Icon(Icons.add, color: Colors.grey.shade500, size: 24)),
        const SizedBox(height: 6),
        SizedBox(width: 70, child: Text('Add New', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade600), textAlign: TextAlign.center)),
      ]),
    );
  }

  Widget _selectedPropertyCard(Stay stay) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -4)]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(children: [
          Stack(children: [
            Container(height: 140, width: double.infinity, color: Colors.grey.shade100,
                child: stay.coverPhoto != null
                    ? Image.network(stay.coverPhoto!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Icon(Icons.home_max_rounded, size: 48, color: Colors.grey.shade300)))
                    : Center(child: Icon(Icons.home_max_rounded, size: 48, color: Colors.grey.shade300))),
            Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 70,
                decoration: BoxDecoration(gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                    begin: Alignment.bottomCenter, end: Alignment.topCenter)))),
            Positioned(top: 12, right: 12, child: Row(children: [
              _glassBadge(stay.verificationStatus == 'verified' ? 'Verified' : 'Pending',
                  stay.verificationStatus == 'verified' ? _green : _amber),
              if (stay.isActive) ...[const SizedBox(width: 6), _glassBadge('Active', _blue)],
            ])),
            Positioned(bottom: 12, left: 16, right: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(stay.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Expanded(child: Text(stay.cityName, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(stay.avgRating > 0 ? stay.avgRating.toStringAsFixed(1) : 'New',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ])),
              ]),
            ])),
          ]),
          Padding(padding: const EdgeInsets.all(16), child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickInfo(Icons.meeting_room, '${stay.roomCount}', 'Rooms'),
                _quickInfo(Icons.people, '${stay.maxGuests}', 'Guests'),
                _quickInfo(Icons.attach_money, stay.pricePerNight.toStringAsFixed(0), '/night'),
              ])),
        ]),
      ),
    );
  }

  Widget _glassBadge(String text, Color color) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.9), borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)));
  }

  Widget _quickInfo(IconData icon, String val, String label) {
    return Column(children: [
      Icon(icon, color: _blue, size: 20),
      const SizedBox(height: 4),
      Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark)),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
    ]);
  }

  // ── Quick actions ─────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildQuickActions(Stay stay) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(children: [
          Expanded(child: _actionBtn(Icons.edit_calendar_rounded, 'Availability', const Color(0xFF8B5CF6), () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => HostStayAvailabilityScreen(stayId: stay.id))))),
          const SizedBox(width: 10),
          Expanded(child: _actionBtn(Icons.edit_rounded, 'Edit Stay', _blue, () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => HostStayEditScreen(stayId: stay.id))))),
          const SizedBox(width: 10),
          Expanded(child: _actionBtn(Icons.list_alt_rounded, 'All Requests', _green, () =>
              Navigator.pushNamed(context, '/hostStayRequests'))),
        ]),
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -2)]),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ]),
      ),
    );
  }

  // ── Stay Requests Section ─────────────────────────────────────────────────
  SliverToBoxAdapter _buildStayRequestsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<StayBookingProvider>(
          builder: (_, prov, __) {
            final requests = prov.hostRequests;
            final loading  = prov.hostLoading && requests.isEmpty;

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _amber.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.notifications_active_rounded, color: _amber, size: 20)),
                const SizedBox(width: 12),
                const Text('Stay Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _dark, letterSpacing: -0.5)),
                const Spacer(),
                if (requests.isNotEmpty)
                  _countBadge(requests.length, _amber),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/hostStayRequests'),
                  child: const Text('See All', style: TextStyle(color: _blue, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ]),
              const SizedBox(height: 12),
              if (loading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: _blue)))
              else if (requests.isEmpty)
                _emptyBox(Icons.inbox_outlined, 'No pending requests', 'New requests will appear here')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _RequestCard(
                    booking:  requests[i],
                    onAccept: () => _respond(requests[i].id, 'accept'),
                    onReject: () => _respond(requests[i].id, 'reject'),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  // ── Upcoming Bookings Section ─────────────────────────────────────────────
  SliverToBoxAdapter _buildUpcomingSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<StayBookingProvider>(
          builder: (_, prov, __) {
            // Upcoming = confirmed bookings (loaded with status='confirmed')
            final bookings = prov.hostBookings
                .where((b) => b.bookingStatus == 'confirmed')
                .toList();
            final loading = prov.hostLoading && bookings.isEmpty;

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.event_available_rounded, color: _green, size: 20)),
                const SizedBox(width: 12),
                const Text('Upcoming Bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _dark, letterSpacing: -0.5)),
                const Spacer(),
                if (bookings.isNotEmpty)
                  _countBadge(bookings.length, _green),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/hostStayRequests'),
                  child: const Text('View All', style: TextStyle(color: _blue, fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ]),
              const SizedBox(height: 12),
              if (loading)
                const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: _blue)))
              else if (bookings.isEmpty)
                _emptyBox(Icons.calendar_today_outlined, 'No upcoming bookings', 'Confirmed bookings will appear here')
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _UpcomingCard(
                    booking:    bookings[i],
                    onComplete: () => _complete(bookings[i].id),
                  ),
                ),
            ]);
          },
        ),
      ),
    );
  }

  Future<void> _complete(String bookingId) async {
    HapticFeedback.mediumImpact();
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

  // ── Shared helpers ─────────────────────────────────────────────────────────
  Widget _countBadge(int n, Color color) {
    return Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
        child: Text('$n', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)));
  }

  Widget _emptyBox(IconData icon, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Center(child: Column(children: [
        Icon(icon, size: 40, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(sub, style: TextStyle(fontSize: 12, color: Colors.grey.shade400), textAlign: TextAlign.center),
      ])),
    );
  }

  Widget _loadingState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: _blue.withOpacity(0.1), shape: BoxShape.circle),
        child: const CircularProgressIndicator(color: _blue, strokeWidth: 3)),
    const SizedBox(height: 20),
    Text('Loading dashboard…', style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
  ]));

  Widget _emptyState() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(gradient: LinearGradient(
              colors: [_blue.withOpacity(0.1), _blue.withOpacity(0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight), shape: BoxShape.circle),
          child: const Icon(Icons.home_outlined, size: 72, color: _blue)),
      const SizedBox(height: 28),
      const Text('Start your hosting journey', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: _dark, letterSpacing: -0.5)),
      const SizedBox(height: 12),
      Text('Add your first property and start earning with Yaloo',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.5), textAlign: TextAlign.center),
      const SizedBox(height: 36),
      GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostStayDetailsScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [_blue, _blueDark]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))]),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_home_work_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text('Add Your First Property', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    ]),
  ));

  Widget _addPropertyFab() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_blue, _blueDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _blue.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 12), spreadRadius: -4)],
      ),
      child: FloatingActionButton.extended(
        onPressed: () { HapticFeedback.mediumImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HostStayDetailsScreen())); },
        backgroundColor: Colors.transparent, elevation: 0,
        icon: const Icon(Icons.add_home_work_rounded, size: 22),
        label: const Text('Add Stay', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Card
// ─────────────────────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final StayBookingModel booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  const _RequestCard({required this.booking, required this.onAccept, required this.onReject});

  String _fmtDate(String d) {
    try { final dt = DateTime.parse(d); return DateFormat('dd MMM yyyy').format(dt); }
    catch (_) { return d; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Tourist info
          Row(children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
              child: CircleAvatar(radius: 22,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: booking.touristPhoto.isNotEmpty
                      ? CachedNetworkImageProvider(booking.touristPhoto) : null,
                  child: booking.touristPhoto.isEmpty
                      ? Text(booking.touristFullName.isNotEmpty ? booking.touristFullName[0].toUpperCase() : 'G',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: _dark)) : null),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.touristFullName.isNotEmpty ? booking.touristFullName : 'Guest',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark), overflow: TextOverflow.ellipsis),
              if (booking.touristPhone.isNotEmpty)
                Row(children: [
                  Icon(CupertinoIcons.phone, size: 11, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(booking.touristPhone, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ]),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: _amber.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text('Pending', style: TextStyle(color: _amber, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 12),

          // Stay details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF7FAFF), borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              _row(CupertinoIcons.bed_double, '${booking.stayName}  ·  ${booking.roomCount} room${booking.roomCount > 1 ? 's' : ''}'),
              const SizedBox(height: 6),
              _row(CupertinoIcons.calendar, '${_fmtDate(booking.checkinDate)} → ${_fmtDate(booking.checkoutDate)}  (${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''})'),
              const SizedBox(height: 6),
              _row(CupertinoIcons.person_2, '${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}  ·  ${_capitalize(booking.mealPreference)} meal'),
              if (booking.specialNote?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                _row(CupertinoIcons.doc_text, booking.specialNote!),
              ],
            ]),
          ),
          const SizedBox(height: 10),

          Row(children: [
            Text('LKR ${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _blue)),
            const Spacer(),
            OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(foregroundColor: _red, side: const BorderSide(color: _red),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Decline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(backgroundColor: _green, foregroundColor: Colors.white, elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, size: 13, color: _gray),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: _dark))),
  ]);

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming / Confirmed Booking Card
// ─────────────────────────────────────────────────────────────────────────────
class _UpcomingCard extends StatelessWidget {
  final StayBookingModel booking;
  final VoidCallback? onComplete;
  const _UpcomingCard({required this.booking, this.onComplete});

  String _fmtDate(String d) {
    try { return DateFormat('dd MMM').format(DateTime.parse(d)); }
    catch (_) { return d; }
  }

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(children: [
        // Date header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
              color: _isToday ? _blue.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Row(children: [
            if (_isToday) Container(margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _blue, borderRadius: BorderRadius.circular(6)),
                child: const Text('TODAY', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
            Icon(CupertinoIcons.calendar, size: 14,
                color: _isToday ? _blue : Colors.grey.shade500),
            const SizedBox(width: 6),
            Text('${_fmtDate(booking.checkinDate)} → ${_fmtDate(booking.checkoutDate)}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: _isToday ? _blue : Colors.grey.shade700)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: const Text('Confirmed', style: TextStyle(color: _green, fontSize: 11, fontWeight: FontWeight.w700))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
              child: CircleAvatar(radius: 22,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage: booking.touristPhoto.isNotEmpty
                      ? CachedNetworkImageProvider(booking.touristPhoto) : null,
                  child: booking.touristPhoto.isEmpty
                      ? Text(booking.touristFullName.isNotEmpty ? booking.touristFullName[0].toUpperCase() : 'G',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _dark)) : null),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.touristFullName.isNotEmpty ? booking.touristFullName : 'Guest',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text('${booking.guestCount} guest${booking.guestCount > 1 ? 's' : ''}  ·  ${booking.totalNights} night${booking.totalNights > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              if (booking.stayCoverPhoto.isNotEmpty || booking.stayName.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(booking.stayName, style: TextStyle(fontSize: 11, color: Colors.grey.shade400), overflow: TextOverflow.ellipsis),
              ],
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('LKR ${booking.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark)),
              Text('total', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ]),
          ]),
        ),
        if (onComplete != null) Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: const Text('Mark as Completed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10), elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          )),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Property Switcher Sheet (unchanged in logic, styled to match)
// ─────────────────────────────────────────────────────────────────────────────
class _PropertySwitcherSheet extends StatelessWidget {
  final List<Stay> stays;
  final int selectedIndex;
  final Function(int) onSelect;
  const _PropertySwitcherSheet({required this.stays, required this.selectedIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 16),
        Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 20),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Row(children: [
          const Text('Switch Property', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _dark, letterSpacing: -0.5)),
          const Spacer(),
          IconButton(onPressed: () => Navigator.pop(context),
              icon: Container(padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.close, color: Colors.grey.shade600))),
        ])),
        const SizedBox(height: 8),
        Flexible(child: ListView.builder(
          shrinkWrap: true, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          itemCount: stays.length,
          itemBuilder: (_, i) {
            final stay = stays[i]; final isSel = i == selectedIndex;
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); onSelect(i); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: isSel ? _blue.withOpacity(0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isSel ? _blue : Colors.grey.shade200, width: isSel ? 2 : 1),
                    boxShadow: isSel ? [BoxShadow(color: _blue.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))] : null),
                child: Row(children: [
                  Container(width: 56, height: 56,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isSel ? _blue.withOpacity(0.3) : Colors.grey.shade200, width: 2)),
                      child: ClipRRect(borderRadius: BorderRadius.circular(12),
                          child: stay.coverPhoto != null
                              ? Image.network(stay.coverPhoto!, fit: BoxFit.cover)
                              : Container(color: Colors.grey.shade100, child: Icon(Icons.home, color: Colors.grey.shade400)))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(stay.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: isSel ? _blue : _dark), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(child: Text(stay.cityName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                    ]),
                  ])),
                  if (isSel)
                    Container(padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: _blue, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 18)),
                ]),
              ),
            );
          },
        )),
        const SizedBox(height: 16),
      ])),
    );
  }
}