import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';
import 'package:yaloo/core/widgets/custom_app_bar.dart';
import 'package:yaloo/core/widgets/floating_chat_button.dart';
import 'package:yaloo/core/widgets/step_progress_indicator.dart';
import 'package:yaloo/core/widgets/custom_text_field.dart';
import 'package:yaloo/core/widgets/custom_primary_button.dart';

// Enums for selection
enum TravelerType { solo, couple, group }

class TourInformationScreen extends StatefulWidget {
  const TourInformationScreen({super.key});

  @override
  State<TourInformationScreen> createState() => _TourInformationScreenState();
}

class _TourInformationScreenState extends State<TourInformationScreen> {
  // --- Form State ---
  TravelerType _travelerType = TravelerType.solo;

  final _meetingPointController = TextEditingController(text: 'Colombo');
  final _pickupTimeHourController = TextEditingController(text: '00');
  final _pickupTimeMinuteController = TextEditingController(text: '00');
  final _noteController = TextEditingController();
  final _hoursController = TextEditingController(text: '4'); // <-- NEW: For duration
  bool _isAm = true;

  // --- Validation ---
  bool _canConfirm = false;

  // --- Payment Summary Data (This would be calculated) ---
  final double _baseRate = 5.0; // Base rate per hour
  double _durationHours = 0.0;
  double _total = 0.0;

  int get _travelerCount {
    switch (_travelerType) {
      case TravelerType.solo:
        return 1;
      case TravelerType.couple:
        return 2;
      case TravelerType.group:
      // You can set this to any number, or add another text field for it
        return 5; // Example: Group rate is for 5 people
    }
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to all required controllers
    _meetingPointController.addListener(_validateForm);
    _pickupTimeHourController.addListener(_validateForm);
    _pickupTimeMinuteController.addListener(_validateForm);
    _noteController.addListener(_validateForm);
    _hoursController.addListener(_validateForm); // <-- ADDED
    _validateForm(); // Run once on init
  }

  @override
  void dispose() {
    _meetingPointController.dispose();
    _pickupTimeHourController.dispose();
    _pickupTimeMinuteController.dispose();
    _noteController.dispose();
    _hoursController.dispose(); // <-- ADDED
    super.dispose();
  }

