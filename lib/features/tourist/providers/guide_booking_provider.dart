// lib/features/tourist/providers/guide_booking_provider.dart

import 'package:flutter/foundation.dart';
import '../models/guide_search_result.dart';
import '../models/guide_booking_model.dart';
import '../services/guide_booking_service.dart';

class GuideBookingProvider extends ChangeNotifier {
  final GuideBookingService _service;

  GuideBookingProvider({required GuideBookingService service})
      : _service = service;

  // ── Search state ──────────────────────────────────────────────────────────
  List<GuideSearchResult> _searchResults = [];
  bool   _searchLoading = false;
  String _searchError   = '';

  // Last search params (for re-use on Guide Detail screen)
  String _lastSearchDate      = '';
  String _lastSearchStartTime = '';
  String _lastSearchEndTime   = '';
  String _lastCityId          = '';
  String _lastCityName        = '';

  List<GuideSearchResult> get searchResults  => _searchResults;
  bool                    get searchLoading  => _searchLoading;
  String                  get searchError    => _searchError;
  String                  get lastSearchDate => _lastSearchDate;
  String                  get lastStartTime  => _lastSearchStartTime;
  String                  get lastEndTime    => _lastSearchEndTime;
  String                  get lastCityName   => _lastCityName;

  // ── Guide detail state ────────────────────────────────────────────────────
  Map<String, dynamic>? _guideDetail;
  bool   _detailLoading = false;
  String _detailError   = '';

  Map<String, dynamic>? get guideDetail   => _guideDetail;
  bool                  get detailLoading => _detailLoading;
  String                get detailError   => _detailError;

  // ── Tourist bookings state ────────────────────────────────────────────────
  List<GuideBookingModel> _myBookings        = [];
  bool                    _bookingsLoading   = false;
  String                  _bookingsError     = '';
  bool                    _createLoading     = false;
  GuideBookingModel?      _lastCreatedBooking;

  List<GuideBookingModel> get myBookings         => _myBookings;
  bool                    get bookingsLoading     => _bookingsLoading;
  String                  get bookingsError       => _bookingsError;
  bool                    get createLoading       => _createLoading;
  GuideBookingModel?      get lastCreatedBooking  => _lastCreatedBooking;

  // ── Guide-side state ──────────────────────────────────────────────────────
  List<GuideBookingModel> _guideRequests   = [];
  List<GuideBookingModel> _guideUpcoming   = [];
  List<GuideBookingModel> _guideHistory    = [];
  bool                    _guideReqLoading = false;
  String                  _guideReqError   = '';

  List<GuideBookingModel> get guideRequests   => _guideRequests;
  List<GuideBookingModel> get guideUpcoming   => _guideUpcoming;
  List<GuideBookingModel> get guideHistory    => _guideHistory;
  bool                    get guideReqLoading => _guideReqLoading;
  String                  get guideReqError   => _guideReqError;

  // ─────────────────────────────────────────────────────────────────────────
  // SEARCH GUIDES
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> searchGuides({
    required String cityId,
    required String cityName,
    required String date,
    required String startTime,
    String? endTime,
  }) async {
    _searchLoading = true;
    _searchError   = '';
    _searchResults = [];
    notifyListeners();

    try {
      final response = await _service.searchGuides(
        cityId:    cityId,
        date:      date,
        startTime: startTime,
        endTime:   endTime,
      );

      _searchResults      = response.guides;
      _lastSearchDate     = date;
      _lastSearchStartTime = startTime;
      _lastSearchEndTime  = endTime ?? response.endTime;
      _lastCityId         = cityId;
      _lastCityName       = cityName;
    } catch (e) {
      _searchError = e.toString();
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE PUBLIC PROFILE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadGuideDetail(String guideProfileId) async {
    _detailLoading = true;
    _detailError   = '';
    _guideDetail   = null;
    notifyListeners();

    try {
      _guideDetail = await _service.getGuidePublicProfile(guideProfileId);
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _detailLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE BOOKING
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> createBooking({
    required String guideProfileId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    int guestCount = 1,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    String? specialNote,
  }) async {
    _createLoading       = true;
    _lastCreatedBooking  = null;
    notifyListeners();

    try {
      final booking = await _service.createBooking(
        guideProfileId:  guideProfileId,
        bookingDate:     bookingDate,
        startTime:       startTime,
        endTime:         endTime,
        guestCount:      guestCount,
        pickupLatitude:  pickupLatitude,
        pickupLongitude: pickupLongitude,
        pickupAddress:   pickupAddress,
        specialNote:     specialNote,
      );
      _lastCreatedBooking = booking;
      _myBookings.insert(0, booking);
      return true;
    } catch (e) {
      _bookingsError = e.toString();
      return false;
    } finally {
      _createLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOURIST MY BOOKINGS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadMyBookings({String? status}) async {
    _bookingsLoading = true;
    _bookingsError   = '';
    notifyListeners();

    try {
      _myBookings = await _service.getMyBookings(status: status);
    } catch (e) {
      _bookingsError = e.toString();
    } finally {
      _bookingsLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TOURIST CANCEL BOOKING
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _service.cancelBooking(bookingId);
      final idx = _myBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        // Refresh from API to get updated status
        await loadMyBookings();
      }
      return true;
    } catch (e) {
      _bookingsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — LOAD REQUESTS + UPCOMING + HISTORY
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadGuideRequests() async {
    _guideReqLoading = true;
    _guideReqError   = '';
    notifyListeners();

    try {
      _guideRequests = await _service.getGuideRequests();
    } catch (e) {
      _guideReqError = e.toString();
    } finally {
      _guideReqLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGuideUpcoming() async {
    try {
      _guideUpcoming = await _service.getGuideUpcoming();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadGuideHistory({String? status}) async {
    try {
      _guideHistory = await _service.getGuideHistory(status: status);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadAllGuideBookings() async {
    await Future.wait([
      loadGuideRequests(),
      loadGuideUpcoming(),
      loadGuideHistory(),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — RESPOND TO BOOKING
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> respondToBooking({
    required String bookingId,
    required String action,
    String? guideResponseNote,
  }) async {
    try {
      await _service.respondToBooking(
        bookingId:          bookingId,
        action:             action,
        guideResponseNote:  guideResponseNote,
      );
      // Refresh requests list
      await loadGuideRequests();
      await loadGuideUpcoming();
      return true;
    } catch (e) {
      _guideReqError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — COMPLETE BOOKING
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> completeBooking(String bookingId) async {
    try {
      await _service.completeBooking(bookingId);
      await loadAllGuideBookings();
      return true;
    } catch (e) {
      _guideReqError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    _searchError   = '';
    notifyListeners();
  }

  void clearBookingError() {
    _bookingsError = '';
    notifyListeners();
  }
}