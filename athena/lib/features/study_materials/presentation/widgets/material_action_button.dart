import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MaterialActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const MaterialActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.athenaPurple,
        side: BorderSide(color: AppColors.athenaPurple),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}