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

3. Add `Android` targets:

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
```

4. Add `iOS` targets:

```bash
rustup target add aarch64-apple-ios x86_64-apple-ios aarch64-apple-ios-sim
```

5. Add `MacOS` targets:

```bash
rustup target add aarch64-apple-darwin x86_64-apple-darwin
```

6. To check all the `rustup` targets:

```bash
rustup show
```

<span style="color: red;">\*\* Note: Avoid installing **`rustc`** through **`homebrew`**</span>

---

## Step 1 — Install flutter_rust_bridge_codegen

```bash
cargo install flutter_rust_bridge_codegen
flutter_rust_bridge_codegen --version
```

This will globally install the `flutter_rust_bridge_codegen` into your system

---

## Step 2 — Generate Dart bindings from Rust

Create a file in the app directory with the name: `flutter_rust_bridge.yaml`, and paste these code:

```yaml
rust_input: crate::api
rust_root: rust/
dart_output: lib/rust_lib

# Disable web platform — only native FFI targets are needed
# (Android, iOS, macOS, Linux, Windows)
# This prevents frb_generated.web.dart from being generated
web: false
```

Create another file with the name: `codegen.sh`, and paste these code:

```bash
set -euo pipefail

echo "🗑️  Removing existing generated files..."
rm -f lib/rust_lib/frb_generated.dart
rm -f lib/rust_lib/frb_generated.io.dart
rm -f lib/rust_lib/frb_generated.web.dart
rm -rf .dart_tool/

echo "⚙️  Running flutter_rust_bridge_codegen..."
flutter_rust_bridge_codegen generate

flutter pub get

echo "✅ Codegen complete!"
```

Make codegen.sh executable:

```bash
chmod +x codegen.sh
./codegen.sh
```

This reads your `pub fn` signatures in Rust and emits matching Dart async functions in `rust_lib` directory.

```
lib
 └─ rust_lib
  ├── api.dart
  ├── frb_generated.dart
  └── frb_generated.io.dart
```

---

## Step 3 — Build the Rust native library

### 🤖 Android:

```bash
chmod +x build_android.sh
./build_android.sh
```

This places `.so` files into `android/app/src/main/jniLibs/`.

### 🍎 iOS:

#### Part 1 — Rust crate setup

1. **Update `Cargo.toml` crate types**

```toml
[lib]
name = "rust_lib"
crate-type = ["lib", "staticlib", "cdylib"]
```

2. **Install cargo-xcode and generate Xcode project**

```bash
cargo install cargo-xcode
cd rust
cargo xcode
```

---

#### Part 2 — Xcode: add Rust as subproject

3. **Open iOS workspace**

```bash
open ios/Runner.xcworkspace
```

4. **Add `rust_lib.xcodeproj` as subproject**

- Right-click Runner → Add Files → select `rust/rust_lib.xcodeproj`

---

#### Part 3 — Build Phases

5. **Add dependency**

- Add `rust_lib-staticlib` in _Dependencies_

6. **Link library**

- Add `librust_lib_static.a` in _Link Binary With Libraries_

---

#### Part 4 — Headers & Swift

7. **Run codegen and copy header**

```bash
./codegen.sh
cp rust/target/bindings.h ios/Runner/bridge_generated.h
```

8. **Update bridging header**

```c
#import "GeneratedPluginRegistrant.h"
#import "bridge_generated.h"
```

9. **Call dummy method in AppDelegate.swift**

```swift
let dummy = dummy_method_to_enforce_bundling()
print(dummy)
```

---

#### Part 5 — Build Settings

10. **Set Strip Style**

- Use: `Non-Global Symbols`

11. **Run app**

```bash
flutter run -d ios
```

### 💻 MacOS:

#### Part 1 — Rust setup

1. **Update Cargo.toml**

```toml
crate-type = ["lib", "staticlib", "cdylib"]
```

```bash
cd rust && cargo xcode
```

---

#### Part 2 — Xcode setup

2. **Open workspace**

```bash
open macos/Runner.xcworkspace
```

3. **Fix install name base**

- Set: `@executable_path/../Frameworks/`

---

#### Part 3 — Build Phases

4. **Add dependency**

- Add `rust_lib-cdylib`

5. **Link library**

- Add `rust_lib.dylib`
- Also add to _Bundle Frameworks_

---

#### Part 4 — Headers & Swift

6. **Generate header**

```bash
./codegen.sh
cp rust/target/bindings.h macos/Runner/bridge_generated.h
```

7. **Set bridging header**

- `Runner/bridge_generated.h`

8. **Call dummy method**

```swift
let dummy = dummy_method_to_enforce_bundling()
print(dummy)
```

---

#### Part 5 — Rpath

9. **Runpath Search Paths**

- `@executable_path/../Frameworks`

10. **Fix dylib install name**

```bash
install_name_tool -id   @rpath/librust_lib.dylib   macos/Runner/librust_lib.dylib
```

11. **Run app**

```bash
flutter clean && flutter run -d macos
```

### 🐧 Linux:

```bash
chmod +x build_linux.sh
./build_linux.sh
```

Modify `CMakeLists.txt` file:

```txt
# For initializing rust library
set(RUST_LIB "${CMAKE_CURRENT_SOURCE_DIR}/../linux/librust_lib.so")
  install(FILES "${RUST_LIB}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}")
  target_link_libraries(${BINARY_NAME} PRIVATE "${RUST_LIB}")
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
