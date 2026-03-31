// lib/features/tourist/services/stay_booking_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stay_booking_model.dart';

class StayBookingService {
  late final Dio _dio;

  StayBookingService() {
    final base = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';
    _dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
  }

  // ── Cities (reuse accounts endpoint) ─────────────────────────────────────
  Future<List<Map<String, dynamic>>> getCities() async {
    try {
      final r = await _dio.get('/accounts/cities/');
      return (r.data as List)
          .map((c) => {'id': c['id'].toString(), 'name': c['name'].toString()})
          .toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Tourist: search stays ─────────────────────────────────────────────────
  Future<List<StaySearchResult>> searchStays({
    String? cityId,
    required String checkin,
    required String checkout,
    int guests = 1,
    int rooms  = 1,
    String? type,
  }) async {
    try {
      final params = <String, dynamic>{
        if (cityId  != null) 'city_id':  cityId,
        'checkin':  checkin,
        'checkout': checkout,
        'guests':   guests,
        'rooms':    rooms,
        if (type != null) 'type': type,
      };
      final r = await _dio.get('/bookings/stays/search/', queryParameters: params);
      final raw = r.data;
      // API may return { stays: [...] } or just [...]
      final list = raw is Map ? (raw['stays'] as List? ?? []) : (raw as List);
      return list.map((j) => StaySearchResult.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Tourist: stay public profile ──────────────────────────────────────────
  Future<Map<String, dynamic>> getStayProfile(String stayId) async {
    try {
      final r = await _dio.get('/bookings/stays/$stayId/profile/');

      final Map<String, dynamic> data = Map<String, dynamic>.from(r.data as Map);

      data['cover_photo'] = data['cover_photo'] ?? '';
      data['host_photo']  = data['host_photo'] ?? '';
      data['host_bio']    = data['host_bio'] ?? 'This host has not provided a biography yet.';
      data['description'] = data['description'] ?? 'No description available.';
      data['city_name']   = data['city_name'] ?? '';
      data['photos']      = data['photos'] ?? [];
      data['facilities']  = data['facilities'] ?? [];
      data['reviews']     = data['reviews'] ?? [];

      return data;

    } on DioException catch (e) {
      throw _err(e);
    } catch (e) {
      // Catch any formatting/parsing crashes and surface them safely
      throw Exception('Data parsing error: $e');
    }
  }

  // ── Tourist: create booking ───────────────────────────────────────────────
  Future<StayBookingModel> createBooking({
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
    try {
      final r = await _dio.post('/bookings/stays/create/', data: {
        'stay_id':           stayId,
        'checkin_date':      checkinDate,
        'checkout_date':     checkoutDate,
        'booking_type':      bookingType,
        'room_count':        roomCount,
        'guest_count':       guestCount,
        'meal_preference':   mealPreference,
        if (checkinTime  != null) 'checkin_time':  checkinTime,
        if (checkoutTime != null) 'checkout_time': checkoutTime,
        if (specialNote  != null) 'special_note':  specialNote,
        'tourist_full_name': touristFullName,
        if (touristPassport != null) 'tourist_passport': touristPassport,
        'tourist_phone':   touristPhone,
        'tourist_email':   touristEmail,
        if (touristCountry != null) 'tourist_country': touristCountry,
        if (touristGender  != null) 'tourist_gender':  touristGender,
      });
      return StayBookingModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Tourist: my bookings ──────────────────────────────────────────────────
  Future<List<StayBookingModel>> getMyBookings({String? status}) async {
    try {
      final r = await _dio.get('/bookings/stays/my/',
          queryParameters: status != null ? {'status': status} : null);
      return (r.data as List)
          .map((j) => StayBookingModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Tourist: booking detail ───────────────────────────────────────────────
  Future<StayBookingModel> getBookingDetail(String bookingId) async {
    try {
      final r = await _dio.get('/bookings/stays/$bookingId/');
      return StayBookingModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Tourist: cancel ───────────────────────────────────────────────────────
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _dio.post('/bookings/stays/$bookingId/cancel/');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Host: pending requests ────────────────────────────────────────────────
  Future<List<StayBookingModel>> getHostRequests() async {
    try {
      final r = await _dio.get('/bookings/stays/host/requests/');
      return (r.data as List)
          .map((j) => StayBookingModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Host: all bookings ────────────────────────────────────────────────────
  Future<List<StayBookingModel>> getHostAllBookings({String? status}) async {
    try {
      final r = await _dio.get('/bookings/stays/host/all/',
          queryParameters: status != null ? {'status': status} : null);
      return (r.data as List)
          .map((j) => StayBookingModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Host: respond ─────────────────────────────────────────────────────────
  Future<void> respondToBooking({
    required String bookingId,
    required String action,
    String? hostResponseNote,
  }) async {
    try {
      await _dio.post('/bookings/stays/$bookingId/respond/', data: {
        'action': action,
        if (hostResponseNote != null) 'host_response_note': hostResponseNote,
      });
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Host: complete ────────────────────────────────────────────────────────
  Future<void> completeBooking(String bookingId) async {
    try {
      await _dio.post('/bookings/stays/$bookingId/complete/');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ── Error helper ──────────────────────────────────────────────────────────
  String _err(DioException e) {
    final d = e.response?.data;
    if (d is Map) {
      for (final k in ['error', 'errors', 'detail']) {
        if (d.containsKey(k)) return d[k].toString();
      }
    }
    switch (e.response?.statusCode) {
      case 400: return 'Bad request — check your inputs.';
      case 401: return 'Not authenticated — please log in again.';
      case 403: return 'Permission denied.';
      case 404: return 'Not found.';
      default:  return e.message ?? 'Unexpected error';
    }
  }
}