#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_android.sh  —  Compile the Rust library for Android targets
#
# Prerequisites:
#   • Rust + cargo installed (https://rustup.rs)
#   • Android NDK installed and ANDROID_NDK_HOME set
#   • cargo-ndk: cargo install cargo-ndk
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUST_DIR="$ROOT_DIR/rust"
OUT_DIR="$ROOT_DIR/android/app/src/main/jniLibs"

mkdir -p "$OUT_DIR"

echo "📦 Building Rust library for Android..."

cd "$RUST_DIR"

# Add Rust targets if not already installed
rustup target add \
  aarch64-linux-android \
  armv7-linux-androideabi \
  x86_64-linux-android

# Build with cargo-ndk (handles NDK toolchain setup automatically)
cargo ndk \
  -t arm64-v8a \
  -t armeabi-v7a \
  -t x86_64 \
  -o "$OUT_DIR" \
  build --release

echo "✅ Android .so files written to: $OUT_DIR"
echo ""
echo "  arm64-v8a  → $OUT_DIR/arm64-v8a/librust_lib.so"
echo "  armeabi-v7a → $OUT_DIR/armeabi-v7a/librust_lib.so"
echo "  x86_64     → $OUT_DIR/x86_64/librust_lib.so"
