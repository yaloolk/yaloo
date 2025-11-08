import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon; // We accept a full Icon widget for more flexibility
  final VoidCallback onPressed;

  const CustomIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

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
        padding: const EdgeInsets.all(10),
        shadowColor: Colors.black.withOpacity(0.2),
      ),
    );
  }
}