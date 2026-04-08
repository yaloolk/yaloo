// lib/features/tourist/widgets/cancellation_bottom_sheet.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/services/payment_service.dart';

const _blue  = Color(0xFF2563EB);
const _dark  = Color(0xFF1F2937);
const _gray  = Color(0xFF6B7280);
const _green = Color(0xFF10B981);
const _amber = Color(0xFFF59E0B);
const _red   = Color(0xFFEF4444);

/// Call this function from any screen to show the cancel sheet.
///
/// Returns [CancelResult] when tourist confirms, or null if they dismiss.
///
/// Example:
/// ```dart
/// final result = await showCancellationSheet(
///   context:     context,
///   bookingType: 'guide',
///   bookingId:   booking.id,
/// );
/// if (result != null && result.success) {
///   // refresh list, show snack bar, etc.
/// }
/// ```
Future<CancelResult?> showCancellationSheet({
  required BuildContext context,
  required String       bookingType,   // 'guide' | 'stay'
  required String       bookingId,
}) async {
  return showModalBottomSheet<CancelResult>(
    context:           context,
    isScrollControlled: true,
    backgroundColor:   Colors.transparent,
    builder: (_) => _CancellationSheet(
      bookingType: bookingType,
      bookingId:   bookingId,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _CancellationSheet extends StatefulWidget {
  final String bookingType;
  final String bookingId;
  const _CancellationSheet({
    required this.bookingType,
    required this.bookingId,
  });
  @override State<_CancellationSheet> createState() => _CancellationSheetState();
}

class _CancellationSheetState extends State<_CancellationSheet> {

  final _service = PaymentService();

  bool                  _loading      = true;
  bool                  _cancelling   = false;
  String                _error        = '';
  CancellationPreview?  _preview;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final preview = await _service.getCancellationPreview(
        bookingType: widget.bookingType,
        bookingId:   widget.bookingId,
      );
      if (mounted) setState(() { _preview = preview; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _confirmCancel() async {
    setState(() => _cancelling = true);
    final result = await _service.cancelBooking(
      bookingType: widget.bookingType,
      bookingId:   widget.bookingId,
    );
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle bar
        Center(child: Container(
          width: 40.w, height: 4.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2.r),
          ),
        )),
        SizedBox(height: 20.h),

        // Title
        Text('Cancel Booking', style: TextStyle(
          fontSize: 18.sp, fontWeight: FontWeight.w800, color: _dark,
        )),
        SizedBox(height: 6.h),
        Text('Review the cancellation policy before confirming.',
            style: TextStyle(color: _gray, fontSize: 12.sp),
            textAlign: TextAlign.center),
        SizedBox(height: 20.h),

        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: CircularProgressIndicator(),
          )
        else if (_error.isNotEmpty)
          _errorCard()
        else if (_preview != null)
            _previewContent(_preview!),
      ]),
    );
  }

  Widget _errorCard() => Column(children: [
    Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _red.withOpacity(0.3)),
      ),
      child: Text(_error, style: TextStyle(color: _red, fontSize: 13.sp)),
    ),
    SizedBox(height: 16.h),
    _outlineBtn('Close', () => Navigator.pop(context), color: _gray),
  ]);

  Widget _previewContent(CancellationPreview p) => Column(children: [
    // Tier indicator
    _tierBadge(p),
    SizedBox(height: 16.h),

    // Time info
    _infoRow(CupertinoIcons.clock, 'Hours until booking',
        '${p.hoursBeforeStart.toStringAsFixed(1)}h'),
    _divider(),
    _infoRow(CupertinoIcons.money_dollar_circle, 'Booking total',
        'LKR ${p.originalAmountLkr.toStringAsFixed(0)}'),

    if (p.feePercent > 0) ...[
      _divider(),
      _infoRow(FontAwesomeIcon.ban, 'Cancellation fee (${p.feePercent.toStringAsFixed(0)}%)',
          '− LKR ${p.feeAmountLkr.toStringAsFixed(0)}',
          valueColor: _red),
    ],

    _divider(),
    _infoRow(CupertinoIcons.arrow_down_circle_fill, 'You will receive',
        'LKR ${p.refundAmountLkr.toStringAsFixed(0)}',
        valueColor: p.refundAmountLkr > 0 ? _green : _red,
        bold: true),

    SizedBox(height: 12.h),

    // Policy note
    Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _policyBgColor(p.tier),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(p.policyDescription,
          style: TextStyle(
              color: _policyTextColor(p.tier),
              fontSize: 11.sp, height: 1.5)),
    ),

    SizedBox(height: 24.h),

    // Refund timeline note
    if (p.refundAmountLkr > 0)
      Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Text(
          'Refunds take 5–10 business days to appear on your card.',
          style: TextStyle(color: _gray, fontSize: 10.sp),
          textAlign: TextAlign.center,
        ),
      ),

    // Action buttons
    if (_cancelling)
      const CircularProgressIndicator()
    else ...[
      SizedBox(
        width: double.infinity, height: 50.h,
        child: ElevatedButton(
          onPressed: _confirmCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: _red,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            elevation: 0,
          ),
          child: Text(
            p.refundAmountLkr > 0
                ? 'Cancel & Refund LKR ${p.refundAmountLkr.toStringAsFixed(0)}'
                : 'Cancel (No Refund)',
            style: TextStyle(color: Colors.white, fontSize: 14.sp,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
      SizedBox(height: 10.h),
      _outlineBtn('Keep My Booking', () => Navigator.pop(context)),
    ],
  ]);

  Widget _tierBadge(CancellationPreview p) {
    final color  = p.isFree ? _green : p.isPartial ? _amber : _red;
    final text   = p.isFree
        ? '✓ Free cancellation'
        : p.isPartial
        ? '${p.feePercent.toStringAsFixed(0)}% cancellation fee'
        : 'No refund available';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 15.sp,
              fontWeight: FontWeight.w800)),
    );
  }

  Widget _infoRow(dynamic icon, String label, String value, {
    Color? valueColor, bool bold = false,
  }) => Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(children: [
      Icon(icon as IconData, color: _blue, size: 15.w),
      SizedBox(width: 10.w),
      Text(label, style: TextStyle(color: _gray, fontSize: 12.sp)),
      const Spacer(),
      Text(value, style: TextStyle(
        color: valueColor ?? _dark,
        fontSize: 13.sp,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
      )),
    ]),
  );

  Widget _divider() => Divider(color: Colors.grey.shade100, height: 1.h);

  Widget _outlineBtn(String label, VoidCallback onTap, {Color? color}) =>
      SizedBox(
        width: double.infinity, height: 48.h,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? _blue,
            side: BorderSide(color: (color ?? _blue).withOpacity(0.4)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r)),
          ),
          child: Text(label, style: TextStyle(
              fontSize: 14.sp, fontWeight: FontWeight.w600)),
        ),
      );

  Color _policyBgColor(String tier) {
    if (tier == 'free')    return _green.withOpacity(0.08);
    if (tier == 'partial') return _amber.withOpacity(0.08);
    return _red.withOpacity(0.08);
  }

  Color _policyTextColor(String tier) {
    if (tier == 'free')    return const Color(0xFF065F46);
    if (tier == 'partial') return const Color(0xFF92400E);
    return const Color(0xFF991B1B);
  }
}

// Simple icon wrapper so we can pass FontAwesome icons
class FontAwesomeIcon {
  static const ban = CupertinoIcons.xmark_circle_fill;
}