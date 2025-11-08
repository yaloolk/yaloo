import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:yaloo/core/constants/colors.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(100),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          // TODO: Open Chat AI
        },
        icon: Icon(LucideIcons.bot, color: Colors.white, size: 32),
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}
