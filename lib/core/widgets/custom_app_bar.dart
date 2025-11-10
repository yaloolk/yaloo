import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      // Use the provided leading widget, or default to a back arrow
      leading: leading ?? IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(CupertinoIcons.left_chevron, color: AppColors.primaryBlack, size: 24),
      ),
      title: Text(
        title,
        style: AppTextStyles.headlineLargeBlack.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: actions,
    );
  }

  // This is required to make AppBar work as a PreferredSizeWidget
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}