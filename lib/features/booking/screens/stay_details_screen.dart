import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/core/widgets/step_progress_indicator.dart';
import 'package:yaloo/core/widgets/custom_text_area.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

class StayDetailsScreen extends StatefulWidget {
  const StayDetailsScreen({super.key});

  @override
  State<StayDetailsScreen> createState() => _StayDetailsScreenState();
}

class _StayDetailsScreenState extends State<StayDetailsScreen> {
  // --- State Variables ---
  int _bedCount = 2;
  int _roomCount = 2;
  String _selectedMeal = "Veg";
  final List<String> _mealOptions = ["Veg", "Non- Veg", "Halal"];

  // Time Input Controllers
  final _checkInHourController = TextEditingController();
  final _checkInMinuteController = TextEditingController(text: "00");
  bool _isCheckInAm = true;

  final _checkOutHourController = TextEditingController();
  final _checkOutMinuteController = TextEditingController(text: "00");
  bool _isCheckOutAm = true;

  final _noteController = TextEditingController();

  // --- Payment Data ---
  final double _baseRate = 10.0; // As per UI image ($10)
  final int _days = 2; // Mock days
  double get _total => _baseRate * _days;

  @override
  void dispose() {
    _checkInHourController.dispose();
    _checkInMinuteController.dispose();
    _checkOutHourController.dispose();
    _checkOutMinuteController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Stay Details',
        actions: [
          IconButton(
            onPressed: () { /* TODO: Help */ },
            icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryBlack, size: 24.w),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Step Progress ---
              const StepProgressIndicator(
                currentStep: 1,
                steps: [
                  {'Details': FontAwesomeIcons.user},
                  {'Stay Info': FontAwesomeIcons.house},
                  {'Payment': FontAwesomeIcons.creditCard},
                ],
              ),

              SizedBox(height: 24.h),

              // --- 2. Beds & Rooms Counters ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCounterGroup("Beds", FontAwesomeIcons.bed, _bedCount, (val) {
                    setState(() => _bedCount = val);
                  }),
                  SizedBox(width: 24.w),
                  _buildCounterGroup("Rooms", FontAwesomeIcons.doorOpen, _roomCount, (val) {
                    setState(() => _roomCount = val);
                  }),
                ],
              ),
              SizedBox(height: 24.h),

              // --- 3. Meal Preferences ---
              _buildSectionLabel("Meal Preferences", FontAwesomeIcons.utensils),
              SizedBox(height: 12.h),
              Row(
                children: _mealOptions.map((meal) {
                  final isSelected = _selectedMeal == meal;
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMeal = meal),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEBF2FA) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: isSelected ? AppColors.secondaryGray : Colors.transparent
                          ),
                        ),
                        child: Text(
                          meal,
                          style: AppTextStyles.textSmall.copyWith(
                            color: AppColors.primaryBlack,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // --- 4. Check-in / Check-out Time ---
              _buildTimeRow(
                  "Check-in Time",
                  FontAwesomeIcons.arrowRightToBracket,
                  _checkInHourController,
                  _checkInMinuteController,
                  _isCheckInAm,
                      (val) => setState(() => _isCheckInAm = val)
              ),
              SizedBox(height: 16.h),
              _buildTimeRow(
                  "Check-out Time",
                  FontAwesomeIcons.arrowRightFromBracket,
                  _checkOutHourController,
                  _checkOutMinuteController,
                  _isCheckOutAm,
                      (val) => setState(() => _isCheckOutAm = val)
              ),
              SizedBox(height: 24.h),

              // --- 5. Note Field ---
              _buildSectionLabel("Note", null, isRequired: false),
              _buildNoteField(),
              SizedBox(height: 32.h),

              // --- 6. Payment Summary ---
              _buildPaymentSummary(),
              SizedBox(height: 24.h),

              // --- 7. Confirm Button ---
              CustomPrimaryButton(
                text: 'CONFIRM',
                onPressed: () {
                  // Navigate to Payment
                  Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {
                        'total': _total,
                        'bookingType': 'host'
                        // ... other data
                      }
                  );
                },
              ),
              SizedBox(height: 16.h),

              // --- 8. FAQ Link ---
              _buildFaqLink(),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionLabel(String label, IconData? icon, {bool isRequired = false}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16.w, color: AppColors.primaryBlack),
          SizedBox(width: 8.w),
        ],
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: AppColors.primaryBlack, fontSize: 16.sp),
            children: [
              if (isRequired)
                TextSpan(text: ' *', style: TextStyle(color: AppColors.primaryRed))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterGroup(String label, IconData icon, int value, Function(int) onChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel(label, icon),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF2FA), // Light blue-ish gray
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: value > 0 ? () => onChanged(value - 1) : null,
                  child: Icon(Icons.remove, size: 18.w, color: AppColors.primaryBlack),
                ),
                Text(
                  '$value',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () => onChanged(value + 1),
                  child: Icon(Icons.add, size: 18.w, color: AppColors.primaryBlack),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, IconData icon, TextEditingController hourCtrl, TextEditingController minCtrl, bool isAm, Function(bool) onAmChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label, icon),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Hour Box
            Container(
              width: 50.w,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFA0C4FF)), // Light blue border
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: TextField(
                  controller: hourCtrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "|",
                    hintStyle: TextStyle(color: AppColors.primaryGray),
                  ),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(":", style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            ),
            // Minute Box (Grey filled)
            Container(
              width: 50.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFEAEAEA),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: TextField(
                  controller: minCtrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  readOnly: true, // As per image seems static/disabled
                  decoration: const InputDecoration(border: InputBorder.none),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // AM/PM Toggle
            Container(
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Row(
                children: [
                  _buildAmPmBtn("AM", isAm, () => onAmChanged(true)),
                  _buildAmPmBtn("PM", !isAm, () => onAmChanged(false)),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildAmPmBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: isSelected ? const Color(0xFF0056D2) : Colors.transparent, // Dark Blue if selected
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryBlack,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Payment Summary',
                style: AppTextStyles.bodyLarge.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildDetailRow("Base Rate (per night):", "\$${_baseRate.toStringAsFixed(0)}"),
          SizedBox(height: 8.h),
          _buildDetailRow("days:", "$_days"),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 8.h),
          _buildDetailRow(
            "Total:",
            "\$${_total.toStringAsFixed(0)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            title,
            style: TextStyle(
                fontSize: isTotal ? 16.sp : 14.sp,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: AppColors.primaryBlack
            )
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: AppColors.primaryBlack
          ),
        ),
      ],
    );
  }

  Widget _buildFaqLink() {
    return Center(
      child: TextButton.icon(
        onPressed: () { /* TODO: Open FAQs */ },
        icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryGray, size: 16.w),
        label: Text(
          'FAQs & Help',
          style: AppTextStyles.textSmall.copyWith(
            color: AppColors.primaryGray,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }


  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.secondaryGray),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: TextField(
        controller: _noteController,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Write your note here...',
          // prefixIcon: Icon(FontAwesomeIcons.noteSticky, color: AppColors.primaryGray),
          border: InputBorder.none,
        ),
      ),
    );
  }
}