// lib/core/services/payment_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../storage/secure_storage.dart';

// ── Result types ──────────────────────────────────────────────────────────────

class PaymentIntentResult {
  final String clientSecret;
  final String paymentId;
  final double amountLkr;
  final double platformFeeLkr;
  final double totalLkr;

  const PaymentIntentResult({
    required this.clientSecret,
    required this.paymentId,
    required this.amountLkr,
    required this.platformFeeLkr,
    required this.totalLkr,
  });
}

class CancellationPreview {
  final String tier;
  final double feePercent;
  final double originalAmountLkr;
  final double feeAmountLkr;
  final double refundAmountLkr;
  final String policyDescription;
  final double hoursBeforeStart;
  final int freeCancelHours;
  final int partialFeeHours;

  const CancellationPreview({
    required this.tier,
    required this.feePercent,
    required this.originalAmountLkr,
    required this.feeAmountLkr,
    required this.refundAmountLkr,
    required this.policyDescription,
    required this.hoursBeforeStart,
    required this.freeCancelHours,
    required this.partialFeeHours,
  });

  factory CancellationPreview.fromJson(Map<String, dynamic> json) =>
      CancellationPreview(
        tier: json['tier'] as String? ?? 'free',
        feePercent: (json['fee_percent'] as num?)?.toDouble() ?? 0,
        originalAmountLkr:
        (json['original_amount_lkr'] as num?)?.toDouble() ?? 0,
        feeAmountLkr: (json['fee_amount_lkr'] as num?)?.toDouble() ?? 0,
        refundAmountLkr: (json['refund_amount_lkr'] as num?)?.toDouble() ?? 0,
        policyDescription: json['policy_description'] as String? ?? '',
        hoursBeforeStart:
        (json['hours_before_start'] as num?)?.toDouble() ?? 0,
        freeCancelHours: (json['free_cancel_hours'] as int?) ?? 24,
        partialFeeHours: (json['partial_fee_hours'] as int?) ?? 12,
      );

  bool get isFree => tier == 'free';
  bool get isPartial => tier == 'partial';
  bool get isNone => tier == 'none';
}

class CancelResult {
  final bool success;
  final String message;
  final double refundAmountLkr;
  final double feeAmountLkr;
  final String refundNote;
  final String? error;

  const CancelResult({
    required this.success,
    required this.message,
    this.refundAmountLkr = 0,
    this.feeAmountLkr = 0,
    this.refundNote = '',
    this.error,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class PaymentService {
  // Use the same base URL and auth pattern as DjangoApiService
  static String get _baseUrl => EnvConfig.apiBaseUrl;

  Future<String?> _getToken() async {
    return await SecureStorage().getAccessToken();
  }

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── Create PaymentIntent ────────────────────────────────────────────────

  Future<PaymentIntentResult> createPaymentIntent({
    required String bookingType,
    required String bookingId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    // Uses the same pattern as DjangoApiService:
    // baseUrl = 'http://x.x.x.x:8000/api'
    // full URL = 'http://x.x.x.x:8000/api/payment/create-intent/'
    final url = '$_baseUrl/payment/create-intent/';

    if (kDebugMode) debugPrint('🌐 POST $url');

    final response = await http
        .post(
      Uri.parse(url),
      headers: _headers(token),
      body: json.encode({
        'booking_type': bookingType,
        'booking_id': bookingId,
      }),
    )
        .timeout(const Duration(seconds: 20));

    if (kDebugMode) {
      debugPrint('📡 create-intent status: ${response.statusCode}');
      debugPrint('📡 create-intent body: ${response.body}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return PaymentIntentResult(
        clientSecret: data['client_secret'] as String,
        paymentId: data['payment_id'] as String,
        amountLkr: (data['amount_lkr'] as num).toDouble(),
        platformFeeLkr: (data['platform_fee_lkr'] as num? ?? 0).toDouble(),
        totalLkr: (data['total_lkr'] as num? ?? data['amount_lkr'] as num)
            .toDouble(),
      );
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    throw Exception(body['error'] ?? 'Failed to initialise payment (${response.statusCode})');
  }

  // ── Present Stripe Payment Sheet ────────────────────────────────────────

  Future<bool> presentPaymentSheet({
    required String clientSecret,
    required double totalLkr,
    String merchantDisplayName = 'Yaloo',
  }) async {

    // Payment Sheet does not support Flutter Web.
    // Yaloo is a mobile app — test on Android or iOS.
    if (kIsWeb) {
      throw Exception(
        'Payments are not supported in the web browser.\n'
            'Please use the Yaloo mobile app on Android or iOS to complete your booking.',
      );
    }

    // Mobile: iOS + Android
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantDisplayName,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      throw Exception(e.error.localizedMessage ?? 'Payment failed');
    }
  }

  Future<bool> _presentWebPayment({
    required String clientSecret,
    required double totalLkr,
  }) async {
    // Extract PaymentIntent ID from client secret
    // client_secret format: pi_xxxxx_secret_yyyyy
    final paymentIntentId = clientSecret.split('_secret_').first;

    // Use confirmPaymentElement via Stripe.js
    // For web, we use the confirmPayment method which handles redirect
    try {
      final result = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      return result.status == PaymentIntentsStatus.Succeeded ||
          result.status == PaymentIntentsStatus.RequiresCapture;

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return false;
      throw Exception(e.error.localizedMessage ?? 'Web payment failed');
    }
  }

  // ── Cancellation preview ────────────────────────────────────────────────

  Future<CancellationPreview> getCancellationPreview({
    required String bookingType,
    required String bookingId,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final url =
        '$_baseUrl/payment/cancellation-preview/?booking_type=$bookingType&booking_id=$bookingId';

    if (kDebugMode) debugPrint('🌐 GET $url');

    final response = await http
        .get(Uri.parse(url), headers: _headers(token))
        .timeout(const Duration(seconds: 15));

    if (kDebugMode) {
      debugPrint('📡 cancellation-preview status: ${response.statusCode}');
    }

    if (response.statusCode == 200) {
      return CancellationPreview.fromJson(
          json.decode(response.body) as Map<String, dynamic>);
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    throw Exception(body['error'] ?? 'Failed to load cancellation info');
  }

  // ── Cancel booking with refund ──────────────────────────────────────────

  Future<CancelResult> cancelBooking({
    required String bookingType,
    required String bookingId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return const CancelResult(
            success: false,
            message: 'Not authenticated',
            error: 'No token');
      }

      final url = '$_baseUrl/payment/cancel/';

      if (kDebugMode) debugPrint('🌐 POST $url');

      final response = await http
          .post(
        Uri.parse(url),
        headers: _headers(token),
        body: json.encode({
          'booking_type': bookingType,
          'booking_id': bookingId,
        }),
      )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('📡 cancel status: ${response.statusCode}');
        debugPrint('📡 cancel body: ${response.body}');
      }

      final body = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return CancelResult(
          success: true,
          message: body['message'] as String? ?? 'Booking cancelled',
          refundAmountLkr:
          (body['refund_amount_lkr'] as num? ?? 0).toDouble(),
          feeAmountLkr: (body['fee_amount_lkr'] as num? ?? 0).toDouble(),
          refundNote: body['refund_note'] as String? ?? '',
        );
      }

      return CancelResult(
        success: false,
        message: 'Cancellation failed',
        error: body['error'] as String?,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('❌ cancelBooking error: $e');
      return CancelResult(
          success: false, message: 'Cancellation failed', error: e.toString());
    }
  }
}