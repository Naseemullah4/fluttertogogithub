import 'package:flutter/material.dart';

class BadgePill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  BadgePill({
    super.key,
    required this.label,
    Color? backgroundColor,
    Color? textColor,
    Color? color,
    this.icon,
  })  : backgroundColor = backgroundColor ?? (color != null ? color.withValues(alpha: 0.12) : const Color(0xFFF1F5F9)),
        textColor = textColor ?? (color ?? const Color(0xFF334155));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
