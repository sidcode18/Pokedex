import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.maxValue = 255,
  });

  final String label;
  final int value;
  final Color color;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              value.toString().padLeft(3, '0'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: color,
                backgroundColor: color.withValues(alpha: 0.18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
