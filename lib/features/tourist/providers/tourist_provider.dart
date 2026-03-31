// tourist_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/tourist_api_service.dart';
import '../models/tourist_models.dart';

class TouristProvider extends ChangeNotifier {
  final TouristApiService _api = TouristApiService();

  // ── Profile ────────────────────────────────────────────────────────────────
  TouristProfile? _profile;
  TouristProfile? get profile => _profile;

  bool _profileLoading = false;
  bool get profileLoading => _profileLoading;           // used in screen

  String? _profileError;
  String? get profileError => _profileError;

  // ── Interests ──────────────────────────────────────────────────────────────
  // Screen accesses: provider.interests  (List<Interest>)
  List<Interest> _interests = [];
  List<Interest> get interests => List.unmodifiable(_interests);

  // Full catalogue for the picker modal
  List<Interest> _masterInterests = [];
  List<Interest> get masterInterests => List.unmodifiable(_masterInterests);
  bool _masterInterestsLoaded = false;

  bool _interestsLoading = false;
  bool get interestsLoading => _interestsLoading;

  String? _interestError;
  String? get interestError => _interestError;

  // ── Stats ──────────────────────────────────────────────────────────────────
  // Screen accesses: provider.stats  (Map<String, dynamic>?)
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? get stats => _stats;

  bool _statsLoading = false;
  bool get statsLoading => _statsLoading;

  String? _statsError;
  String? get statsError => _statsError;

  // ── Upload state ───────────────────────────────────────────────────────────
  bool _isUploadingPhoto = false;
  bool get isUploadingPhoto => _isUploadingPhoto;

  // ── Convenience ───────────────────────────────────────────────────────────
  String get fullName => _profile?.fullName ?? '';
  String? get profilePicUrl => _profile?.profilePic;
  String get email =>
      Supabase.instance.client.auth.currentUser?.email ?? '';

  // True only when ALL three sections are done (useful for skeleton screens).
  bool get isFullyLoaded =>
      !_profileLoading && !_interestsLoading && !_statsLoading;

  // ═══════════════════════════════════════════════════════════════════════════
  // LOAD ALL  –  called from _loadData() in the screen
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fires profile, interests and stats in parallel, each section
  /// triggers its own notifyListeners() independently so the UI
  /// can paint each card as soon as its data arrives.
  Future<void> loadAll({bool forceRefresh = false}) async {
    await Future.wait([
      loadProfile(forceRefresh: forceRefresh),
      loadInterests(),
      loadStats(),
    ]);
  }

