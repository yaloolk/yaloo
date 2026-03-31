// lib/features/tourist/screens/tourist_profile_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:yaloo/core/storage/secure_storage.dart';
import '../models/tourist_models.dart';
import '../providers/tourist_provider.dart';

class TouristProfileScreen extends StatefulWidget {
  const TouristProfileScreen({super.key});
  @override
  State<TouristProfileScreen> createState() => _TouristProfileScreenState();
}

class _TouristProfileScreenState extends State<TouristProfileScreen> {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _loadData();
    });
  }

  Future<void> _loadData({bool force = false}) async {
    if (!mounted) return;
    final p = context.read<TouristProvider>();
    await Future.wait([
      p.loadProfile(forceRefresh: force),
      p.loadInterests(),
      p.loadStats(),
    ]);
  }

  // PHOTO UPLOAD
  Future<void> _pickAndUploadPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (source == null || !mounted) return;
    final xfile = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (xfile == null || !mounted) return;
    try {
      await context.read<TouristProvider>().uploadProfilePicture(xfile);
      if (mounted) _snack('Profile picture updated!', Colors.green);
    } catch (e) {
      if (mounted) _snack('Upload failed: $e', Colors.red);
    }
  }

  // BIO EDIT
  Future<void> _openEditBio(TouristProfile profile) async {
    final ctrl = TextEditingController(text: profile.profileBio);
    final result = await showModalBottomSheet<String>(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _EditBioSheet(controller: ctrl),
    );
    if (result != null && mounted) {
      try {
        await context.read<TouristProvider>().updateBio(result);
        if (mounted) _snack('Bio updated!', Colors.green);
      } catch (e) {
        if (mounted) _snack('Failed to update bio', Colors.red);
      }
    }
  }

  // INTERESTS EDIT
  Future<void> _openEditInterests() async {
    final provider = context.read<TouristProvider>();
    await provider.loadMasterInterests();
    if (!mounted) return;
    await showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider, child: const _EditInterestsSheet(),
      ),
    );
  }

  void _goToPersonalInfo() {
    Navigator.pushNamed(context, '/personalInformation').then((_) => _loadData(force: true));
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();
    final confirm = await showModalBottomSheet<bool>(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => const _LogoutSheet(),
    );

    if (confirm != true || !mounted) return;

    try {
      // 1. Delete the access token
      await SecureStorage().deleteAccessToken();

      if (mounted) {
        // 2. Clear the user data from the provider
        context.read<TouristProvider>().clear();

        // 3. Clear the navigation stack and go to login (REPLACED HERE)
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/login',
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) _snack('Logout failed: $e', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<TouristProvider>(
        builder: (context, provider, _) {
          if (provider.profile != null) {
            return RefreshIndicator(
              onRefresh: () => _loadData(force: true),
              color: const Color(0xFF2563EB),
              child: _buildBody(provider),
            );
          }
          if (provider.profileLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Failed to load profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadData, child: const Text('Retry')),
          ]));
        },
      ),
    );
  }

  Widget _buildBody(TouristProvider provider) {
    final profile = provider.profile!;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildHeader(provider, profile), _g(20),
        _buildStats(provider), _g(20),
        _buildQuickActions(profile), _g(20),
        _buildAbout(profile), _g(16),
        _buildInterests(provider), _g(16),
        _buildLanguages(provider), _g(16),
        _buildContactInfo(profile), _g(16),
        _buildTravelPrefs(profile),
        if (profile.emergencyContactName.isNotEmpty) ...[_g(16), _buildEmergency(profile)],
        _g(24), _buildLogoutBtn(), _g(48),
      ],
    );
  }

  SliverToBoxAdapter _g(double h) => SliverToBoxAdapter(child: SizedBox(height: h));

  Widget _buildHeader(TouristProvider provider, TouristProfile profile) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8), Color(0xFF1E40AF)]),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.38), blurRadius: 32, offset: const Offset(0, 14), spreadRadius: -6)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 52, 24, 32),
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.14), Colors.white.withOpacity(0.04)])),
              child: Column(children: [
                Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.45), width: 4),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.22), blurRadius: 24, offset: const Offset(0, 8))]),
                    child: CircleAvatar(
                      radius: 64,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: profile.profilePic.isNotEmpty ? NetworkImage(profile.profilePic) : null,
                      child: profile.profilePic.isEmpty
                          ? Text(profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'T',
                          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w800, color: Colors.white))
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: provider.isUploadingPhoto ? null : _pickAndUploadPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2563EB), width: 2.5),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 3))]),
                      child: provider.isUploadingPhoto
                          ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2563EB)))
                          : const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB), size: 18),
                    ),
                  ),
                ]),
                const SizedBox(height: 18),
                Text(profile.fullName.isEmpty ? 'Traveler' : profile.fullName,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6),
                    textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.travel_explore, color: Colors.amber, size: 20), const SizedBox(width: 7),
                    Text('Traveler', style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 14, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(TouristProvider provider) {
    final s = provider.stats ?? {};
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: Row(children: [
          Expanded(child: _sc('${s['total_trips'] ?? 0}', 'Trips', Icons.flight_takeoff, const Color(0xFF8B5CF6))),
          const SizedBox(width: 12),
          Expanded(child: _sc('${s['languages_count'] ?? 0}', 'Languages', Icons.language, const Color(0xFF10B981))),
          const SizedBox(width: 12),
          Expanded(child: _sc('${provider.interests.length}', 'Interests', Icons.favorite, const Color(0xFFF59E0B))),
        ])));
  }

  Widget _sc(String v, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6), spreadRadius: -4)]),
      child: Column(children: [
        Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22)),
        const SizedBox(height: 8),
        Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildQuickActions(TouristProfile profile) {
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: Container(
          padding: const EdgeInsets.all(16), decoration: _card(),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _qb(Icons.edit_note_rounded, 'Edit Info', const Color(0xFF2563EB), _goToPersonalInfo),
            _qb(Icons.favorite_border_rounded, 'Interests', const Color(0xFFEC4899), _openEditInterests),
            _qb(Icons.notes_rounded, 'About Me', const Color(0xFF8B5CF6), () => _openEditBio(profile)),
            _qb(Icons.settings_rounded, 'Settings', const Color(0xFF6B7280), () => Navigator.pushNamed(context, '/settings')),
          ]),
        )));
  }

  Widget _qb(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Column(children: [
      Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 24)),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
    ]));
  }

  Widget _buildAbout(TouristProfile profile) {
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _sec(
          icon: Icons.person_outline_rounded, iconColor: const Color(0xFF2563EB),
          title: 'About Me', onEdit: () => _openEditBio(profile),
          child: Text(
            profile.profileBio.isEmpty ? 'Tap the edit button to write about yourself and your travel style.' : profile.profileBio,
            style: TextStyle(fontSize: 15, height: 1.7,
                color: profile.profileBio.isEmpty ? Colors.grey.shade400 : const Color(0xFF374151),
                fontStyle: profile.profileBio.isEmpty ? FontStyle.italic : FontStyle.normal),
          ),
        )));
  }

  Widget _buildInterests(TouristProvider provider) {
    final interests = provider.interests;
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _sec(
          icon: Icons.favorite_rounded, iconColor: const Color(0xFFEC4899),
          title: 'Interests', onEdit: _openEditInterests,
          child: provider.interestsLoading
              ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
              : interests.isEmpty
              ? Text('No interests yet. Tap the edit button to add some!',
              style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic))
              : Wrap(spacing: 8, runSpacing: 8,
              children: interests.map((i) => _chip(i!.name, const Color(0xFFEC4899))).toList()),
        )));
  }

  Widget _buildLanguages(TouristProvider provider) {
    final langs = (provider.stats ?? {})['languages'] as List<dynamic>? ?? [];
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _sec(
          icon: Icons.language_rounded, iconColor: const Color(0xFF06B6D4),
          title: 'Languages', onEdit: _goToPersonalInfo,
          child: langs.isEmpty
              ? Text('No languages added. Tap the edit button.', style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic))
              : Wrap(spacing: 8, runSpacing: 8,
              children: langs.map<Widget>((l) {
                final name = l['name'] as String? ?? '';
                final isNative = l['is_native'] as bool? ?? false;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.1), borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF06B6D4).withOpacity(0.25))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.language_rounded, size: 13, color: Color(0xFF06B6D4)), const SizedBox(width: 5),
                    Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF06B6D4))),
                    if (isNative) ...[
                      const SizedBox(width: 6),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Native', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
                    ],
                  ]),
                );
              }).toList()),
        )));
  }

  Widget _buildContactInfo(TouristProfile profile) {
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _sec(
          icon: Icons.contact_mail_rounded, iconColor: const Color(0xFF8B5CF6),
          title: 'Contact Information', onEdit: _goToPersonalInfo,
          child: Column(children: [
            _ir(Icons.phone_rounded, 'Phone', profile.phoneNumber.isEmpty ? 'Not added' : profile.phoneNumber, Colors.green),
            const Divider(height: 22),
            _ir(Icons.public_rounded, 'Country', profile.country.isEmpty ? 'Not specified' : profile.country, Colors.orange),
            const Divider(height: 22),
            _ir(Icons.cake_rounded, 'Date of Birth', profile.dateOfBirth.isEmpty ? 'Not added' : profile.dateOfBirth, Colors.pink),
            const Divider(height: 22),
            _ir(Icons.wc_rounded, 'Gender', profile.gender.isEmpty ? 'Not specified' : profile.gender, Colors.purple),
          ]),
        )));
  }

  Widget _ir(IconData icon, String label, String value, Color color) {
    final empty = value.startsWith('Not');
    return Row(children: [
      Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
            color: empty ? Colors.grey.shade400 : const Color(0xFF1F2937))),
      ])),
    ]);
  }

  Widget _buildTravelPrefs(TouristProfile profile) {
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _sec(
          icon: Icons.airplanemode_active_rounded, iconColor: const Color(0xFFF59E0B),
          title: 'Travel Preferences',
          child: Column(children: [
            _pr('Travel Style', profile.travelStyle.isEmpty ? 'Not set' : profile.travelStyle),
            if (profile.passportNumber.isNotEmpty) ...[
              const Divider(height: 16),
              _pr('Passport', profile.passportNumber.length >= 4
                  ? '${String.fromCharCodes(List.filled(6, 0x2022))}${profile.passportNumber.substring(profile.passportNumber.length - 4)}'
                  : '${String.fromCharCodes(List.filled(6, 0x2022))}'),
            ],
          ]),
        )));
  }

  Widget _buildEmergency(TouristProfile profile) {
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: _sec(
          icon: Icons.emergency_rounded, iconColor: const Color(0xFFEF4444),
          title: 'Emergency Contact', onEdit: _goToPersonalInfo,
          child: Column(children: [
            _pr('Name', profile.emergencyContactName),
            if (profile.emergencyContactRelation.isNotEmpty) ...[const Divider(height: 16), _pr('Relation', profile.emergencyContactRelation)],
            if (profile.emergencyContactNumber.isNotEmpty) ...[const Divider(height: 16), _pr('Phone', profile.emergencyContactNumber)],
          ]),
        )));
  }

  Widget _pr(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937))),
      ]));

  Widget _buildLogoutBtn() {
    return SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: GestureDetector(
          onTap: _handleLogout,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.08), borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20), SizedBox(width: 10),
              Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontSize: 16, fontWeight: FontWeight.w700)),
            ]),
          ),
        )));
  }

  Widget _sec({required IconData icon, required Color iconColor, required String title, required Widget child, VoidCallback? onEdit}) {
    return Container(padding: const EdgeInsets.all(20), decoration: _card(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1F2937)))),
            if (onEdit != null)
              GestureDetector(onTap: onEdit, child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.edit_rounded, color: Color(0xFF2563EB), size: 17))),
          ]),
          const SizedBox(height: 16),
          child,
        ]));
  }

  Widget _chip(String name, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.favorite_rounded, size: 13, color: color), const SizedBox(width: 5),
        Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
      ]));

  BoxDecoration _card() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 16, offset: const Offset(0, 4))]);
}

