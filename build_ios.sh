#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_ios.sh  —  Compile the Rust library as an XCFramework for iOS
#
# Supports:
#   • Physical iOS devices     (aarch64-apple-ios)
#   • Apple Silicon simulators (aarch64-apple-ios-sim)  M1/M2/M3 Macs
#   • Intel simulators         (x86_64-apple-ios)
#
# Prerequisites:
#   • Rust + cargo (https://rustup.rs)
#   • Xcode + Command Line Tools
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RUST_DIR="$(cd "$(dirname "$0")/rust" && pwd)"

# ── Output paths ──────────────────────────────────────────────────────────────
XCFRAMEWORK_NAME="RustLib.xcframework"
XCFRAMEWORK_OUT="$RUST_DIR/$XCFRAMEWORK_NAME"

# ── Ensure output dirs exist ──────────────────────────────────────────────────
SIM_LIPO_DIR="$RUST_DIR/target/ios-sim-lipo"
SIM_LIPO_LIB="$SIM_LIPO_DIR/librust_lib.a"

echo "📦 Building Rust library for iOS..."
echo "   Rust dir : $RUST_DIR"
echo "   Output   : $XCFRAMEWORK_OUT"
echo ""

cd "$RUST_DIR"

# ── Step 1: Install required targets ─────────────────────────────────────────
# Safe to run every time — no-op if already installed
echo "🎯 Adding Rust targets..."
rustup target add \
  aarch64-apple-ios \
  aarch64-apple-ios-sim \
  x86_64-apple-ios

# ── Step 2: Build for all targets ─────────────────────────────────────────────
echo ""
echo "🔨 Building for physical device (aarch64-apple-ios)..."
cargo build --release --target aarch64-apple-ios

echo ""
echo "🔨 Building for Apple Silicon simulator (aarch64-apple-ios-sim)..."
cargo build --release --target aarch64-apple-ios-sim

echo ""
echo "🔨 Building for Intel simulator (x86_64-apple-ios)..."
cargo build --release --target x86_64-apple-ios

# ── Step 3: Create universal simulator slice (fat binary) ─────────────────────
# Combines Apple Silicon + Intel simulator libs into one slice
echo ""
echo "🔗 Creating universal simulator binary with lipo..."
mkdir -p "$SIM_LIPO_DIR"
lipo -create \
  "$RUST_DIR/target/aarch64-apple-ios-sim/release/librust_lib.a" \
  "$RUST_DIR/target/x86_64-apple-ios/release/librust_lib.a" \
  -output "$SIM_LIPO_LIB"

# ── Step 4: Create XCFramework ─────────────────────────────────────────────────
# Bundles device + simulator slices into a single distributable framework
echo ""
echo "📦 Creating XCFramework..."
rm -rf "$XCFRAMEWORK_OUT"
xcodebuild -create-xcframework \
  -library "$RUST_DIR/target/aarch64-apple-ios/release/librust_lib.a" \
  -library "$SIM_LIPO_LIB" \
  -output "$XCFRAMEWORK_OUT"

# ── Done ───────────────────────────────────────────────────────────────────────
echo ""
echo "✅ XCFramework written to: $XCFRAMEWORK_OUT"
echo ""
echo "Next steps in Xcode:"
echo "  1. Open ios/Runner.xcworkspace"
echo "  2. Runner → Build Phases → Link Binary With Libraries → + → Add $XCFRAMEWORK_NAME (from rust folder)" 
echo "  3. Runner → Build Phases → Bundle Frameworks → + → Add $XCFRAMEWORK_NAME"
echo "  4. Drag "bridge_generated.h" (from rust folder) → Runner"
echo "  5. Open "Runner-Bridging-Header.h" → Add #import "bridge_generated.h" "
echo "  6. Open "AppDelegare.swift" → Add these two lines of code: "
echo ""
echo "           let dummy = dummy_method_to_enforce_bundling()"
echo "           print(dummy)"                          
