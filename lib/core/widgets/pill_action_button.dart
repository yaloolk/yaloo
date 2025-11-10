import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

/// The main action button (Text + Pill Button) for Login/Signup.
class PillActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Nullable for disabled state
  final bool isLoading;

  const PillActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            disabledBackgroundColor: AppColors.primaryGray.withAlpha(100),
            shape: const StadiumBorder(), // This makes it a "pill"
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          child: isLoading
              ? const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
              : const Icon(Icons.arrow_forward, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}