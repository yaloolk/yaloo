import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

// For Country, DOB, Gender, Language
class CustomPickerButton extends StatelessWidget {
  final String hint;
  final IconData icon;
  final String? value;
  final VoidCallback onTap;

  const CustomPickerButton({
    Key? key,
    required this.hint,
    required this.icon,
    this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null && value!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20, right: 12),
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
            Icon(icon, color: AppColors.primaryGray),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                hasValue ? value! : hint,
                style: AppTextStyles.textSmall.copyWith(
                  color: hasValue
                      ? Colors.black
                      : AppColors.primaryGray.withAlpha(150),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.primaryGray),
          ],
        ),
      ),
    );
  }
}