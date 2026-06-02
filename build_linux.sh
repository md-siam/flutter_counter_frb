#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# build_linux.sh  —  Compile the Rust library for Linux
#
# Prerequisites:
#   • Rust + cargo installed (https://rustup.rs)
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

RUST_DIR="$(cd "$(dirname "$0")/rust" && pwd)"
OUT_DIR="$(cd "$(dirname "$0")" && pwd)/linux"

mkdir -p "$OUT_DIR"

echo "📦 Building Rust library for Linux..."

cd "$RUST_DIR"

# Add target if not already installed
rustup target add x86_64-unknown-linux-gnu

# Build for Linux x86_64
cargo build --release --target x86_64-unknown-linux-gnu

# Copy the compiled shared library to the linux/ folder
cp target/x86_64-unknown-linux-gnu/release/librust_lib.so "$OUT_DIR/librust_lib.so"

echo "✅ Linux .so file written to: $OUT_DIR/librust_lib.so"
echo ""
echo "Next: Add the following to your linux/CMakeLists.txt"
echo "  set(RUST_LIB \"\${CMAKE_CURRENT_SOURCE_DIR}/../linux/librust_lib.so\")"
echo "  install(FILES \"\${RUST_LIB}\" DESTINATION \"\${INSTALL_BUNDLE_LIB_DIR}\")"
echo "  target_link_libraries(\${BINARY_NAME} PRIVATE \"\${RUST_LIB}\")"
