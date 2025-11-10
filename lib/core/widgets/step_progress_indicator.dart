import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<Map<String, IconData>> steps;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        children: _buildSteps(),
      ),
    );
  }

  List<Widget> _buildSteps() {
    List<Widget> stepWidgets = [];
    for (int i = 0; i < steps.length; i++) {
      // --- FIXED ---
      // 'steps' is a List, so we access it by index.
      final Map<String, IconData> stepMap = steps[i];
      // Each item in the list is a Map with one entry.
      // We get the first (and only) entry from that map.
      final MapEntry<String, IconData> step = stepMap.entries.first;
      // --- END FIX ---

      final bool isActive = i == currentStep;
      final bool isCompleted = i < currentStep;

      // Add the step (Icon + Label)
      stepWidgets.add(
        _buildStep(
          icon: step.value, // Now this is correct (the IconData)
          label: step.key,   // Now this is correct (the String label)
          isActive: isActive,
          isCompleted: isCompleted,
        ),
      );

      // Add a connector line between steps
      if (i < steps.length - 1) {
        stepWidgets.add(
          _buildConnector(isCompleted: isCompleted),
        );
      }
    }
    return stepWidgets;
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    final color =
    isActive || isCompleted ? AppColors.primaryBlue : AppColors.secondaryGray;

    return Column(
      children: [
        Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 2.w,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : color,
            size: 20.w,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: AppTextStyles.textSmall.copyWith(
            color: isActive || isCompleted
                ? AppColors.primaryBlack
                : AppColors.primaryGray,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2.h,
        color: isCompleted ? AppColors.primaryBlue : AppColors.secondaryGray,
        margin: EdgeInsets.only(bottom: 28.h), // Aligns with icons
      ),
    );
  }
}