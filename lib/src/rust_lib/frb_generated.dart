// AUTO-GENERATED FILE — do not edit by hand.
// Run `flutter_rust_bridge_codegen generate` to regenerate.
//
// This file is a simplified hand-written version matching what
// flutter_rust_bridge v2 generates. In a real project, run the codegen tool.

// ignore_for_file: unused_import, unused_field, non_constant_identifier_names

import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';

// ─── Typedefs ──────────────────────────────────────────────────────────────

typedef _GetCounterNative = ffi.Int64 Function();
typedef _GetCounterDart = int Function();

typedef _IncrementNative = ffi.Int64 Function();
typedef _IncrementDart = int Function();

typedef _DecrementNative = ffi.Int64 Function();
typedef _DecrementDart = int Function();

typedef _ResetNative = ffi.Int64 Function();
typedef _ResetDart = int Function();

// ─── Load the shared library ───────────────────────────────────────────────

ffi.DynamicLibrary _loadLib() {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open('librust_lib.so');
  } else if (Platform.isIOS) {
    // Static lib is linked into the app binary at compile time.
    // process() looks up symbols from the running executable itself.
    return ffi.DynamicLibrary.process();
  } else if (Platform.isMacOS) {
    return ffi.DynamicLibrary.open('librust_lib.dylib');
  } else if (Platform.isWindows) {
    return ffi.DynamicLibrary.open('rust_lib.dll');
  } else if (Platform.isLinux) {
    return ffi.DynamicLibrary.open('librust_lib.so');
  }
  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
}

// ─── Singleton wrapper ─────────────────────────────────────────────────────

class RustLib {
  RustLib._();
  static final RustLib _instance = RustLib._();
  static RustLib get instance => _instance;

  late final ffi.DynamicLibrary _lib = _loadLib();

  late final _GetCounterDart _getCounter = _lib.lookupFunction<_GetCounterNative, _GetCounterDart>('get_counter');

  late final _IncrementDart _increment = _lib.lookupFunction<_IncrementNative, _IncrementDart>('increment');

  late final _DecrementDart _decrement = _lib.lookupFunction<_DecrementNative, _DecrementDart>('decrement');

  late final _ResetDart _reset = _lib.lookupFunction<_ResetNative, _ResetDart>('reset');

  Future<int> getCounter() async => _getCounter();
  Future<int> increment() async => _increment();
  Future<int> decrement() async => _decrement();
  Future<int> reset() async => _reset();
}