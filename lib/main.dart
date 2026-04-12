import 'package:flutter/material.dart';
import 'counter_page.dart';
import 'rust_lib/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the flutter_rust_bridge before any Rust functions are called.
  // This sets up the FFI bindings and the async runtime on the Rust side.
  await RustLib.init();
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
