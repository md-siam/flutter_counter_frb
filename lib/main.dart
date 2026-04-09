import 'package:flutter/material.dart';
import 'counter_page.dart';

void main() {
  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rust Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF1A1A2E),
        ),
        useMaterial3: true,
        fontFamily: 'Courier New',
      ),
      home: const CounterPage(),
    );
  }
}
