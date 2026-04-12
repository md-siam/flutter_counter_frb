import 'dart:async';

import 'package:flutter/material.dart';

import 'rust_lib/api.dart';
import 'widgets/counter_button.dart';
import 'widgets/info_bar.dart';
import 'widgets/rust_badge.dart';

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

  Timer? _longPressTimer;

  static const _longPressInterval = Duration(milliseconds: 100);

  static const _longPressInitialDelay = Duration(milliseconds: 400);

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

    getCounter().then((v) {
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
    _cancelLongPress();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pulse() async {
    await _animController.forward();
    await _animController.reverse();
  }

  Future<void> _increment() async {
    final v = await increment();
    _pulse();
    if (mounted) setState(() => _count = v);
  }

  Future<void> _decrement() async {
    final v = await decrement();
    _pulse();
    if (mounted) setState(() => _count = v);
  }

  Future<void> _reset() async {
    final v = await reset();
    if (mounted) setState(() => _count = v);
  }

  void _startLongPress(Future<void> Function() action) {
    action();

    Future.delayed(_longPressInitialDelay, () {
      if (!mounted) return;

      _longPressTimer = Timer.periodic(_longPressInterval, (_) {
        action();
      });
    });
  }

  void _cancelLongPress() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  Color get _countColor {
    if (_count > 0) return Colors.tealAccent;
    if (_count < 0) return Colors.redAccent;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RUST COUNTER',
                        style: TextStyle(
                          fontSize: 15,
                          letterSpacing: 3,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Powered by: \nffi + flutter_rust_bridge',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  RustBadge(),
                ],
              ),
            ),
            const Spacer(),
            _loading
                ? const CircularProgressIndicator(color: Colors.tealAccent)
                : ScaleTransition(
                    scale: _scaleAnim,
                    child: Column(
                      children: [
                        Text(
                          _count.toString(),
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
                            fontSize: 16,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  CounterButton(
                    label: '−',
                    color: Colors.redAccent,
                    onTap: _decrement,
                    onLongPressStart: () => _startLongPress(_decrement),
                    onLongPressEnd: _cancelLongPress,
                  ),
                  const SizedBox(width: 16),
                  CounterButton(
                    label: '+',
                    color: Colors.tealAccent,
                    onTap: _increment,
                    onLongPressStart: () => _startLongPress(_increment),
                    onLongPressEnd: _cancelLongPress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: InfoBar(count: _count),
            ),
          ],
        ),
      ),
    );
  }
}
