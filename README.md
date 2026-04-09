# flutter_counter_frb

A Flutter counter app whose business logic lives in **Rust**, called from Dart via **FFI** and **flutter_rust_bridge v2**.

---

## Project Structure

```
flutter_counter_frb/
├── rust/                        # Rust crate
│   ├── Cargo.toml
│   └── src/
│       └── lib.rs               # Counter logic (increment / decrement / reset)
│
├── lib/
│   ├── main.dart                # Flutter app entry point
│   ├── counter_page.dart        # UI — calls Rust via FFI
│   ├── widgets                  # Widgets
│   │    ├── counter_button.dart
│   │    ├── info_bar.dart
│   │    └── rust_badge.dart
│   └── src/rust_lib/
│       ├── frb_generated.dart   # FFI bindings (replace with codegen output)
│       └── api.dart             # Re-export for clean imports
│
├── android/app/
│   ├── build.gradle             # jniLibs config
│   └── src/main/jniLibs/        # .so files go here after build_android.sh
│       ├── arm64-v8a/
│       ├── armeabi-v7a/
│       └── x86_64/
│
├── ios/                         # librust_lib.a goes here after build_ios.sh
├── build_android.sh
├── build_ios.sh
└── pubspec.yaml
```

---

## Prerequisites

| Tool                | Install                                      |
| ------------------- | -------------------------------------------- |
| Rust + Cargo        | https://rustup.rs                            |
| Flutter SDK ≥ 3.10  | https://docs.flutter.dev/get-started/install |
| cargo-ndk (Android) | `cargo install cargo-ndk`                    |
| Android NDK         | via Android Studio → SDK Manager             |
| cargo-lipo (iOS)    | `cargo install cargo-lipo`                   |
| Xcode (iOS/macOS)   | Mac App Store                                |

1. Terminal commands to properly install `rustc` on your device:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"

nano ~/.zshrc
export ANDROID_NDK_HOME=/home/technonext/Android/Sdk/ndk/30.0.14904198
```

2. Should show clean output like:

```bash
rustc --version
cargo --version
```

3. Add Android targets:

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
```

4. Add iOS and MacOS targets:

```bash
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim
```

<span style="color: red;">\*\* Note: Avoid installing **`rustc`** through **`homebrew`**</span>

---

## Step 1 — Install flutter_rust_bridge_codegen

```bash
cargo install flutter_rust_bridge_codegen
```

---

## Step 2 — Generate Dart bindings from Rust

> Skip this if you want to use the hand-written `frb_generated.dart` provided.

```bash
cd flutter_counter_frb
flutter_rust_bridge_codegen generate \
  --rust-input rust/src/lib.rs \
  --dart-output lib/src/rust_lib/frb_generated.dart
```

This reads your `pub fn` signatures in Rust and emits matching Dart async functions.

---

## Step 3 — Build the Rust native library

### Android

```bash
mkdir -p android/app/src/main/jniLibs/{arm64-v8a,armeabi-v7a,x86_64}
chmod +x build_android.sh
./build_android.sh
```

This places `.so` files into `android/app/src/main/jniLibs/`.

### iOS

```bash
chmod +x build_ios.sh
./build_ios.sh
```

Then in Xcode: **Runner → Build Phases → Link Binary with Libraries → + → Add librust_lib.a**

### Desktop (Linux / macOS / Windows)

```bash
cd rust
cargo build --release
# Outputs to rust/target/release/librust_lib.{so,dylib,dll}
# Copy alongside your Flutter executable or into the right system path
```

---

## Step 4 — Run the Flutter app

```bash
flutter pub get
flutter run
```

---

## How the FFI bridge works

```
Dart (counter_page.dart)
    │
    │  calls async method
    ▼
RustLib.instance.increment()        ← frb_generated.dart
    │
    │  DynamicLibrary.lookupFunction
    ▼
librust_lib.so / .dylib / .dll      ← compiled Rust
    │
    │  #[no_mangle] pub extern "C" fn increment() -> i64
    ▼
COUNTER (Mutex<i64>)                ← Rust global state
```

---

## Adding more crates.io packages

1. Add the dependency to `rust/Cargo.toml`:

   ```toml
   [dependencies]
   uuid = { version = "1", features = ["v4"] }
   ```

2. Use it inside `rust/src/lib.rs`:

   ```rust
   use uuid::Uuid;

   pub fn generate_id() -> String {
       Uuid::new_v4().to_string()
   }
   ```

3. Re-run codegen → rebuild the native lib → `flutter run`.

Cargo handles all dependency resolution automatically. Only the _boundary_ functions need `pub` — everything internal stays pure Rust.
