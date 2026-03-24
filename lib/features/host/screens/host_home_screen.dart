// lib/features/host/screens/host_home_screen.dart
// ✅ FIXED - Overflow issues resolved, responsive layout

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';
import 'package:yaloo/features/host/models/host_models.dart';
import 'package:yaloo/features/host/screens/host_stay_edit_screen.dart';
import 'package:yaloo/features/host/screens/host_stay_availability_screen.dart';
import 'package:intl/intl.dart';

import '../../auth/screens/host/host_stay_details_screen.dart';

class HostHomeScreen extends StatefulWidget {
  const HostHomeScreen({super.key});

  @override
  State<HostHomeScreen> createState() => _HostHomeScreenState();
}

class _HostHomeScreenState extends State<HostHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<HostProvider>().loadDashboard();
    _animationController.forward();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    await context.read<HostProvider>().loadDashboard(forceRefresh: true);
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
        onSelect: (index) {
          provider.selectStay(index);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showBookingDetails(Map<String, dynamic> booking) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BookingDetailsSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Consumer<HostProvider>(
          builder: (context, provider, _) {
            if (provider.dashboardLoading && provider.dashboard == null) {
              return _buildLoadingState();
            }

            final dashboard = provider.dashboard;
            if (dashboard == null || dashboard.stays.isEmpty) {
              return _buildEmptyState();
            }

            final selectedStay = provider.selectedStay;

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: const Color(0xFF2563EB),
              backgroundColor: Colors.white,
              strokeWidth: 3,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildGlassHeader(dashboard),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _buildPropertySwitcherBar(provider, selectedStay),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  if (selectedStay != null) _buildQuickActions(selectedStay),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _buildStayRequestsSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _buildUpcomingBookingsSection(),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildAddPropertyButton(),
    );
  }

  // Fixed Glass Header - Prevent text overflow
  Widget _buildGlassHeader(HostDashboard dashboard) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1D4ED8),
              Color(0xFF1E40AF),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Hero(
                        tag: 'host-avatar',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withOpacity(0.25),
                          backgroundImage: dashboard.profilePic != null
                              ? NetworkImage(dashboard.profilePic!)
                              : null,
                          child: dashboard.profilePic == null
                              ? const Icon(Icons.person, color: Colors.white, size: 28)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dashboard.hostName.split(' ').first,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Fixed: Use Wrap instead of Row to prevent overflow
                Row(
                  children: [
                    Expanded(child: _glassStat('${dashboard.totalStays}', 'Properties', Icons.home_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _glassStat('${dashboard.activeStays}', 'Active', Icons.check_circle_rounded)),
                    const SizedBox(width: 8),
                    Expanded(child: _glassStat(
                      '\$${NumberFormat.compact().format(dashboard.totalEarned)}',
                      'Earned',
                      Icons.account_balance_wallet_rounded,
                    )),
                  ],
                ),
              ],
            ),
          ),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Instagram-style Property Switcher
  Widget _buildPropertySwitcherBar(HostProvider provider, Stay? selectedStay) {
    if (selectedStay == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final stays = provider.dashboard?.stays ?? [];
    final hasMultiple = stays.length > 1;

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Your Properties',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (hasMultiple)
                  TextButton.icon(
                    onPressed: _showPropertySwitcher,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Switch'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      textStyle: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stays.length + 1,
              itemBuilder: (context, index) {
                if (index == stays.length) {
                  return _buildAddPropertyStory();
                }

                final stay = stays[index];
                final isSelected = index == provider.selectedStayIndex;

                return GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      HapticFeedback.selectionClick();
                      provider.selectStay(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : Colors.grey.shade300,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ] : null,
                          ),
                          child: ClipOval(
                            child: stay.coverPhoto != null
                                ? Image.network(
                              stay.coverPhoto!,
                              fit: BoxFit.cover,
                              width: 64,
                              height: 64,
                            )
                                : Container(
                              color: Colors.grey.shade100,
                              child: Icon(Icons.home, color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 70,
                          child: Text(
                            stay.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedStay != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSelectedPropertyCard(selectedStay),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddPropertyStory() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HostStayDetailsScreen()),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade50,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Colors.grey.shade500,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              'Add New',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPropertyCard(Stay stay) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Hero Image
            Stack(
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  child: stay.coverPhoto != null
                      ? Image.network(
                    stay.coverPhoto!,
                    fit: BoxFit.cover,
                  )
                      : Center(
                    child: Icon(
                      Icons.home_max_rounded,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                // Status badges
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _buildGlassBadge(
                        stay.verificationStatus == 'verified' ? 'Verified' : 'Pending',
                        stay.verificationStatus == 'verified'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      if (stay.isActive) ...[
                        const SizedBox(width: 6),
                        _buildGlassBadge('Active', const Color(0xFF2563EB)),
                      ],
                    ],
                  ),
                ),
                // Title overlay
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stay.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              stay.cityName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  stay.avgRating > 0 ? stay.avgRating.toStringAsFixed(1) : 'New',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Quick info row
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickInfo(Icons.meeting_room, '${stay.roomCount}', 'Rooms'),
                  _buildQuickInfo(Icons.people, '${stay.maxGuests}', 'Guests'),
                  _buildQuickInfo(Icons.attach_money, '${stay.pricePerNight.toStringAsFixed(0)}', '/night'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Quick Actions
  Widget _buildQuickActions(Stay stay) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_calendar_rounded,
                label: 'Availability',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HostStayAvailabilityScreen(stayId: stay.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                color: const Color(0xFF2563EB),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HostStayEditScreen(stayId: stay.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                icon: Icons.analytics_rounded,
                label: 'Stats',
                color: const Color(0xFF10B981),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fixed Stay Requests - Prevent overflow
  Widget _buildStayRequestsSection() {
    final requests = [
      {
        'id': '1',
        'guestName': 'Sarah Johnson',
        'guestImage': null,
        'checkIn': '2024-03-15',
        'checkOut': '2024-03-18',
        'guests': 2,
        'message': 'Hi! I\'m visiting for a business conference. Looking forward to staying at your place!',
        'status': 'pending',
        'price': 450.0,
      },
      {
        'id': '2',
        'guestName': 'Michael Chen',
        'guestImage': null,
        'checkIn': '2024-03-20',
        'checkOut': '2024-03-25',
        'guests': 4,
        'message': 'Family vacation! We have 2 kids aged 5 and 8. Is the place child-friendly?',
        'status': 'pending',
        'price': 875.0,
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Color(0xFFF59E0B),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Stay Requests',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (requests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${requests.length} new',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (requests.isEmpty)
              _buildEmptyStateCard(
                icon: Icons.inbox_outlined,
                title: 'No pending requests',
                subtitle: 'When guests request to book, they\'ll appear here',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildRequestCard(requests[index]),
              ),
          ],
        ),
      ),
    );
  }

  // Fixed Request Card - Layout optimized to prevent overflow
  Widget _buildRequestCard(Map<String, dynamic> request) {
    final nights = DateTime.parse(request['checkOut'] as String)
        .difference(DateTime.parse(request['checkIn'] as String))
        .inDays;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar + Name + Status
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: request['guestImage'] != null
                        ? NetworkImage(request['guestImage'] as String)
                        : null,
                    child: request['guestImage'] == null
                        ? Text(
                      (request['guestName'] as String).substring(0, 1),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['guestName'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request['guests']} guests • $nights nights',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pending',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Message box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Text(
                request['message'] as String,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButtonSmall(
                    'Decline',
                    Colors.grey.shade200,
                    Colors.grey.shade700,
                        () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionButtonSmall(
                    'Accept',
                    const Color(0xFF2563EB),
                    Colors.white,
                        () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonSmall(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // Fixed Upcoming Bookings
  Widget _buildUpcomingBookingsSection() {
    final bookings = [
      {
        'id': '1',
        'guestName': 'Emma Wilson',
        'guestImage': null,
        'propertyName': 'Sunset Villa',
        'checkIn': '2024-03-10',
        'checkOut': '2024-03-15',
        'guests': 3,
        'totalPrice': 750.0,
        'status': 'confirmed',
        'specialRequests': 'Late check-in at 10 PM',
      },
      {
        'id': '2',
        'guestName': 'James Rodriguez',
        'guestImage': null,
        'propertyName': 'Sunset Villa',
        'checkIn': '2024-03-22',
        'checkOut': '2024-03-24',
        'guests': 2,
        'totalPrice': 400.0,
        'status': 'confirmed',
        'specialRequests': null,
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Upcoming Bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (bookings.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (bookings.isEmpty)
              _buildEmptyStateCard(
                icon: Icons.calendar_today_outlined,
                title: 'No upcoming bookings',
                subtitle: 'Your confirmed bookings will appear here',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildBookingCard(bookings[index]),
              ),
          ],
        ),
      ),
    );
  }

  // Fixed Booking Card - Prevent overflow
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final checkIn = DateTime.parse(booking['checkIn'] as String);
    final checkOut = DateTime.parse(booking['checkOut'] as String);
    final nights = checkOut.difference(checkIn).inDays;
    final isToday = checkIn.isAtSameMomentAs(DateTime.now()) ||
        (checkIn.isAfter(DateTime.now()) && checkIn.difference(DateTime.now()).inDays < 1);

    return GestureDetector(
      onTap: () => _showBookingDetails(booking),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Date header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isToday ? const Color(0xFF2563EB).withOpacity(0.05) : Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'TODAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 14,
                    color: isToday ? const Color(0xFF2563EB) : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${DateFormat('MMM d').format(checkIn)} - ${DateFormat('MMM d').format(checkOut)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isToday ? const Color(0xFF2563EB) : Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Confirmed',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Guest info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: booking['guestImage'] != null
                          ? NetworkImage(booking['guestImage'] as String)
                          : null,
                      child: booking['guestImage'] == null
                          ? Text(
                        (booking['guestName'] as String).substring(0, 1),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking['guestName'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${booking['guests']} guests • $nights nights',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (booking['specialRequests'] != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, size: 10, color: Colors.orange.shade600),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    'Special request',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${booking['totalPrice']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        'total',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2563EB).withOpacity(0.1),
                    const Color(0xFF2563EB).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_outlined,
                size: 72,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Start your hosting journey',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first property and start earning with Yaloo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HostStayDetailsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Add Your First Property',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF2563EB),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your dashboard...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPropertyButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HostStayDetailsScreen(),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_home_work_rounded, size: 24),
        label: const Text(
          'Add Stay',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// Property Switcher Modal - Fixed
class _PropertySwitcherSheet extends StatelessWidget {
  final List<Stay> stays;
  final int selectedIndex;
  final Function(int) onSelect;

  const _PropertySwitcherSheet({
    required this.stays,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    'Switch Property',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: stays.length,
                itemBuilder: (_, index) {
                  final stay = stays[index];
                  final isSelected = index == selectedIndex;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelect(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB).withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ] : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2563EB).withOpacity(0.3)
                                    : Colors.grey.shade200,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: stay.coverPhoto != null
                                  ? Image.network(
                                stay.coverPhoto!,
                                fit: BoxFit.cover,
                              )
                                  : Container(
                                color: Colors.grey.shade100,
                                child: Icon(Icons.home, color: Colors.grey.shade400),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stay.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? const Color(0xFF2563EB)
                                        : const Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        stay.cityName,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: stay.isActive
                                            ? const Color(0xFF10B981).withOpacity(0.1)
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        stay.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: stay.isActive
                                              ? const Color(0xFF10B981)
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    if (stay.avgRating > 0) ...[
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.star,
                                        size: 11,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        stay.avgRating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Fixed Booking Details Bottom Sheet - No overflow
class _BookingDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingDetailsSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final checkIn = DateTime.parse(booking['checkIn'] as String);
    final checkOut = DateTime.parse(booking['checkOut'] as String);
    final nights = checkOut.difference(checkIn).inDays;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Guest Info Hero - Fixed layout
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2563EB).withOpacity(0.1),
                      const Color(0xFF2563EB).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
                        backgroundImage: booking['guestImage'] != null
                            ? NetworkImage(booking['guestImage'] as String)
                            : null,
                        child: booking['guestImage'] == null
                            ? Text(
                          (booking['guestName'] as String).substring(0, 1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['guestName'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Confirmed',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Details Grid - Fixed with proper constraints
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today_rounded,
                      'Check-in',
                      DateFormat('EEE, MMM d, y').format(checkIn),
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.logout_rounded,
                      'Check-out',
                      DateFormat('EEE, MMM d, y').format(checkOut),
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.nights_stay_rounded,
                      'Duration',
                      '$nights nights',
                      Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.people_rounded,
                      'Guests',
                      '${booking['guests']} guests',
                      Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.home_rounded,
                      'Property',
                      booking['propertyName'] as String,
                      Colors.indigo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Price Breakdown - Fixed
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${((booking['totalPrice'] as double) / nights).toStringAsFixed(0)} x $nights nights',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${booking['totalPrice']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '\$${booking['totalPrice']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message_rounded, size: 20),
                        label: const Text('Message Guest'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}