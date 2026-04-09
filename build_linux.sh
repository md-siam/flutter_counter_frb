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

cargo build --release --target x86_64-unknown-linux-gnu

cp target/x86_64-unknown-linux-gnu/release/librust_lib.so "$OUT_DIR/"

echo "✅ Linux .so file written to: $OUT_DIR/librust_lib.so"