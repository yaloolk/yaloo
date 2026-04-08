// lib/core/services/payment_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../network/api_client.dart';

// ── Result types ──────────────────────────────────────────────────────────────

class PaymentIntentResult {
  final String  clientSecret;
  final String  paymentId;
  final double  amountLkr;
  final double  platformFeeLkr;
  final double  totalLkr;

  const PaymentIntentResult({
    required this.clientSecret,
    required this.paymentId,
    required this.amountLkr,
    required this.platformFeeLkr,
    required this.totalLkr,
  });
}

class CancellationPreview {
  final String  tier;           // 'free' | 'partial' | 'none'
  final double  feePercent;
  final double  originalAmountLkr;
  final double  feeAmountLkr;
  final double  refundAmountLkr;
  final String  policyDescription;
  final double  hoursBeforeStart;
  final int     freeCancelHours;
  final int     partialFeeHours;

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
        tier:               json['tier']                 as String? ?? 'free',
        feePercent:         (json['fee_percent']         as num?)?.toDouble() ?? 0,
        originalAmountLkr:  (json['original_amount_lkr'] as num?)?.toDouble() ?? 0,
        feeAmountLkr:       (json['fee_amount_lkr']      as num?)?.toDouble() ?? 0,
        refundAmountLkr:    (json['refund_amount_lkr']   as num?)?.toDouble() ?? 0,
        policyDescription:  json['policy_description']  as String? ?? '',
        hoursBeforeStart:   (json['hours_before_start']  as num?)?.toDouble() ?? 0,
        freeCancelHours:    (json['free_cancel_hours']   as int?)  ?? 24,
        partialFeeHours:    (json['partial_fee_hours']   as int?)  ?? 12,
      );

  bool get isFree    => tier == 'free';
  bool get isPartial => tier == 'partial';
  bool get isNone    => tier == 'none';
}

class CancelResult {
  final bool    success;
  final String  message;
  final double  refundAmountLkr;
  final double  feeAmountLkr;
  final String  refundNote;
  final String? error;

  const CancelResult({
    required this.success,
    required this.message,
    this.refundAmountLkr = 0,
    this.feeAmountLkr    = 0,
    this.refundNote      = '',
    this.error,
  });
}

// ── Service ───────────────────────────────────────────────────────────────────

class PaymentService {
  final _api = ApiClient();

  // ── Step 1: Create PaymentIntent on backend ──────────────────────────────

  Future<PaymentIntentResult> createPaymentIntent({
    required String bookingType,   // 'guide' | 'stay'
    required String bookingId,
  }) async {
    final resp = await _api.post('/api/payment/create-intent/', data: {
      'booking_type': bookingType,
      'booking_id':   bookingId,
    });

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      final body = jsonDecode(resp.data);
      throw Exception(body['error'] ?? 'Failed to initialise payment');
    }

    final data = jsonDecode(resp.data) as Map<String, dynamic>;
    return PaymentIntentResult(
      clientSecret:    data['client_secret']     as String,
      paymentId:       data['payment_id']        as String,
      amountLkr:       (data['amount_lkr']       as num).toDouble(),
      platformFeeLkr:  (data['platform_fee_lkr'] as num? ?? 0).toDouble(),
      totalLkr:        (data['total_lkr']        as num? ?? data['amount_lkr'] as num).toDouble(),
    );
  }

  // ── Step 2: Present Stripe Payment Sheet ────────────────────────────────

  /// Returns true when tourist successfully enters card and payment is
  /// authorised (but NOT yet captured — capture happens on confirm).
  Future<bool> presentPaymentSheet({
    required String clientSecret,
    required double totalLkr,
    String merchantDisplayName = 'Yaloo',
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName:       merchantDisplayName,
          // Show exact amount to tourist
          // Note: amount shows in the currency the PaymentIntent was created in (USD)
          // You may want to show LKR amount separately in your UI
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;

    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        // Tourist dismissed the sheet — not an error
        return false;
      }
      throw Exception(e.error.localizedMessage ?? 'Payment failed');
    }
  }

  // ── Cancellation preview ─────────────────────────────────────────────────

  Future<CancellationPreview> getCancellationPreview({
    required String bookingType,
    required String bookingId,
  }) async {
    final resp = await _api.get(
      '/api/payment/cancellation-preview/'
          '?booking_type=$bookingType&booking_id=$bookingId',
    );

    if (resp.statusCode != 200) {
      final body = jsonDecode(resp.data);
      throw Exception(body['error'] ?? 'Failed to load cancellation info');
    }

    return CancellationPreview.fromJson(
      jsonDecode(resp.data) as Map<String, dynamic>,
    );
  }

  // ── Cancel booking with refund ───────────────────────────────────────────

  Future<CancelResult> cancelBooking({
    required String bookingType,
    required String bookingId,
  }) async {
    try {
      final resp = await _api.post('/api/payment/cancel/', data: {
        'booking_type': bookingType,
        'booking_id':   bookingId,
      });

      final body = jsonDecode(resp.data) as Map<String, dynamic>;

      if (resp.statusCode == 200) {
        return CancelResult(
          success:          true,
          message:          body['message']           as String? ?? 'Booking cancelled',
          refundAmountLkr:  (body['refund_amount_lkr'] as num? ?? 0).toDouble(),
          feeAmountLkr:     (body['fee_amount_lkr']    as num? ?? 0).toDouble(),
          refundNote:       body['refund_note']        as String? ?? '',
        );
      }

      return CancelResult(
        success: false,
        message: 'Cancellation failed',
        error:   body['error'] as String?,
      );

    } catch (e) {
      return CancelResult(success: false, message: 'Cancellation failed', error: e.toString());
    }
  }
}