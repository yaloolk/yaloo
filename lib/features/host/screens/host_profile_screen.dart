// lib/features/host/screens/host_profile_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:yaloo/features/host/providers/host_provider.dart';
import 'package:yaloo/features/host/models/host_models.dart';
import 'package:yaloo/features/host/screens/host_edit_profile_screen.dart';
import 'package:yaloo/features/host/screens/host_gallery_screen.dart';
import 'package:yaloo/core/storage/secure_storage.dart';

class HostProfileScreen extends StatefulWidget {
  const HostProfileScreen({super.key});

  @override
  State<HostProfileScreen> createState() => _HostProfileScreenState();
}

class _HostProfileScreenState extends State<HostProfileScreen> {
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final provider = context.read<HostProvider>();
    await Future.wait([
      provider.loadProfile(forceRefresh: true),
      provider.loadLanguages(),
    ]);
  }

  // ─────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────
  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogoutSheet(),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isLoggingOut = true);
    try {
      await SecureStorage().deleteAccessToken();
      if (mounted) context.read<HostProvider>().clear();
      if (mounted) Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (_) {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // EDIT BIO (inline sheet)
  // ─────────────────────────────────────────────────────────
  void _showEditBio(HostProfile profile) {
    final ctrl = TextEditingController(text: profile.profileBio);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Edit Bio',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 4),
                Text('Tell guests what makes you a great host', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 16),
                TextField(
                  controller: ctrl,
                  maxLines: 5,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Write something about yourself…',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                      setSheetState(() => saving = true);
                      final ok = await context.read<HostProvider>().updateProfile({'profile_bio': ctrl.text.trim()});
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'Bio updated!' : 'Update failed'),
                          backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Bio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ADD LANGUAGE
  // ─────────────────────────────────────────────────────────
  void _showAddLanguage() {
    final provider = context.read<HostProvider>();
    final allLangs = provider.languages;
    final profileLangs = provider.profile?.languages ?? [];
    final addedIds = profileLangs.map((l) => l.languageId).toSet();
    final available = allLangs.where((l) => !addedIds.contains(l.id)).toList();

    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All available languages already added')),
      );
      return;
    }

    Language? selectedLang;
    String selectedProficiency = 'native';
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Add Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                const SizedBox(height: 20),
                // Language dropdown
                DropdownButtonFormField<Language>(
                  value: selectedLang,
                  hint: const Text('Select language'),
                  items: available.map((l) => DropdownMenuItem(value: l, child: Text(l.name))).toList(),
                  onChanged: (v) => setSheetState(() => selectedLang = v),
                  decoration: InputDecoration(
                    labelText: 'Language',
                    prefixIcon: Icon(Icons.language, color: Colors.grey.shade400, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),
                // Proficiency selector
                const Text('Proficiency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 10),
                Row(
                  children: ['basic', 'conversational', 'native'].map((p) {
                    final selected = selectedProficiency == p;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedProficiency = p),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF2563EB) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _capitalise(p),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (selectedLang == null || saving)
                        ? null
                        : () async {
                      setSheetState(() => saving = true);
                      final ok = await context.read<HostProvider>().addLanguage(
                        selectedLang!.id,
                        selectedProficiency,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(ok ? 'Language added!' : 'Failed to add language'),
                          backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Add Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // REMOVE LANGUAGE
  // ─────────────────────────────────────────────────────────
  Future<void> _confirmRemoveLanguage(UserLanguage lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Language', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Remove ${lang.name} from your profile?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final ok = await context.read<HostProvider>().removeLanguage(lang.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? '${lang.name} removed' : 'Failed to remove'),
        backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────
  // UPDATE LANGUAGE PROFICIENCY
  // ─────────────────────────────────────────────────────────
  void _showUpdateProficiency(UserLanguage lang) {
    String selectedProficiency = lang.proficiency;
    bool saving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('${lang.name} Proficiency', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
              const SizedBox(height: 20),
              Row(
                children: ['basic', 'conversational', 'native'].map((p) {
                  final sel = selectedProficiency == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setSheetState(() => selectedProficiency = p),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF2563EB) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _capitalise(p),
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : Colors.grey.shade700),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                        setSheetState(() => saving = true);
                        final ok = await context.read<HostProvider>().updateLanguage(lang.id, selectedProficiency);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ok ? 'Proficiency updated!' : 'Update failed'),
                            backgroundColor: ok ? const Color(0xFF10B981) : Colors.red,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Update', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalise(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  void _goToEditProfile() {
    HapticFeedback.mediumImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const HostEditProfileScreen()))
        .then((_) => _loadData());
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoggingOut) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<HostProvider>(
        builder: (context, provider, _) {
          if (provider.profileLoading && provider.profile == null) {
            return _buildLoadingState();
          }
          final profile = provider.profile;
          if (profile == null) return _buildErrorState();

          return RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFF2563EB),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildHeader(profile),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                _buildStats(profile),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                _buildQuickActions(),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                _buildAboutSection(profile),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildLanguagesSection(profile),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildContactSection(profile),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildVerificationSection(profile),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildGalleryTile(),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                _buildSettingsSection(),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                _buildLogoutButton(),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeader(HostProfile profile) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)],
          ),
          borderRadius: BorderRadius.circular(32),
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
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10))],
                      ),
                      child: Hero(
                        tag: 'profile-avatar',
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: profile.profilePic.isNotEmpty ? NetworkImage(profile.profilePic) : null,
                          child: profile.profilePic.isEmpty
                              ? Text(
                            profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'H',
                            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white),
                          )
                              : null,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _goToEditProfile,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 2.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const Icon(Icons.camera_alt, color: Color(0xFF2563EB), size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  profile.fullName.isEmpty ? 'Host' : profile.fullName,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        profile.avgRating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 14, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 8),
                      Text(
                        'Host since ${profile.memberSince}',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildVerificationBadge(profile.verificationStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case 'verified':
        color = const Color(0xFF10B981);
        icon = Icons.verified;
        label = 'Verified Host';
        break;
      case 'rejected':
        color = const Color(0xFFEF4444);
        icon = Icons.cancel;
        label = 'Verification Rejected';
        break;
      default:
        color = const Color(0xFFF59E0B);
        icon = Icons.pending_actions;
        label = 'Verification Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STATS
  // ─────────────────────────────────────────────────────────
  Widget _buildStats(HostProfile profile) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _statCard('${profile.noOfStaysOwned}', 'Properties', Icons.home_work_rounded, const Color(0xFF8B5CF6))),
                const SizedBox(width: 12),
                Expanded(child: _statCard('${profile.totalCompletedBookings}', 'Bookings', Icons.event_available_rounded, const Color(0xFF10B981))),
                const SizedBox(width: 12),
                Expanded(child: _statCard('\$${NumberFormat.compact().format(profile.totalEarned)}', 'Earned', Icons.account_balance_wallet_rounded, const Color(0xFFF59E0B))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard(profile.avgRating.toStringAsFixed(1), 'Rating', Icons.star_rounded, const Color(0xFFEC4899))),
                const SizedBox(width: 12),
                Expanded(child: _statCard('${profile.languages.length}', 'Languages', Icons.language_rounded, const Color(0xFF06B6D4))),
                const SizedBox(width: 12),
                Expanded(child: _statCard('${profile.noOfStaysOwned}', 'Active', Icons.toggle_on_rounded, const Color(0xFF84CC16))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickAction(Icons.edit_note_rounded, 'Edit Profile', const Color(0xFF2563EB), _goToEditProfile),
              _quickAction(Icons.photo_library_rounded, 'Gallery', const Color(0xFF8B5CF6), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HostGalleryScreen()));
              }),
              _quickAction(Icons.language_rounded, 'Languages', const Color(0xFF06B6D4), _showAddLanguage),
              _quickAction(Icons.bar_chart_rounded, 'Analytics', const Color(0xFFF59E0B), () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 7),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // ABOUT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildAboutSection(HostProfile profile) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('About Me', Icons.person_outline, const Color(0xFF2563EB), onEdit: () => _showEditBio(profile)),
              const SizedBox(height: 14),
              profile.profileBio.isEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell guests what makes your hosting special — your hosting style, local knowledge, or what makes you unique.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500, height: 1.6, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => _showEditBio(profile),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Color(0xFF2563EB), size: 18),
                          SizedBox(width: 8),
                          Text('Add Bio', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Text(profile.profileBio, style: const TextStyle(fontSize: 15, color: Color(0xFF374151), height: 1.7)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // LANGUAGES SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildLanguagesSection(HostProfile profile) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Languages', Icons.language_rounded, const Color(0xFF06B6D4), onAdd: _showAddLanguage),
              const SizedBox(height: 16),
              if (profile.languages.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        Icon(Icons.language, size: 48, color: Colors.grey.shade200),
                        const SizedBox(height: 10),
                        Text('No languages added yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _showAddLanguage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF06B6D4).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.25)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Color(0xFF06B6D4), size: 16),
                                SizedBox(width: 6),
                                Text('Add Language', style: TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...profile.languages.map((lang) => _langChip(lang)),
                    // "Add more" chip
                    GestureDetector(
                      onTap: _showAddLanguage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF06B6D4).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.25), style: BorderStyle.solid),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: const Color(0xFF06B6D4), size: 16),
                            const SizedBox(width: 4),
                            Text('Add', style: TextStyle(color: const Color(0xFF06B6D4), fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langChip(UserLanguage lang) {
    Color profColor;
    switch (lang.proficiency) {
      case 'native':
        profColor = const Color(0xFF10B981);
        break;
      case 'conversational':
        profColor = const Color(0xFFF59E0B);
        break;
      default:
        profColor = const Color(0xFF8B5CF6);
    }

    return GestureDetector(
      onTap: () => _showUpdateProficiency(lang),
      onLongPress: () => _confirmRemoveLanguage(lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF2563EB).withOpacity(0.08),
            const Color(0xFF2563EB).withOpacity(0.04),
          ]),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 14, color: Color(0xFF2563EB)),
            const SizedBox(width: 6),
            Text(lang.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2563EB))),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: profColor, borderRadius: BorderRadius.circular(6)),
              child: Text(
                _capitalise(lang.proficiency),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 12, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // CONTACT SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildContactSection(HostProfile profile) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('Personal Details', Icons.contact_mail_outlined, const Color(0xFF8B5CF6), onEdit: _goToEditProfile),
              const SizedBox(height: 18),
              _contactRow(Icons.phone_outlined, 'Phone', profile.phoneNumber.isEmpty ? 'Not added' : profile.phoneNumber, Colors.green),
              const Divider(height: 22),
              _contactRow(Icons.public_outlined, 'Country', profile.country.isEmpty ? 'Not specified' : profile.country, Colors.orange),
              const Divider(height: 22),
              _contactRow(Icons.cake_outlined, 'Date of Birth', profile.dateOfBirth.isEmpty ? 'Not added' : profile.dateOfBirth, Colors.pink),
              const Divider(height: 22),
              _contactRow(Icons.wc_outlined, 'Gender', profile.gender.isEmpty ? 'Not specified' : _capitalise(profile.gender), Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value, Color color) {
    final isEmpty = value.contains('Not');
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isEmpty ? Colors.grey.shade400 : const Color(0xFF1F2937),
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _goToEditProfile,
          child: Icon(Icons.edit_outlined, size: 16, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // VERIFICATION
  // ─────────────────────────────────────────────────────────
  Widget _buildVerificationSection(HostProfile profile) {
    final isVerified = profile.verificationStatus == 'verified';
    final isRejected = profile.verificationStatus == 'rejected';
    final color = isVerified ? const Color(0xFF10B981) : (isRejected ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.08), color.withOpacity(0.04)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                child: Icon(isVerified ? Icons.verified_user : (isRejected ? Icons.cancel : Icons.pending_actions), color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVerified ? 'Verified Host' : (isRejected ? 'Verification Rejected' : 'Verification Pending'),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVerified
                          ? 'Your account is fully verified. Guests trust you!'
                          : (isRejected ? 'Your verification was rejected. Contact support.' : 'Verification is in progress. We\'ll notify you soon.'),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // GALLERY TILE
  // ─────────────────────────────────────────────────────────
  Widget _buildGalleryTile() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HostGalleryScreen())),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFFEC4899).withOpacity(0.2),
                      const Color(0xFF8B5CF6).withOpacity(0.2),
                    ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF8B5CF6), size: 26),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Photo Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                      SizedBox(height: 3),
                      Text('Manage property photos', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.arrow_forward_ios, color: Color(0xFF2563EB), size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SETTINGS
  // ─────────────────────────────────────────────────────────
  Widget _buildSettingsSection() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
              const SizedBox(height: 16),
              _settingTile(Icons.notifications_outlined, 'Notifications', 'Manage alerts & reminders', () {}),
              const Divider(height: 18),
              _settingTile(Icons.security_outlined, 'Security', 'Password & two-factor auth', () {}),
              const Divider(height: 18),
              _settingTile(Icons.payments_outlined, 'Payment Methods', 'Manage payouts & banking', () {}),
              const Divider(height: 18),
              _settingTile(Icons.help_outline, 'Help & Support', 'Get assistance anytime', () { Navigator.pushNamed(context, '/helpSupport'); }),
              const Divider(height: 18),
              _settingTile(Icons.policy_outlined, 'Terms & Privacy', 'View policies', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, size: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: _handleLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 10),
                Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
  );

  Widget _sectionHeader(String title, IconData icon, Color color, {VoidCallback? onEdit, VoidCallback? onAdd}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
          ],
        ),
        if (onEdit != null)
          GestureDetector(
            onTap: onEdit,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.edit, size: 16, color: color),
            ),
          )
        else if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.add, size: 16, color: color),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
            child: const CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          Text('Loading profile…', style: TextStyle(fontSize: 15, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Failed to load profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// LOGOUT SHEET
// ─────────────────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Logout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
              const SizedBox(height: 8),
              Text('Are you sure you want to sign out?', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                        child: Center(
                          child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700, fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: const Center(
                          child: Text('Sign Out', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}