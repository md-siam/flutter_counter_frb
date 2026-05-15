import 'dart:async';

import 'package:flutter/material.dart';

import 'src/rust/api.dart';
import 'widgets/header.dart';
import 'widgets/counter_button.dart';
import 'widgets/info_bar.dart';

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

    _loadCounter();
  }

  @override
  void dispose() {
    _cancelLongPress();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCounter() async {
    final value = await getCounter();

    setState(() {
      _count = value;
      _loading = false;
    });
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
            const Header(),
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
                  ),
                  const SizedBox(width: 16),
                  CounterButton(
                    label: '+',
                    color: Colors.tealAccent,
                    onTap: _increment,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _count == 0 ? null : _reset,
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
            InfoBar(count: _count),
          ],
        ),
      ),
    );
  }
}
