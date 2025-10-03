import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final double? fontSize;
  final bool showArrow;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.fontSize,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.primaryYellow).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryYellow,
          foregroundColor: textColor ?? Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (showArrow)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (index) {
                    final opacity = 0.3 + (index * 0.35);
                    return Padding(
                      padding: EdgeInsets.only(left: index * 3.0),
                      child: Icon(
                        Icons.chevron_right,
                        size: 22,
                        color: (textColor ?? Colors.black).withOpacity(opacity),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}