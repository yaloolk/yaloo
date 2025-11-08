import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
  }) : super(key: key);

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
        icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.primaryBlack, size: 24),
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