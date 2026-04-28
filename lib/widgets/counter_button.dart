import 'package:flutter/material.dart';

class CounterButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const CounterButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        onLongPressStart: (_) => onLongPressStart(),
        onLongPressEnd: (_) => onLongPressEnd(),
        onLongPressCancel: onLongPressEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 72,
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
            borderRadius: BorderRadius.circular(16),
            color: color.withValues(alpha: 0.08),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                height: 1,
                fontSize: 36,
                color: color,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
