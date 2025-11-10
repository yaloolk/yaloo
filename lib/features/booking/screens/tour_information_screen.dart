import 'package:flutter/material.dart';
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
            icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryBlack, size: 24),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(height: 24),

              // --- 3. Duration (UPDATED) ---
              _buildFormLabel("Duration (in hours)"),
              CustomTextField(
                controller: _hoursController,
                hintText: 'e.g., 4',
                icon: FontAwesomeIcons.hourglassHalf,
                keyboardType: TextInputType.number, hint: '',
              ),
              const SizedBox(height: 24),

              // --- 4. Form Fields ---
              _buildFormLabel("Meeting Point"),
              CustomTextField(
                controller: _meetingPointController,
                hintText: 'Enter a meeting point',
                icon: FontAwesomeIcons.mapLocationDot, hint: '',
              ),
              const SizedBox(height: 16),
              _buildFormLabel("Pickup Time"),
              _buildTimePicker(),
              const SizedBox(height: 16),
              _buildFormLabel("Note"),
              _buildNoteField(),
              const SizedBox(height: 24),

              // --- 5. Payment Summary (UPDATED) ---
              _buildPaymentSummary(),
              const SizedBox(height: 24),

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
                        // ... pass other booking data
                      }
                  );
                } : null,
              ),
              const SizedBox(height: 20),
              _buildFaqLink(),
              const SizedBox(height: 100), // Padding for chat button
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
        const SizedBox(width: 12),
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
        const SizedBox(width: 12),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.secondaryGray,
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primaryGray.withAlpha(20),
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ] : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 28),
            const SizedBox(height: 8),
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
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Icon(FontAwesomeIcons.clock, color: AppColors.primaryGray, size: 20),
          SizedBox(width: 16),
          SizedBox(
            width: 40,
            child: TextField(
              controller: _pickupTimeHourController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'HH',
                hintStyle: AppTextStyles.textSmall.copyWith(
                  color: AppColors.primaryGray.withAlpha(150),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Text(':', style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            width: 40,
            child: TextField(
              controller: _pickupTimeMinuteController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.textSmall.copyWith(color: Colors.black, fontSize: 16),
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
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            color: AppColors.primaryBlue,
            fillColor: AppColors.primaryBlue,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text('AM', style: AppTextStyles.textSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Payment Summary',
            style: AppTextStyles.headlineLargeBlack.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Base Rate (per hour):", "\$${_baseRate.toStringAsFixed(0)}"),
          Divider(color: Colors.grey.shade300, height: 24),
          _buildDetailRow("Travelers:", _travelerCount.toString()),
          Divider(color: Colors.grey.shade300, height: 24),
          _buildDetailRow("Duration:", "${_durationHours.toStringAsFixed(0)}h"),
          Divider(color: Colors.grey.shade300, height: 24),
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
        icon: Icon(FontAwesomeIcons.circleQuestion, color: AppColors.primaryGray, size: 16),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGray.withAlpha(20),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
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