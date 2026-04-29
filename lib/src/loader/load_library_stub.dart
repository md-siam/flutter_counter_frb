//
// Stub implementation for Flutter Web.
// Returns null since web doesn't use ExternalLibrary —
// RustLib.init() with null lets flutter_rust_bridge handle
// web WASM loading automatically.

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

ExternalLibrary? loadRustLibrary() {
  // Web does not support dart:ffi.
  // Returning null tells flutter_rust_bridge to use
  // its built-in WASM loader for web.
  return null;
}
