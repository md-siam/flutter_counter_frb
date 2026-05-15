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

RUST_DIR="$(cd "$(dirname "$0")/rust" && pwd)"
OUT_DIR="$(cd "$(dirname "$0")/android/app/src/main/jniLibs" && pwd)"

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
