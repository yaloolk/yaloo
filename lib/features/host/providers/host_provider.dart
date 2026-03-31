// lib/features/host/providers/host_provider.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaloo/core/services/host_api_service.dart';
import 'package:yaloo/features/host/models/host_models.dart';

class HostProvider extends ChangeNotifier {
  final HostApiService _api = HostApiService();

  // State
  HostProfile? _profile;
  HostDashboard? _dashboard;
  StayDetail? _selectedStayDetail;
  List<Stay> _stays = [];

  // Loading states
  bool _profileLoading = false;
  bool _dashboardLoading = false;
  bool _stayDetailLoading = false;
  bool _facilitiesLoading = false;

  // Error state
  String? _error;

  // Selected stay index (for switcher)
  int _selectedStayIndex = 0;

  // Cached data
  List<Facility> _facilities = [];
  List<Language> _languages = [];
  List<City> _cities = [];

  // Getters
  HostProfile? get profile => _profile;
  HostDashboard? get dashboard => _dashboard;
  StayDetail? get selectedStayDetail => _selectedStayDetail;
  List<Stay> get stays => _stays;

  bool get profileLoading => _profileLoading;
  bool get dashboardLoading => _dashboardLoading;
  bool get stayDetailLoading => _stayDetailLoading;
  bool get facilitiesLoading => _facilitiesLoading;

  String? get error => _error;
  int get selectedStayIndex => _selectedStayIndex;

  List<Facility> get facilities => _facilities;
  List<Language> get languages => _languages;
  List<City> get cities => _cities;

  Stay? get selectedStay {
    if (_dashboard == null || _dashboard!.stays.isEmpty) return null;
    if (_selectedStayIndex >= _dashboard!.stays.length) return null;
    return _dashboard!.stays[_selectedStayIndex];
  }

  // ══════════════════════════════════════════════════════════
  // PROFILE
  // ══════════════════════════════════════════════════════════

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (_profileLoading) return;

