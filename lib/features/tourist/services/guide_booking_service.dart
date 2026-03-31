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
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // ── SEARCH GUIDES ─────────────────────────────────────────────────────────
  Future<GuideSearchResponse> searchGuides({
    required String cityId,
    required String date,
    required String startTime,
    String? endTime,
  }) async {
    try {
      final r = await _dio.get('/accounts/guides/search/', queryParameters: {
        'city_id': cityId, 'date': date, 'start_time': startTime,
      });
      final data   = r.data as Map<String, dynamic>;
      final guides = (data['guides'] as List? ?? [])
          .map((g) => GuideSearchResult.fromJson(g)).toList();
      return GuideSearchResponse(
        count:     data['count']      ?? 0,
        city:      data['city']       ?? {},
        date:      data['date']       ?? '',
        startTime: data['start_time'] ?? '',
        endTime:   data['end_time']   ?? '',
        guides:    guides,
      );
    } on DioException catch (e) { throw _err(e); }
  }

  // ── GUIDE PUBLIC PROFILE ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getGuidePublicProfile(String id) async {
    try {
      final r = await _dio.get('/accounts/guides/$id/');
      return r.data as Map<String, dynamic>;
    } on DioException catch (e) { throw _err(e); }
  }

  // ── CREATE BOOKING ────────────────────────────────────────────────────────
  Future<GuideBookingModel> createBooking({
    required String guideProfileId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    int    guestCount    = 1,
    double? pickupLatitude,
    double? pickupLongitude,
    String? pickupAddress,
    String? specialNote,
  }) async {
    try {
      final r = await _dio.post('/bookings/guide/create/', data: {
        'guide_profile_id': guideProfileId,
        'booking_date':     bookingDate,
        'start_time':       _trim(startTime),
        'end_time':         _trim(endTime),
        'guest_count':      guestCount,
        if (pickupLatitude  != null) 'pickup_latitude':  pickupLatitude,
        if (pickupLongitude != null) 'pickup_longitude': pickupLongitude,
        if (pickupAddress   != null) 'pickup_address':   pickupAddress,
        if (specialNote     != null) 'special_note':     specialNote,
      });
      return GuideBookingModel.fromJson(r.data);
    } on DioException catch (e) { throw _err(e); }
  }

  // ── MY BOOKINGS (tourist) ─────────────────────────────────────────────────
  Future<List<GuideBookingModel>> getMyBookings({String? status}) async {
    try {
      final r = await _dio.get('/bookings/guide/my/',
          queryParameters: status != null ? {'status': status} : null);
      return _list(r.data);
    } on DioException catch (e) { throw _err(e); }
  }

  // ── BOOKING DETAIL ────────────────────────────────────────────────────────
  Future<GuideBookingModel> getBookingDetail(String id) async {
    try {
      final r = await _dio.get('/bookings/guide/$id/');
      return GuideBookingModel.fromJson(r.data);
    } on DioException catch (e) { throw _err(e); }
  }

  // ── CANCEL BOOKING ────────────────────────────────────────────────────────
  Future<void> cancelBooking(String id) async {
    try {
      await _dio.post('/bookings/guide/$id/cancel/');
    } on DioException catch (e) { throw _err(e); }
  }

  // ── GUIDE: PENDING REQUESTS ───────────────────────────────────────────────
  Future<List<GuideBookingModel>> getGuideRequests() async {
    try {
      final r = await _dio.get('/bookings/guide/requests/');
      return _list(r.data);
    } on DioException catch (e) { throw _err(e); }
  }

  // ── GUIDE: UPCOMING ───────────────────────────────────────────────────────
  Future<List<GuideBookingModel>> getGuideUpcoming() async {
    try {
      final r = await _dio.get('/bookings/guide/upcoming/');
      return _list(r.data);
    } on DioException catch (e) { throw _err(e); }
  }

  // ── GUIDE: RESPOND ────────────────────────────────────────────────────────
  Future<void> respondToBooking({
    required String bookingId,
    required String action,
    String? guideResponseNote,
  }) async {
    try {
      await _dio.post('/bookings/guide/$bookingId/respond/', data: {
        'action': action,
        if (guideResponseNote != null) 'guide_response_note': guideResponseNote,
      });
    } on DioException catch (e) { throw _err(e); }
  }

  // ── GUIDE: HISTORY ────────────────────────────────────────────────────────
  Future<List<GuideBookingModel>> getGuideHistory({String? status}) async {
    try {
      final r = await _dio.get('/bookings/guide/history/',
          queryParameters: status != null ? {'status': status} : null);
      return _list(r.data);
    } on DioException catch (e) { throw _err(e); }
  }

  // ── GUIDE: COMPLETE ───────────────────────────────────────────────────────
  Future<void> completeBooking(String id) async {
    try {
      await _dio.post('/bookings/guide/$id/complete/');
    } on DioException catch (e) { throw _err(e); }
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  List<GuideBookingModel> _list(dynamic d) =>
      (d as List).map((b) => GuideBookingModel.fromJson(b)).toList();

  String _trim(String t) {
    final p = t.split(':');
    return p.length >= 2 ? '${p[0]}:${p[1]}' : t;
  }

  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map) {
      for (final k in ['error', 'errors', 'detail']) {
        if (d.containsKey(k)) return d[k].toString();
      }
    }
    switch (e.response?.statusCode) {
      case 404: return 'Endpoint not found — check API_BASE_URL in .env';
      case 401: return 'Not authenticated — please log in again.';
      case 403: return 'Permission denied.';
      default:  return e.message ?? 'Unexpected error';
    }
  }
}

class GuideSearchResponse {
  final int count;
  final Map<String, dynamic> city;
  final String date;
  final String startTime;
  final String endTime;
  final List<GuideSearchResult> guides;

  const GuideSearchResponse({
    required this.count, required this.city, required this.date,
    required this.startTime, required this.endTime, required this.guides,
  });
}