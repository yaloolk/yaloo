import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

/// The main navigation button (Text + Circle Button) for multi-page forms.
class CircularNavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CircularNavButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTextStyles.headlineLarge.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 15),
        ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isLoading ? AppColors.primaryGray : AppColors.primaryBlue,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.arrow_forward, color: Colors.white, size: 28,),
        ),
      ],
    );
  }
}