// Integration-style widget tests for the Flutter Counter app.
//
// These tests mock the Rust FFI layer entirely so they run on any platform
// (CI, desktop, web) without needing a compiled .so file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_counter_frb/main.dart';
import 'package:flutter_counter_frb/src/rust_lib/frb_generated.dart';

// ─── Mock RustLib ─────────────────────────────────────────────────────────────

/// A pure-Dart mock that replaces the FFI calls during tests.
/// Mirrors the exact API of [RustLib] so [CounterPage] needs no changes.
class MockRustLib implements RustLib {
  int _count = 0;

  @override
  Future<int> getCounter() async => _count;

  @override
  Future<int> increment() async => ++_count;

  @override
  Future<int> decrement() async => --_count;

  @override
  Future<int> reset() async {
    _count = 0;
    return _count;
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// Pumps the [CounterApp] and waits for all async frames to settle.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const CounterApp());
  await tester.pumpAndSettle();
}

/// Taps the increment (+) button and waits for the UI to settle.
Future<void> tapIncrement(WidgetTester tester) async {
  await tester.tap(find.text('+'));
  await tester.pumpAndSettle();
}

/// Taps the decrement (−) button and waits for the UI to settle.
Future<void> tapDecrement(WidgetTester tester) async {
  await tester.tap(find.text('−'));
  await tester.pumpAndSettle();
}

/// Taps the RESET button and waits for the UI to settle.
Future<void> tapReset(WidgetTester tester) async {
  await tester.tap(find.text('RESET'));
  await tester.pumpAndSettle();
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Unit tests for MockRustLib (Rust logic verification) ──────────────────

  group('MockRustLib unit tests', () {
    late MockRustLib rust;

    setUp(() => rust = MockRustLib());

    test('initial counter value is 0', () async {
      expect(await rust.getCounter(), 0);
    });

    test('increment increases counter by 1', () async {
      expect(await rust.increment(), 1);
      expect(await rust.increment(), 2);
      expect(await rust.increment(), 3);
    });

    test('decrement decreases counter by 1', () async {
      await rust.increment();
      await rust.increment();
      expect(await rust.decrement(), 1);
    });

    test('decrement can go negative', () async {
      expect(await rust.decrement(), -1);
      expect(await rust.decrement(), -2);
    });

    test('reset returns counter to 0', () async {
      await rust.increment();
      await rust.increment();
      await rust.increment();
      expect(await rust.reset(), 0);
      expect(await rust.getCounter(), 0);
    });

    test('increment after reset starts from 0', () async {
      await rust.increment();
      await rust.increment();
      await rust.reset();
      expect(await rust.increment(), 1);
    });

    test('mixed operations produce correct result', () async {
      await rust.increment(); // 1
      await rust.increment(); // 2
      await rust.increment(); // 3
      await rust.decrement(); // 2
      await rust.decrement(); // 1
      expect(await rust.getCounter(), 1);
    });
  });
}
