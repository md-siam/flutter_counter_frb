#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_macos.sh  —  Compile the Rust library for macOS
#
# Prerequisites:
#   • Rust + cargo installed (https://rustup.rs)
#   • Xcode Command Line Tools: xcode-select --install
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RUST_DIR="$(cd "$(dirname "$0")/rust" && pwd)"
OUT_DIR="$(cd "$(dirname "$0")" && pwd)/macos"

mkdir -p "$OUT_DIR"

echo "📦 Building Rust library for macOS..."

cd "$RUST_DIR"

# Add targets if not already installed
# rustup target add \
#   aarch64-apple-darwin \
#   x86_64-apple-darwin

# Build for both Apple Silicon and Intel
cargo build --release --target aarch64-apple-darwin
cargo build --release --target x86_64-apple-darwin

# Merge into a universal binary (works on both chips)
lipo -create \
  target/aarch64-apple-darwin/release/librust_lib.dylib \
  target/x86_64-apple-darwin/release/librust_lib.dylib \
  -output "$OUT_DIR/librust_lib.dylib"

echo "✅ Universal macOS dylib written to: $OUT_DIR/librust_lib.dylib"
echo ""
echo "Next: Add librust_lib.dylib to your Xcode project under"
echo "  Runner → Build Phases → Link Binary with Libraries"
echo ""
echo "Then: Change librust_lib.dylib Embed status in"
echo "  General → Frameworks, Libraries, and Embedded Content → Embed & Sign"
echo ""
echo "Then: Run from VSCode or Android Studio"