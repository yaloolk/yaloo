// lib/features/tourist/services/guide_booking_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/guide_search_result.dart';
import '../models/guide_booking_model.dart';

class GuideBookingService {
  late final Dio _dio;

  GuideBookingService() {

    final base = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';

    _dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // ── Auto-attach Supabase JWT on every request ──────────────────────────
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token =
            Supabase.instance.client.auth.currentSession?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<GuideSearchResponse> searchGuides({
    required String cityId,
    required String date,
    required String startTime,   // HH:MM
    String? endTime,             // no longer sent — backend ignores it
  }) async {
    try {
      final response = await _dio.get(
        '/accounts/guides/search/',
        queryParameters: {
          'city_id':    cityId,
          'date':       date,
          'start_time': startTime,
          // endTime intentionally omitted — backend derives the window
        },
      );

      final data   = response.data as Map<String, dynamic>;
      final guides = (data['guides'] as List? ?? [])
          .map((g) => GuideSearchResult.fromJson(g))
          .toList();

      return GuideSearchResponse(
        count:     data['count']      ?? 0,
        city:      data['city']       ?? {},
        date:      data['date']       ?? '',
        startTime: data['start_time'] ?? '',
        endTime:   data['end_time']   ?? '',
        guides:    guides,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getGuidePublicProfile(
      String guideProfileId) async {
    try {
      final response =
      await _dio.get('/accounts/guides/$guideProfileId/');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<GuideBookingModel> createBooking({
    required String guideProfileId,
    required String bookingDate,
    required String startTime,       // must be exact slot boundary "HH:MM"
    required String endTime,         // must be exact slot boundary "HH:MM"
    int    guestCount       = 1,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    String? specialNote,
  }) async {
    try {
      final response = await _dio.post(
        '/bookings/guide/create/',             // ← /api/ prefix ADDED
        data: {
          'guide_profile_id': guideProfileId,
          'booking_date':     bookingDate,
          'start_time':       _stripSeconds(startTime),
          'end_time':         _stripSeconds(endTime),
          'guest_count':      guestCount,
          if (pickupLatitude  != null) 'pickup_latitude':  pickupLatitude,
          if (pickupLongitude != null) 'pickup_longitude': pickupLongitude,
          if (pickupAddress   != null) 'pickup_address':   pickupAddress,
          if (specialNote     != null) 'special_note':     specialNote,
        },
      );
      return GuideBookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // MY BOOKINGS (tourist)
  // GET /api/booking/guide/my/
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<GuideBookingModel>> getMyBookings({String? status}) async {
    try {
      final response = await _dio.get(
        '/bookings/guide/my/',                 // ← /api/ prefix ADDED
        queryParameters: status != null ? {'status': status} : null,
      );
      return (response.data as List)
          .map((b) => GuideBookingModel.fromJson(b))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BOOKING DETAIL
  // GET /api/booking/guide/<booking_id>/
  // ─────────────────────────────────────────────────────────────────────────

  Future<GuideBookingModel> getBookingDetail(String bookingId) async {
    try {
      final response =
      await _dio.get('/bookings/guide/$bookingId/');  // ← /api/
      return GuideBookingModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CANCEL BOOKING (tourist)
  // POST /api/booking/guide/<booking_id>/cancel/
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _dio.post('/bookings/guide/$bookingId/cancel/');  // ← /api/
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — BOOKING REQUESTS
  // GET /api/booking/guide/requests/
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<GuideBookingModel>> getGuideRequests() async {
    try {
      final response =
      await _dio.get('/bookings/guide/requests/');        // ← /api/
      return (response.data as List)
          .map((b) => GuideBookingModel.fromJson(b))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — UPCOMING BOOKINGS
  // GET /api/booking/guide/upcoming/
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<GuideBookingModel>> getGuideUpcoming() async {
    try {
      final response =
      await _dio.get('/bookings/guide/upcoming/');        // ← /api/
      return (response.data as List)
          .map((b) => GuideBookingModel.fromJson(b))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — RESPOND TO BOOKING
  // POST /api/booking/guide/<booking_id>/respond/
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> respondToBooking({
    required String bookingId,
    required String action,           // 'accept' | 'reject'
    String? guideResponseNote,
  }) async {
    try {
      await _dio.post(
        '/bookings/guide/$bookingId/respond/',  // ← /api/
        data: {
          'action': action,
          if (guideResponseNote != null)
            'guide_response_note': guideResponseNote,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — BOOKING HISTORY
  // GET /api/booking/guide/history/
  // ─────────────────────────────────────────────────────────────────────────

  Future<List<GuideBookingModel>> getGuideHistory({String? status}) async {
    try {
      final response = await _dio.get(
        '/bookings/guide/history/',
        queryParameters: status != null ? {'status': status} : null,
      );
      return (response.data as List)
          .map((b) => GuideBookingModel.fromJson(b))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GUIDE — COMPLETE BOOKING
  // POST /api/booking/guide/<booking_id>/complete/
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> completeBooking(String bookingId) async {
    try {
      await _dio.post(
          '/bookings/guide/$bookingId/complete/');  // ← /api/
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// DB stores times as HH:MM:SS — strip the seconds before sending so
  /// Django's TimeField serializer receives clean "HH:MM" values.
  String _stripSeconds(String t) {
    final parts = t.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return t;
  }

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      if (data.containsKey('error'))  return data['error'].toString();
      if (data.containsKey('errors')) return data['errors'].toString();
      if (data.containsKey('detail')) return data['detail'].toString();
    }
    final status = e.response?.statusCode;
    if (status == 404) {
      return 'Endpoint not found (404). '
          'Verify API_BASE_URL in .env is http://127.0.0.1:8000 (no /api suffix).';
    }
    if (status == 401) return 'Not authenticated — please log in again.';
    if (status == 403) return 'Permission denied.';
    return e.message ?? 'An unexpected error occurred';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Response wrapper
// ─────────────────────────────────────────────────────────────────────────────

class GuideSearchResponse {
  final int count;
  final Map<String, dynamic> city;
  final String date;
  final String startTime;
  final String endTime;
  final List<GuideSearchResult> guides;

  const GuideSearchResponse({
    required this.count,
    required this.city,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.guides,
  });
}