// PHOTO SOURCE SHEET
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Change Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
            const SizedBox(height: 20),
            _t(context, Icons.photo_library_rounded, 'Choose from Gallery', const Color(0xFF2563EB), ImageSource.gallery),
            const SizedBox(height: 12),
            _t(context, Icons.camera_alt_rounded, 'Take a Photo', const Color(0xFF10B981), ImageSource.camera),
            const SizedBox(height: 8),
          ]))),
    );
  }
  Widget _t(BuildContext ctx, IconData icon, String label, Color color, ImageSource src) {
    return GestureDetector(onTap: () => Navigator.pop(ctx, src),
        child: Container(padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 16),
              Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
            ])));
  }
}

// EDIT BIO SHEET
class _EditBioSheet extends StatelessWidget {
  final TextEditingController controller;
  const _EditBioSheet({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            child: SafeArea(child: Padding(padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Edit About Me', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close_rounded, color: Colors.grey.shade500)),
                  ]),
                  const SizedBox(height: 16),
                  Container(padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3))),
                      child: TextField(controller: controller, maxLines: 5, autofocus: true,
                          decoration: InputDecoration(hintText: 'Tell other travelers about yourself and your travel style...',
                              border: InputBorder.none, hintStyle: TextStyle(color: Colors.grey.shade400, height: 1.6)),
                          style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF1F2937)))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, controller.text.trim()),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                    child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  )),
                ])))));
  }
}

