#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUST_DIR="$PROJECT_DIR/rust"

echo "🌐 Building Rust library for Flutter Web..."
echo "   Project dir : $PROJECT_DIR"
echo "   Rust dir    : $RUST_DIR"
echo ""

cd "$PROJECT_DIR"

# ── Step 1: Install required Rust WASM target ────────────────────────────────
echo "🎯 Adding Rust WASM target..."
rustup target add wasm32-unknown-unknown

# ── Step 2: Ensure wasm-pack is installed ────────────────────────────────────
if ! command -v wasm-pack >/dev/null 2>&1; then
  echo "📦 Installing wasm-pack..."
  cargo install wasm-pack
else
  echo "✅ wasm-pack already installed"
fi

# ── Step 3: Generate Flutter Rust Bridge files ───────────────────────────────
echo ""
echo "⚙️ Generating Flutter Rust Bridge code..."
flutter_rust_bridge_codegen generate

# ── Step 4: Build Rust for WebAssembly ───────────────────────────────────────
echo ""
echo "🦀 Building Rust WASM for Flutter Web..."
dart run flutter_rust_bridge build-web \
  --dart-root "$PROJECT_DIR" \
  --rust-root "$RUST_DIR"

# ── Step 5: Build Flutter Web ────────────────────────────────────────────────
echo ""
echo "🕸️ Building Flutter Web..."
flutter build web

echo ""
echo "✅ Flutter Web build completed."
echo ""
echo "Run locally with:"
echo "  flutter run -d chrome"
echo ""
echo "For production hosting, make sure your server sends these headers:"
echo "  Cross-Origin-Opener-Policy: same-origin"
echo "  Cross-Origin-Embedder-Policy: require-corp"