// lib/features/guide/providers/guide_provider.dart
//
// Central ChangeNotifier for guide state.
// KEY FIX: Added _profileFetching guard to prevent duplicate concurrent
//          calls to /accounts/me/ which caused timeout on Django dev server.
//
// Usage in main.dart:
//   ChangeNotifierProvider(create: (_) => GuideProvider()..init()),
//
// Usage in a widget:
//   final p = context.watch<GuideProvider>();

import 'package:flutter/foundation.dart';
import 'package:yaloo/core/network/api_client.dart';
import 'package:yaloo/features/guide/models/guide_model.dart';
import 'package:yaloo/features/tourist/models/guide_booking_model.dart';
import 'package:yaloo/features/tourist/services/guide_booking_service.dart';

class GuideProvider extends ChangeNotifier {
  final _api     = ApiClient();
  final _service = GuideBookingService();

  // ── Profile ───────────────────────────────────────────────────────────────
  GuideModel? _profile;
  bool   _profileLoading  = false;
  bool   _profileFetching = false; // guard: prevents duplicate in-flight calls
  String _profileError    = '';

  GuideModel? get profile        => _profile;
  bool        get profileLoading => _profileLoading;
  String      get profileError   => _profileError;

  // ── Pending requests ──────────────────────────────────────────────────────
  List<GuideBookingModel> _requests        = [];
  bool                    _requestsLoading = false;
  bool                    _requestsFetching = false;
  String                  _requestsError   = '';

  List<GuideBookingModel> get requests        => _requests;
  bool                    get requestsLoading => _requestsLoading;
  String                  get requestsError   => _requestsError;

  // ── Upcoming confirmed ────────────────────────────────────────────────────
  List<GuideBookingModel> _upcoming        = [];
  bool                    _upcomingLoading = false;
  bool                    _upcomingFetching = false;
  String                  _upcomingError   = '';

  List<GuideBookingModel> get upcoming        => _upcoming;
  bool                    get upcomingLoading => _upcomingLoading;
  String                  get upcomingError   => _upcomingError;

  // ── History ───────────────────────────────────────────────────────────────
  List<GuideBookingModel> _history        = [];
  bool                    _historyLoading = false;
  String                  _historyError   = '';

  List<GuideBookingModel> get history        => _history;
  bool                    get historyLoading => _historyLoading;
  String                  get historyError   => _historyError;

  // ── Whether init has already run successfully ─────────────────────────────
  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ─────────────────────────────────────────────────────────────────────────
  // INIT — called once at app start / after login
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // Run sequentially: load profile first, then requests & upcoming in parallel.
    // This avoids hammering Django dev server with 3 simultaneous calls.
    await loadProfile();
    await Future.wait([
      loadRequests(),
      loadUpcoming(),
    ]);
    _initialized = true;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOAD PROFILE
  // KEY FIX: _profileFetching guard prevents a second call while one is
  //          already in-flight (e.g. screen initState + provider init both
  //          trying to call /accounts/me/ at the same time).
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    if (_profileFetching) return; // ← guard: skip if already loading
    _profileFetching = true;
    _profileLoading  = true;
    _profileError    = '';
    notifyListeners();

    try {
      final r    = await _api.get('/accounts/me/');
      final data = r.data as Map<String, dynamic>;
      _profile = GuideModel.fromJson(data);
    } catch (e) {
      _profileError = _friendlyError(e);
      if (kDebugMode) debugPrint('❌ GuideProvider.loadProfile: $e');
    } finally {
      _profileLoading  = false;
      _profileFetching = false; // ← always reset
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOAD PENDING REQUESTS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadRequests() async {
    if (_requestsFetching) return;
    _requestsFetching = true;
    _requestsLoading  = true;
    _requestsError    = '';
    notifyListeners();

    try {
      _requests = await _service.getGuideRequests();
    } catch (e) {
      _requestsError = _friendlyError(e);
      if (kDebugMode) debugPrint('❌ GuideProvider.loadRequests: $e');
    } finally {
      _requestsLoading  = false;
      _requestsFetching = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOAD UPCOMING CONFIRMED
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadUpcoming() async {
    if (_upcomingFetching) return;
    _upcomingFetching = true;
    _upcomingLoading  = true;
    _upcomingError    = '';
    notifyListeners();

    try {
      _upcoming = await _service.getGuideUpcoming();
    } catch (e) {
      _upcomingError = _friendlyError(e);
      if (kDebugMode) debugPrint('❌ GuideProvider.loadUpcoming: $e');
    } finally {
      _upcomingLoading  = false;
      _upcomingFetching = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // LOAD HISTORY
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadHistory() async {
    _historyLoading = true;
    _historyError   = '';
    notifyListeners();

    try {
      _history = await _service.getGuideHistory();
    } catch (e) {
      _historyError = _friendlyError(e);
      if (kDebugMode) debugPrint('❌ GuideProvider.loadHistory: $e');
    } finally {
      _historyLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESPOND TO BOOKING (accept / reject)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> respondToBooking({
    required String bookingId,
    required String action,           // 'accept' | 'reject'
    String? guideResponseNote,
  }) async {
    await _service.respondToBooking(
      bookingId:         bookingId,
      action:            action,
      guideResponseNote: guideResponseNote,
    );
    // Reset fetching guards so refresh always goes through
    _requestsFetching = false;
    _upcomingFetching = false;
    await Future.wait([loadRequests(), loadUpcoming()]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COMPLETE BOOKING
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> completeBooking(String bookingId) async {
    await _service.completeBooking(bookingId);
    _upcomingFetching = false;
    await Future.wait([loadUpcoming(), loadHistory()]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOGGLE AVAILABILITY
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> toggleAvailability() async {
    try {
      final r              = await _api.post('/accounts/guide/availability/toggle/');
      final data           = r.data as Map<String, dynamic>;
      final isNowAvailable = data['is_available'] as bool? ?? false;
      // Force a fresh profile load after toggle
      _profileFetching = false;
      await loadProfile();
      return isNowAvailable;
    } catch (e) {
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORCE RELOAD PROFILE  (resets guard — use after profile edits)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> forceReloadProfile() async {
    _profileFetching = false;
    await loadProfile();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REFRESH ALL  (resets all guards so everything re-fetches)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> refreshAll() async {
    _profileFetching  = false;
    _requestsFetching = false;
    _upcomingFetching = false;
    await init();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _friendlyError(Object e) {
    final s = e.toString();
    if (s.contains('401') || s.contains('Token validation')) {
      return 'Session expired — please log in again.';
    }
    if (s.contains('timeout') || s.contains('SocketException')) {
      return 'Cannot reach the server. Check your network.';
    }
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}