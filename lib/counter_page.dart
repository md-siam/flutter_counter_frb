import 'package:flutter/material.dart';
import 'src/rust_lib/frb_generated.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> with SingleTickerProviderStateMixin {
  int _count = 0;
  bool _loading = true;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final _rust = RustLib.instance;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _rust.getCounter().then((v) {
      if (mounted) {
        setState(() {
          _count = v;
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pulse() async {
    await _animController.forward();
    await _animController.reverse();
  }

  Future<void> _increment() async {
    final v = await _rust.increment();
    _pulse();
    if (mounted) setState(() => _count = v);
  }

  Future<void> _decrement() async {
    final v = await _rust.decrement();
    _pulse();
    if (mounted) setState(() => _count = v);
  }

  Future<void> _reset() async {
    final v = await _rust.reset();
    if (mounted) setState(() => _count = v);
  }

  Color get _countColor {
    if (_count > 0) return const Color(0xFF4ECCA3);
    if (_count < 0) return const Color(0xFFFF6B6B);
    return const Color(0xFFECECEC);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RUST COUNTER',
                        style: TextStyle(
                          color: Color(0xFF4ECCA3),
                          fontSize: 14,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Powered by: \n' 'ffi + flutter_rust_bridge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  _RustBadge(),
                ],
              ),
            ),

            const Spacer(),

            // ── Counter display ─────────────────────────────────
            _loading
                ? const CircularProgressIndicator(color: Color(0xFF4ECCA3))
                : ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      children: [
                        Text(
                          _count >= 0 ? _count.toString() : _count.toString(),
                          style: TextStyle(
                            color: _countColor,
                            fontSize: 96,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -4,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _count == 0
                              ? 'zero'
                              : _count > 0
                                  ? 'positive'
                                  : 'negative',
                          style: TextStyle(
                            color: _countColor,
                            fontSize: 14,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 48),

            // ── Buttons ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  _CounterButton(
                    label: '−',
                    color: const Color(0xFFFF6B6B),
                    onTap: _decrement,
                  ),
                  const SizedBox(width: 16),
                  _CounterButton(
                    label: '+',
                    color: const Color(0xFF4ECCA3),
                    onTap: _increment,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Reset ────────────────────────────────────────────
            TextButton(
              onPressed: _reset,
              child: const Text(
                'RESET',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ),
            ),

            const Spacer(),

            // ── Footer — Rust/FFI info ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _InfoBar(count: _count),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub widgets ──────────────────────────────────────────────────────────────

class _CounterButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CounterButton({
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
                color: color,
                fontSize: 36,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RustBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFCE412B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFCE412B).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFFCE412B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Rust',
            style: TextStyle(
              color: Color(0xFFCE412B),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  final int count;
  const _InfoBar({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          const _InfoCell(label: 'binding', value: 'FFI'),
          _vDivider(),
          const _InfoCell(label: 'bridge', value: 'frb v2'),
          _vDivider(),
          const _InfoCell(label: 'language', value: 'Rust'),
          _vDivider(),
          _InfoCell(label: 'value', value: count.toString()),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4ECCA3),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
