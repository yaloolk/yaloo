import 'package:flutter/material.dart';
import 'package:yaloo/core/constants/colors.dart';
import 'package:yaloo/core/constants/app_text_styles.dart';

class CustomUploadButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? fileName;
  final VoidCallback onPressed;

  const CustomUploadButton({
    Key? key,
    required this.label,
    required this.icon,
    this.fileName,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isUploaded = fileName != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isUploaded ? AppColors.thirdBlue : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isUploaded ? Border.all(color: AppColors.primaryBlue) : null,
          boxShadow: [
            if (!isUploaded)
              BoxShadow(
                color: AppColors.primaryGray.withAlpha(20),
                blurRadius: 20,
                offset: Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                isUploaded ? Icons.check_circle_outline : icon,
                color: isUploaded ? AppColors.primaryBlue : AppColors.primaryGray
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                isUploaded ? fileName! : label, // Show file name
                style: AppTextStyles.textSmall.copyWith(
                    color: isUploaded ? AppColors.primaryBlue : AppColors.primaryGray,
                    fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}