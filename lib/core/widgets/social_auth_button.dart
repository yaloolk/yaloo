import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';

class SocialAuthButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;

  const SocialAuthButton({
    Key? key,
    required this.iconPath,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        side: BorderSide(color: AppColors.secondaryGray),
      ),
      child: Image.asset(
        iconPath,
        height: 28,
        width: 28,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.public, color: AppColors.primaryGray, size: 28);
        },
      ),
    );
  }
}