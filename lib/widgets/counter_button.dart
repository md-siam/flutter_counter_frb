import 'package:flutter/material.dart';

class CounterButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const CounterButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