  // ── Profile ────────────────────────────────────────────────────────────────

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_profileLoading) return;
    if (_profile != null && !forceRefresh) return;

    _profileLoading = true;
    _profileError = null;
    notifyListeners();

    try {
      final data = await _api.getProfile();
      _profile = TouristProfile.fromJson(data);
      _profileError = null;
    } catch (e) {
      _profileError = _friendlyError(e);
      debugPrint('TouristProvider.loadProfile: $e');
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  // ── Interests ──────────────────────────────────────────────────────────────

  /// Called as provider.loadInterests() from the screen.
  Future<void> loadInterests() async {
    if (_interestsLoading) return;

    _interestsLoading = true;
    _interestError = null;
    notifyListeners();

    try {
      final raw = await _api.getUserInterests();
      _interests = raw
          .map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList();
      _interestError = null;
    } catch (e) {
      _interestError = _friendlyError(e);
      debugPrint('TouristProvider.loadInterests: $e');
    } finally {
      _interestsLoading = false;
      notifyListeners();
    }
  }

  /// Load the full catalogue once (called when picker opens).
  Future<void> loadMasterInterests() async {
    if (_masterInterestsLoaded) return;
    try {
      final raw = await _api.getAllInterests();
      _masterInterests = raw
          .where((e) => e['is_active'] == true)
          .map((e) => Interest.fromJson(e as Map<String, dynamic>))
          .toList();
      _masterInterestsLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('TouristProvider.loadMasterInterests: $e');
    }
  }

  /// Interests available to add (master minus already selected).
  List<Interest> get availableInterests {
    final selected = _interests.map((i) => i.id).toSet();
    return _masterInterests.where((i) => !selected.contains(i.id)).toList();
  }

  Future<void> addInterest(Interest interest) async {
    if (_interests.any((i) => i.id == interest.id)) return;
    _interests = List.from(_interests)..add(interest);
    notifyListeners();
    await _persistInterests();
  }

  Future<void> removeInterest(Interest interest) async {
    _interests = _interests.where((i) => i.id != interest.id).toList();
    notifyListeners();
    await _persistInterests();
  }

  Future<void> _persistInterests() async {
    final ids = _interests.map((i) => i.id).toList();
    await _api.updateUserInterests(ids);
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  Future<void> loadStats() async {
    if (_statsLoading) return;

    _statsLoading = true;
    _statsError = null;
    notifyListeners();

    try {
      _stats = await _api.getUserStats();
      _statsError = null;
    } catch (e) {
      _statsError = _friendlyError(e);
      debugPrint('TouristProvider.loadStats: $e');
    } finally {
      _statsLoading = false;
      notifyListeners();
    }
  }

  // ── Gallery ────────────────────────────────────────────────────────────────

  List<Map<String, String>> _galleryImages = [];
  List<Map<String, String>> get galleryImages =>
      List.unmodifiable(_galleryImages);

  bool _galleryLoading = false;
  bool get galleryLoading => _galleryLoading;

  String? _galleryError;
  String? get galleryError => _galleryError;

  Future<void> loadGallery() async {
    if (_galleryLoading) return;

    _galleryLoading = true;
    _galleryError = null;
    notifyListeners();

    try {
      final raw = await _api.getGallery();
      _galleryImages = raw
          .map((e) => {
        'id': (e['id'] as String?) ?? '',
        'url': (e['url'] as String?) ?? '',
      })
          .toList();
      _galleryError = null;
    } catch (e) {
      _galleryError = _friendlyError(e);
      debugPrint('TouristProvider.loadGallery: $e');
    } finally {
      _galleryLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadGalleryPhoto(dynamic file) async {
    _isUploadingPhoto = true;
    notifyListeners();
    try {
      final result = await _api.uploadGalleryPhoto(file);
      _galleryImages = [
        {
          'id': (result['photo_id'] as String?) ?? '',
          'url': (result['photo_url'] as String?) ?? '',
        },
        ..._galleryImages,
      ];
      notifyListeners();
    } catch (e) {
      debugPrint('TouristProvider.uploadGalleryPhoto: $e');
      rethrow;
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  Future<void> deleteGalleryPhoto(String photoId) async {
    await _api.deleteGalleryPhoto(photoId);
    _galleryImages = _galleryImages.where((p) => p['id'] != photoId).toList();
    notifyListeners();
  }

  // ── Profile picture ────────────────────────────────────────────────────────

  Future<void> uploadProfilePicture(dynamic file) async {
    _isUploadingPhoto = true;
    notifyListeners();
    try {
      final result = await _api.uploadProfilePicture(file);
      if (_profile != null) {
        _profile = _profile!.copyWith(
          profilePic:
          result['profile_pic'] as String? ?? _profile!.profilePic,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('TouristProvider.uploadProfilePicture: $e');
      rethrow;
    } finally {
      _isUploadingPhoto = false;
      notifyListeners();
    }
  }

  // ── Bio ────────────────────────────────────────────────────────────────────

  Future<void> updateBio(String bio) async {
    await _api.updateBio(bio);
    if (_profile != null) {
      _profile = _profile!.copyWith(profileBio: bio);
      notifyListeners();
    }
  }

  // ── Full profile update (personal info page) ───────────────────────────────

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final updated = await _api.updateProfile(data);
    _profile = TouristProfile.fromJson(updated);
    notifyListeners();
  }

  // ── Clear on logout ────────────────────────────────────────────────────────

  void clear() {
    _profile = null;
    _interests = [];
    _masterInterests = [];
    _masterInterestsLoaded = false;
    _galleryImages = [];
    _stats = null;
    _profileError = null;
    _interestError = null;
    _galleryError = null;
    _statsError = null;
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    if (e is DioException) {
      return (e.response?.data?['error'] as String?) ??
          'Network error. Please try again.';
    }
    return e.toString();
  }
}