// lib/features/tourist/providers/stay_booking_provider.dart

import 'package:flutter/foundation.dart';
import '../models/stay_booking_model.dart';
import '../services/stay_booking_service.dart';

class StayBookingProvider extends ChangeNotifier {
  final StayBookingService _service;

  StayBookingProvider({StayBookingService? service})
      : _service = service ?? StayBookingService();

  // ── Cities ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _cities = [];
  bool   _citiesLoading = false;
  List<Map<String, dynamic>> get cities       => _cities;
  bool                       get citiesLoading => _citiesLoading;

  Future<void> loadCities() async {
    if (_cities.isNotEmpty || _citiesLoading) return;
    _citiesLoading = true;
    notifyListeners();
    try {
      _cities = await _service.getCities();
    } catch (_) {}
    _citiesLoading = false;
    notifyListeners();
  }

  // ── Search state ──────────────────────────────────────────────────────────
  List<StaySearchResult> _searchResults = [];
  bool   _searchLoading = false;
  String _searchError   = '';

  List<StaySearchResult> get searchResults => _searchResults;
  bool                   get searchLoading => _searchLoading;
  String                 get searchError   => _searchError;

  // last search params
  String _lastCityName  = '';
  String _lastCheckin   = '';
  String _lastCheckout  = '';
  String get lastCityName => _lastCityName;
  String get lastCheckin  => _lastCheckin;
  String get lastCheckout => _lastCheckout;

  Future<void> searchStays({
    String? cityId,
    String? cityName,
    required String checkin,
    required String checkout,
    int guests = 1,
    int rooms  = 1,
    String? type,
  }) async {
    _searchLoading = true;
    _searchError   = '';
    _searchResults = [];
    notifyListeners();

    try {
      _searchResults = await _service.searchStays(
        cityId:   cityId,
        checkin:  checkin,
        checkout: checkout,
        guests:   guests,
        rooms:    rooms,
        type:     type,
      );
      _lastCityName = cityName ?? '';
      _lastCheckin  = checkin;
      _lastCheckout = checkout;
    } catch (e) {
      _searchError = e.toString();
    } finally {
      _searchLoading = false;
      notifyListeners();
    }
  }

  // ── Stay profile ──────────────────────────────────────────────────────────
  Map<String, dynamic>? _stayProfile;
  bool   _profileLoading = false;
  String _profileError   = '';

  Map<String, dynamic>? get stayProfile    => _stayProfile;
  bool                  get profileLoading => _profileLoading;
  String                get profileError   => _profileError;

  Future<void> loadStayProfile(String stayId) async {
    // Clear the old profile so the loading shimmer shows up properly!
    _stayProfile = null;
    _profileLoading = true;
    _profileError = '';
    notifyListeners();

    try {
      _stayProfile = await _service.getStayProfile(stayId);
    } catch (e) {
      _profileError = e.toString();
    } finally {
      _profileLoading = false;
      notifyListeners();
    }
  }

  // ── Create booking ────────────────────────────────────────────────────────
  bool               _createLoading      = false;
  String             _createError        = '';
  StayBookingModel?  _lastCreatedBooking;

  bool              get createLoading      => _createLoading;
  String            get createError        => _createError;
  StayBookingModel? get lastCreatedBooking => _lastCreatedBooking;

  Future<bool> createBooking({
    required String stayId,
    required String checkinDate,
    required String checkoutDate,
    String  bookingType    = 'per_night',
    int     roomCount      = 1,
    int     guestCount     = 1,
    String  mealPreference = 'none',
    String? checkinTime,
    String? checkoutTime,
    String? specialNote,
    required String touristFullName,
    String? touristPassport,
    required String touristPhone,
    required String touristEmail,
    String? touristCountry,
    String? touristGender,
  }) async {
    _createLoading      = true;
    _createError        = '';
    _lastCreatedBooking = null;
    notifyListeners();

    try {
      final booking = await _service.createBooking(
        stayId:          stayId,
        checkinDate:     checkinDate,
        checkoutDate:    checkoutDate,
        bookingType:     bookingType,
        roomCount:       roomCount,
        guestCount:      guestCount,
        mealPreference:  mealPreference,
        checkinTime:     checkinTime,
        checkoutTime:    checkoutTime,
        specialNote:     specialNote,
        touristFullName: touristFullName,
        touristPassport: touristPassport,
        touristPhone:    touristPhone,
        touristEmail:    touristEmail,
        touristCountry:  touristCountry,
        touristGender:   touristGender,
      );
      _lastCreatedBooking = booking;
      _myBookings.insert(0, booking);
      return true;
    } catch (e) {
      _createError = e.toString();
      return false;
    } finally {
      _createLoading = false;
      notifyListeners();
    }
  }

  // ── Tourist: my bookings ──────────────────────────────────────────────────
  List<StayBookingModel> _myBookings = [];
  bool   _myLoading = false;
  String _myError   = '';

  List<StayBookingModel> get myBookings => _myBookings;
  bool                   get myLoading  => _myLoading;
  String                 get myError    => _myError;

  Future<void> loadMyBookings({String? status}) async {
    _myLoading = true;
    _myError   = '';
    notifyListeners();
    try {
      _myBookings = await _service.getMyBookings(status: status);
    } catch (e) {
      _myError = e.toString();
    } finally {
      _myLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _service.cancelBooking(bookingId);
      await loadMyBookings();
      return true;
    } catch (e) {
      _myError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Host: requests ────────────────────────────────────────────────────────
  List<StayBookingModel> _hostRequests = [];
  List<StayBookingModel> _hostBookings = [];
  bool   _hostLoading = false;
  String _hostError   = '';

  List<StayBookingModel> get hostRequests => _hostRequests;
  List<StayBookingModel> get hostBookings => _hostBookings;
  bool                   get hostLoading  => _hostLoading;
  String                 get hostError    => _hostError;

  Future<void> loadHostRequests() async {
    _hostLoading = true;
    _hostError   = '';
    notifyListeners();
    try {
      _hostRequests = await _service.getHostRequests();
    } catch (e) {
      _hostError = e.toString();
    } finally {
      _hostLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHostAllBookings({String? status}) async {
    _hostLoading = true;
    notifyListeners();
    try {
      _hostBookings = await _service.getHostAllBookings(status: status);
    } catch (e) {
      _hostError = e.toString();
    } finally {
      _hostLoading = false;
      notifyListeners();
    }
  }

  Future<bool> respondToBooking({
    required String bookingId,
    required String action,
    String? hostResponseNote,
  }) async {
    try {
      await _service.respondToBooking(
        bookingId:        bookingId,
        action:           action,
        hostResponseNote: hostResponseNote,
      );
      await loadHostRequests();
      await loadHostAllBookings();
      return true;
    } catch (e) {
      _hostError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeBooking(String bookingId) async {
    try {
      await _service.completeBooking(bookingId);
      await loadHostAllBookings();
      return true;
    } catch (e) {
      _hostError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchError   = '';
    notifyListeners();
  }
}