    _profileLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.getHostProfile();
      _profile = HostProfile.fromJson(data);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ loadProfile: $e');
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _error = null;
    try {
      await _api.updateHostProfile(data);
      await loadProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ updateProfile: $e');
      return false;
    }
  }

  Future<bool> updateProfilePicture(XFile photo) async {
    _error = null;
    try {
      await _api.updateProfilePicture(photo);
      await loadProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ updateProfilePicture: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // DASHBOARD
  // ══════════════════════════════════════════════════════════

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_dashboardLoading) return;

    _dashboardLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.getHostDashboard();
      _dashboard = HostDashboard.fromJson(data);

      if (_dashboard != null) {
        final count = _dashboard!.stays.length;
        if (_selectedStayIndex >= count && count > 0) {
          _selectedStayIndex = 0;
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ loadDashboard: $e');
    } finally {
      _dashboardLoading = false;
      notifyListeners();
    }
  }

  void selectStay(int index) {
    if (_dashboard == null) return;
    if (index < 0 || index >= _dashboard!.stays.length) return;
    if (_selectedStayIndex == index) return;

    _selectedStayIndex = index;
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════
  // STAYS
  // ══════════════════════════════════════════════════════════

  Future<String?> createStay({
    required Map<String, dynamic> stayData,
    List<XFile>? photos,
    List<XFile>? documents,
    List<String>? facilityIds,
  }) async {
    _error = null;
    try {
      final result = await _api.createStay(
        stayData: stayData,
        photos: photos,
        documents: documents,
        facilityIds: facilityIds,
      );

      await loadDashboard(forceRefresh: true);
      return result['stay_id'] as String?;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ createStay: $e');
      return null;
    }
  }

  Future<void> loadStays() async {
    try {
      final data = await _api.getHostStays();
      _stays = data.map((s) => Stay.fromJson(s)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ loadStays: $e');
    }
  }

  Future<void> loadStayDetail(String stayId) async {
    _stayDetailLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.getStayDetail(stayId);
      _selectedStayDetail = StayDetail.fromJson(data);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ loadStayDetail: $e');
    } finally {
      _stayDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStay(String stayId, Map<String, dynamic> data) async {
    _error = null;
    try {
      await _api.updateStay(stayId, data);
      await Future.wait([
        loadStayDetail(stayId),
        loadDashboard(forceRefresh: true),
      ]);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ updateStay: $e');
      return false;
    }
  }

  Future<bool> toggleStayActive(String stayId) async {
    _error = null;
    try {
      await _api.toggleStayActive(stayId);
      await loadDashboard(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ toggleStayActive: $e');
      return false;
    }
  }

  Future<bool> deleteStay(String stayId) async {
    _error = null;
    try {
      await _api.deleteStay(stayId);
      await loadDashboard(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ deleteStay: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // PHOTOS
  // ══════════════════════════════════════════════════════════

  Future<bool> addStayPhotos(String stayId, List<XFile> photos) async {
    _error = null;
    try {
      await _api.addStayPhotos(stayId, photos);
      await Future.wait([
        loadStayDetail(stayId),
        loadDashboard(forceRefresh: true),
      ]);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ addStayPhotos: $e');
      return false;
    }
  }

  Future<bool> deleteStayPhoto(String stayId, String photoId) async {
    _error = null;
    try {
      await _api.deleteStayPhoto(stayId, photoId);
      await loadStayDetail(stayId);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ deleteStayPhoto: $e');
      return false;
    }
  }

  Future<bool> setCoverPhoto(String stayId, String photoId) async {
    _error = null;
    try {
      await _api.setCoverPhoto(stayId, photoId);
      await loadStayDetail(stayId);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ setCoverPhoto: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // FACILITIES
  // ══════════════════════════════════════════════════════════

  Future<void> loadFacilities() async {
    if (_facilitiesLoading) return;

    _facilitiesLoading = true;
    notifyListeners();

    try {
      final data = await _api.getAllFacilities();
      _facilities = data.map((f) => Facility.fromJson(f)).toList();
    } catch (e) {
      if (kDebugMode) print('❌ loadFacilities: $e');
    } finally {
      _facilitiesLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStayFacilities(String stayId, List<String> facilityIds) async {
    _error = null;
    try {
      await _api.updateStayFacilities(stayId, facilityIds);
      await loadStayDetail(stayId);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ updateStayFacilities: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // AVAILABILITY
  // ══════════════════════════════════════════════════════════

  Future<bool> setStayAvailability(String stayId, Map<String, dynamic> data) async {
    _error = null;
    try {
      await _api.setStayAvailability(stayId, data);
      await loadStayDetail(stayId);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ setStayAvailability: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // LANGUAGES
  // ══════════════════════════════════════════════════════════

  Future<void> loadLanguages() async {
    try {
      final data = await _api.getAllLanguages();
      _languages = data.map((l) => Language.fromJson(l)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ loadLanguages: $e');
    }
  }

  Future<bool> addLanguage(String languageId, String proficiency) async {
    _error = null;
    try {
      await _api.addHostLanguage(languageId, proficiency);
      await loadProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ addLanguage: $e');
      return false;
    }
  }

  Future<bool> updateLanguage(String languageId, String proficiency) async {
    _error = null;
    try {
      await _api.updateHostLanguage(languageId, proficiency);
      await loadProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ updateLanguage: $e');
      return false;
    }
  }

  Future<bool> removeLanguage(String languageId) async {
    _error = null;
    try {
      await _api.removeHostLanguage(languageId);
      await loadProfile(forceRefresh: true);
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) print('❌ removeLanguage: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // MASTER DATA
  // ══════════════════════════════════════════════════════════

  Future<void> loadCities() async {
    try {
      final data = await _api.getAllCities();
      _cities = data.map((c) => City.fromJson(c)).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ loadCities: $e');
    }
  }

  // ══════════════════════════════════════════════════════════
  // UTILITY
  // ══════════════════════════════════════════════════════════

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadProfile(forceRefresh: true),
      loadDashboard(forceRefresh: true),
    ]);
  }

  void clear() {
    _profile = null;
    _dashboard = null;
    _selectedStayDetail = null;
    _stays.clear();
    _selectedStayIndex = 0;
    _facilities.clear();
    _languages.clear();
    _cities.clear();
    _error = null;
    notifyListeners();
  }
}