// EDIT INTERESTS SHEET
class _EditInterestsSheet extends StatefulWidget {
  const _EditInterestsSheet();
  @override
  State<_EditInterestsSheet> createState() => _EditInterestsSheetState();
}
class _EditInterestsSheetState extends State<_EditInterestsSheet> {
  final _sc = TextEditingController();
  String _q = '';
  @override
  void dispose() { _sc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Consumer<TouristProvider>(
        builder: (context, provider, _) {
          final master = provider.masterInterests;
          final selIds = provider.interests.map((i) => i.id).toSet();
          final filtered = _q.isEmpty ? master : master.where((i) => i.name.toLowerCase().contains(_q.toLowerCase())).toList();
          return DraggableScrollableSheet(initialChildSize: 0.87, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
              builder: (_, sc2) => Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                  child: Column(children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text('Edit Interests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFEC4899).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: Text('${provider.interests.length} selected',
                                  style: const TextStyle(color: Color(0xFFEC4899), fontWeight: FontWeight.w700, fontSize: 13))),
                        ])),
                    const SizedBox(height: 14),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(controller: _sc, onChanged: (v) => setState(() => _q = v),
                            decoration: InputDecoration(hintText: 'Search interests...',
                                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                                filled: true, fillColor: const Color(0xFFF3F4F6),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12)))),
                    const SizedBox(height: 12),
                    Expanded(child: master.isEmpty
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
                        : filtered.isEmpty
                        ? Center(child: Text('No results for "$_q"', style: TextStyle(color: Colors.grey.shade500)))
                        : ListView.builder(controller: sc2, padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          final isSel = selIds.contains(item.id);
                          return Container(margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                  color: isSel ? const Color(0xFFEC4899).withOpacity(0.07) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isSel ? const Color(0xFFEC4899).withOpacity(0.35) : Colors.transparent, width: 1.5)),
                              child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600,
                                      color: isSel ? const Color(0xFFEC4899) : const Color(0xFF1F2937))),
                                  subtitle: Text(item.category, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                  trailing: AnimatedSwitcher(duration: const Duration(milliseconds: 200),
                                      child: isSel
                                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFFEC4899), key: ValueKey('on'))
                                          : Icon(Icons.add_circle_outline_rounded, color: Colors.grey.shade400, key: const ValueKey('off'))),
                                  onTap: () async {
                                    try {
                                      if (isSel) { await provider.removeInterest(item); } else { await provider.addInterest(item); }
                                    } catch (_) {
                                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to update interest'), backgroundColor: Colors.red));
                                    }
                                  }));
                        })),
                    SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: SizedBox(width: double.infinity, child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                            child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)))))),
                  ])));
        });
  }
}

// LOGOUT SHEET
class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 48, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3))),
              const SizedBox(height: 24),
              Container(padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 40)),
              const SizedBox(height: 20),
              const Text('Logout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
              const SizedBox(height: 8),
              Text('Are you sure you want to logout?', style: TextStyle(fontSize: 15, color: Colors.grey.shade600), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: GestureDetector(onTap: () => Navigator.pop(context, false),
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
                        child: Center(child: Text('Cancel', style: TextStyle(color: Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.w700)))))),
                const SizedBox(width: 12),
                Expanded(child: GestureDetector(onTap: () => Navigator.pop(context, true),
                    child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]),
                        child: const Center(child: Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)))))),
              ]),
              const SizedBox(height: 8),
            ]))));
  }
}