import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type, this.compact = true});

  final String type;
  final bool compact;

  String get _label {
    if (type.isEmpty) return '';
    return type[0].toUpperCase() + type.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final color = TypeColors.of(type);
    final foreground = color.computeLuminance() > 0.65
        ? const Color(0xFF1D1D1D)
        : Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 12 : 16,
            height: compact ? 12 : 16,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.circle, size: compact ? 8 : 10, color: color),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: foreground,
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
