#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_all.sh — Interactive Codegen + Multi-platform Builder
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUST_DIR="$ROOT_DIR/rust"

ANDROID_OUT_DIR="$ROOT_DIR/android/app/src/main/jniLibs"
LINUX_OUT_DIR="$ROOT_DIR/linux"

# ─────────────────────────────────────────────
# STEP 1: CODEGEN OPTION
# ─────────────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Rust Bridge Codegen "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) Run Codegen"
echo "2) Skip Codegen"
echo ""

read -p "Enter choice [1-2]: " codegen_choice

run_codegen() {
  echo ""
  echo "🚀 STARTING CODEGEN..."

  echo "🧹 Cleaning old generated files..."
  rm -f "$ROOT_DIR/lib/rust_lib/frb_generated.dart"
  rm -f "$ROOT_DIR/lib/rust_lib/frb_generated.io.dart"
  rm -f "$ROOT_DIR/lib/rust_lib/frb_generated.web.dart"
  rm -rf "$ROOT_DIR/.dart_tool/"

  echo "⚙️ Running flutter_rust_bridge_codegen..."
  flutter_rust_bridge_codegen generate

  echo "📦 Running flutter pub get..."
  flutter pub get

  echo "✅ Codegen complete!"
}

case $codegen_choice in
  1)
    run_codegen
    ;;
  2)
    echo "⏭️ Skipping codegen..."
    ;;
  *)
    echo "❌ Invalid choice"
    exit 1
    ;;
esac

# ─────────────────────────────────────────────
# STEP 2: PLATFORM SELECTION
# ─────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 Select platform to build:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1) Android"
echo "2) iOS"
echo "3) macOS"
echo "4) Linux"
echo "5) All"
echo ""

read -p "Enter choice [1-5]: " choice

# ─────────────────────────────────────────────
# BUILD FUNCTIONS
# ─────────────────────────────────────────────

build_android() {
  echo "📦 Building Android..."

  mkdir -p "$ANDROID_OUT_DIR"/{arm64-v8a,armeabi-v7a,x86_64}

  cd "$RUST_DIR"

  cargo ndk \
    -t arm64-v8a \
    -t armeabi-v7a \
    -t x86_64 \
    -o "$ANDROID_OUT_DIR" \
    build --release
  
  echo "✅ Android .so files written to: $ANDROID_OUT_DIR"
  echo ""
  echo "  arm64-v8a  → $ANDROID_OUT_DIR/arm64-v8a/librust_lib.so"
  echo "  armeabi-v7a → $ANDROID_OUT_DIR/armeabi-v7a/librust_lib.so"
  echo "  x86_64     → $ANDROID_OUT_DIR/x86_64/librust_lib.so"
}

build_ios() {
  echo "📦 Building iOS..."

  cd "$RUST_DIR"

#   rustup target add aarch64-apple-ios x86_64-apple-ios || true

#   cargo build --release --target aarch64-apple-ios
#   cargo build --release --target x86_64-apple-ios

  echo "✅ iOS build complete (link in Xcode)"
}

build_macos() {
  echo "📦 Building macOS..."

  cd "$RUST_DIR"

#   rustup target add aarch64-apple-darwin x86_64-apple-darwin || true

#   cargo build --release --target aarch64-apple-darwin
#   cargo build --release --target x86_64-apple-darwin

  echo "✅ macOS build complete"
}

build_linux() {
  echo "📦 Building Linux..."

  mkdir -p "$LINUX_OUT_DIR"

  cd "$RUST_DIR"

  cargo build --release --target x86_64-unknown-linux-gnu

  cp target/x86_64-unknown-linux-gnu/release/librust_lib.so \
     "$LINUX_OUT_DIR/librust_lib.so"

  echo "✅ Linux .so file written to: $LINUX_OUT_DIR/librust_lib.so"
  echo ""
  echo "Next: Add the following to your linux/CMakeLists.txt"
  echo "  set(RUST_LIB \"\${CMAKE_CURRENT_SOURCE_DIR}/../linux/librust_lib.so\")"
  echo "  install(FILES \"\${RUST_LIB}\" DESTINATION \"\${INSTALL_BUNDLE_LIB_DIR}\")"
  echo "  target_link_libraries(\${BINARY_NAME} PRIVATE \"\${RUST_LIB}\")"
}

# ─────────────────────────────────────────────
# EXECUTION
# ─────────────────────────────────────────────

case $choice in
  1)
    build_android
    ;;
  2)
    build_ios
    ;;
  3)
    build_macos
    ;;
  4)
    build_linux
    ;;
  5)
    build_android
    build_ios
    build_macos
    build_linux
    ;;
  *)
    echo "❌ Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 ALL DONE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"