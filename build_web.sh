#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "Ensuring Rust target exists..."
rustup target list --installed | grep -q wasm32-unknown-unknown || \
rustup target add wasm32-unknown-unknown

echo "Getting Flutter dependencies..."
flutter pub get

echo "Building Rust WASM package..."
wasm-pack build rust \
  --target no-modules \
  --release \
  --out-dir ../web/pkg

echo "Building Flutter web app..."
flutter build web --no-wasm-dry-run

echo "Web build is ready at build/web"
