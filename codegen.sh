#!/usr/bin/env bash
# codegen.sh — Regenerate Dart FFI bindings from Rust source
#
# Deletes existing generated files first to avoid "File exists" errors,
# then runs flutter_rust_bridge_codegen to regenerate fresh bindings.

set -euo pipefail

echo "🗑️  Removing existing generated files..."
rm -f lib/rust_lib/frb_generated.dart
rm -f lib/rust_lib/frb_generated.io.dart
rm -f lib/rust_lib/frb_generated.web.dart
rm -rf .dart_tool/

echo "⚙️  Running flutter_rust_bridge_codegen..."
flutter_rust_bridge_codegen generate

flutter pub get

echo "✅ Codegen complete!"
