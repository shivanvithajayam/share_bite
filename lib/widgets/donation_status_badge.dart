import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DonationStatusBadge extends StatelessWidget {
  final String status;
  const DonationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label = status.toUpperCase();
    switch (status) {
      case 'accepted':
        bg = AppColors.mint;
        fg = AppColors.tealDark;
        break;
      case 'rejected':
        bg = const Color(0xFFFFEBEE);
        fg = const Color(0xFFC62828);
        break;
      default:
        bg = AppColors.blush;
        fg = AppColors.roseDark;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
