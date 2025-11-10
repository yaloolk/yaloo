import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon; // We accept a full Icon widget for more flexibility
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      // This is your style, applied to all buttons that use this widget
      style: IconButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.white,
        elevation: 8,
        padding: EdgeInsets.all(10.w),
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
    );
  }
}