  void _validateForm() {
    // Check if all mandatory fields are filled
    final bool fieldsAreValid = _meetingPointController.text.isNotEmpty &&
        _pickupTimeHourController.text.isNotEmpty &&
        _pickupTimeMinuteController.text.isNotEmpty &&
        _hoursController.text.isNotEmpty;

    // Calculate price
    _durationHours = double.tryParse(_hoursController.text) ?? 0;
    _total = _baseRate * _durationHours * _travelerCount;

    if (_canConfirm != fieldsAreValid) {
      setState(() {
        _canConfirm = fieldsAreValid;
      });
    } else {
      // Just update the price
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Tour Information',
        actions: [
          IconButton(
            onPressed: () { /* TODO: Show Help */ },
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
              // --- 1. Step Progress (Now on Step 2) ---
              StepProgressIndicator(
                currentStep: 1, // We are on the second step
                steps: const [
                  {'Details': FontAwesomeIcons.user},
                  {'Tour Info': FontAwesomeIcons.map},
                  {'Payment': FontAwesomeIcons.creditCard},
                ],
              ),

              // --- 2. Who's traveling ---
              _buildFormLabel("Who's traveling?"),
              _buildTravelerToggle(),
               SizedBox(height: 24.h),

              // --- 3. Duration (UPDATED) ---
              _buildFormLabel("Duration (in hours)"),
              CustomTextField(
                controller: _hoursController,
                hintText: 'e.g., 4',
                icon: FontAwesomeIcons.hourglassHalf,
                keyboardType: TextInputType.number, hint: '',
              ),
               SizedBox(height: 24.h),

              // --- 4. Form Fields ---
              _buildFormLabel("Meeting Point"),
              CustomTextField(
                controller: _meetingPointController,
                hintText: 'Enter a meeting point',
                icon: FontAwesomeIcons.mapLocationDot, hint: '',
              ),
               SizedBox(height: 16.h),
              _buildFormLabel("Pickup Time"),
              _buildTimePicker(),
               SizedBox(height: 16.h),
              _buildFormLabel("Note"),
              _buildNoteField(),
               SizedBox(height: 24.h),

              // --- 5. Payment Summary (UPDATED) ---
              _buildPaymentSummary(),
               SizedBox(height: 24.h),

              // --- 6. Confirm Button ---
              CustomPrimaryButton(
                text: 'Confirm',
                // UPDATED: Button is enabled/disabled
                onPressed: _canConfirm ? () {
                  // --- UPDATED: Navigate to Payment (Step 3) ---
                  Navigator.pushNamed(
                      context,
                      '/payment',
                      arguments: {
                        'total': _total,
                        'bookingType': 'guide',
                        // ... pass other booking data
                      }
                  );
                } : null,
              ),
               SizedBox(height: 20.h),
              _buildFaqLink(),
               SizedBox(height: 100.h), // Padding for chat button
            ],
          ),
        ),
      ),
      floatingActionButton: const FloatingChatButton(),
    );
  }

  // --- Helper Widgets for this page ---

  Widget _buildTravelerToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildSelectableCard(
            icon: FontAwesomeIcons.user,
            label: 'Solo',
            isSelected: _travelerType == TravelerType.solo,
            onTap: () => setState(() {
              _travelerType = TravelerType.solo;
              _validateForm(); // Re-calculate price
            }),
          ),
        ),
         SizedBox(width: 12.w),
        Expanded(
          child: _buildSelectableCard(
            icon: FontAwesomeIcons.userGroup,
            label: 'Couple',
            isSelected: _travelerType == TravelerType.couple,
            onTap: () => setState(() {
              _travelerType = TravelerType.couple;
              _validateForm(); // Re-calculate price
            }),
          ),
        ),
         SizedBox(width: 12.w),
        Expanded(
          child: _buildSelectableCard(
            icon: FontAwesomeIcons.users,
            label: 'Group',
            isSelected: _travelerType == TravelerType.group,
            onTap: () => setState(() {
              _travelerType = TravelerType.group;
              _validateForm(); // Re-calculate price
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
            width: 1.5.w,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryGray.withAlpha(20),
              blurRadius: 10.r,
              offset: Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 28.w),
             SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 16.w),
      child: Text.rich(
        TextSpan(
          text: label,
          style: AppTextStyles.textSmall.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold),
          children: [
            TextSpan(text: ' *', style: TextStyle(color: AppColors.primaryRed)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.clock, color: AppColors.primaryGray, size: 20.w),
          SizedBox(width: 16.w),
          SizedBox(
            width: 40.w,
            child: TextField(
              controller: _pickupTimeHourController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: 'HH',
                hintStyle: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray.withAlpha(150),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Text(':', style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(
            width: 40.w,
            child: TextField(
              controller: _pickupTimeMinuteController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 16.sp),
              decoration: InputDecoration(
                hintText: 'MM',
                hintStyle: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray.withAlpha(150),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Spacer(),
          ToggleButtons(
            isSelected: [_isAm, !_isAm],
            onPressed: (index) {
              setState(() {
                _isAm = index == 0;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            selectedColor: Colors.white,
            color: AppColors.primaryBlue,
            fillColor: AppColors.primaryBlue,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text('AM', style: AppTextStyles.textSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text('PM', style: AppTextStyles.textSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            'Payment Summary',
            style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
           SizedBox(height: 16.h),
          _buildDetailRow("Base Rate (per hour):", "\$${_baseRate.toStringAsFixed(0)}"),
          Divider(color: Colors.grey.shade300, height: 24.h),
          _buildDetailRow("Travelers:", _travelerCount.toString()),
          Divider(color: Colors.grey.shade300, height: 24.h),
          _buildDetailRow("Duration:", "${_durationHours.toStringAsFixed(0)}h"),
          Divider(color: Colors.grey.shade300, height: 24.h),
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
    final style = isTotal
        ? AppTextStyles.bodyLarge.copyWith(color: AppColors.primaryBlack, fontWeight: FontWeight.bold)
        : AppTextStyles.textSmall.copyWith(color: AppColors.primaryGray);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.primaryBlack,
            fontWeight: FontWeight.bold,
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
        onChanged: (_) => _validateForm(),
      ),
    );
  }
}