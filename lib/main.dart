import 'package:flutter/material.dart';
import 'counter_page.dart';
import 'src/rust/frb_generated.dart';
import 'src/loader/load_rust_library.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init(
    externalLibrary: loadRustLibrary(),
  );

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
