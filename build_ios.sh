#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_ios.sh  —  Compile the Rust library as a static lib for iOS
#
# Prerequisites:
#   • Rust + cargo (https://rustup.rs)
#   • Xcode Command Line Tools
#   • cargo-lipo (for universal static lib): cargo install cargo-lipo
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RUST_DIR="$(cd "$(dirname "$0")/rust" && pwd)"
IOS_DIR="$(cd "$(dirname "$0")/ios" && pwd)"

echo "📦 Building Rust library for iOS..."

cd "$RUST_DIR"

# Add Rust targets if not already installed
# rustup target add \
#   aarch64-apple-ios \
#   aarch64-apple-ios-sim \
#   x86_64-apple-ios

# Build a fat/universal static lib (device + simulator)
cargo lipo --release --targets aarch64-apple-ios,x86_64-apple-ios

cp target/universal/release/librust_lib.a "$IOS_DIR/"

echo "✅ Static lib written to: $IOS_DIR/librust_lib.a"
echo ""
echo "Next: Add librust_lib.a to your Xcode project under"
echo "  Runner → Build Phases → Link Binary with Libraries"
