//! # Counter API
//!
//! All `pub fn` functions in this module are picked up by
//! flutter_rust_bridge_codegen and exposed as async Dart methods.
//!
//! Rules for codegen compatibility:
//!   - Functions must be `pub fn` (no `extern "C"`, no `#[no_mangle]`)
//!   - Supported types: primitives, String, Vec, structs, enums
//!   - The bridge generates async Dart wrappers automatically

use std::sync::{Mutex, OnceLock};
use log::{info, LevelFilter};
use android_logger::Config;

// ─── Global State ─────────────────────────────────────────────────────────────

/// Thread-safe global counter, initialized to 0.
static COUNTER: Mutex<i64> = Mutex::new(0);

/// Ensures the logger is initialized exactly once across all calls.
static LOGGER_INIT: OnceLock<()> = OnceLock::new();

// ─── Logger ───────────────────────────────────────────────────────────────────

/// Initializes the Android logger exactly once.
/// All logs appear in logcat under the tag `RustCounter`.
fn init_logger() {
    LOGGER_INIT.get_or_init(|| {
        android_logger::init_once(
            Config::default()
                .with_max_level(LevelFilter::Debug)
                .with_tag("RustCounter"),
        );
    });
}

// ─── Public API (codegen entry points) ────────────────────────────────────────

/// Returns the current counter value without modifying it.
///
/// Generated Dart usage:
/// ```dart
/// final value = await api.getCounter();
/// ```
pub fn get_counter() -> i64 {
    init_logger();
    *COUNTER.lock().unwrap()
}

/// Increments the counter by 1 and returns the new value.
///
/// Generated Dart usage:
/// ```dart
/// final value = await api.increment();
/// ```
pub fn increment() -> i64 {
    init_logger();
    let mut val = COUNTER.lock().unwrap();
    *val += 1;
    info!("increment() called → new value: {}", *val);
    *val
}

/// Decrements the counter by 1 and returns the new value.
/// The counter can go negative — no lower bound is enforced.
///
/// Generated Dart usage:
/// ```dart
/// final value = await api.decrement();
/// ```
pub fn decrement() -> i64 {
    init_logger();
    let mut val = COUNTER.lock().unwrap();
    *val -= 1;
    info!("decrement() called → new value: {}", *val);
    *val
}

/// Resets the counter to 0 and returns 0.
///
/// Generated Dart usage:
/// ```dart
/// await api.reset();
/// ```
pub fn reset() -> i64 {
    init_logger();
    let mut val = COUNTER.lock().unwrap();
    *val = 0;
    info!("reset() called → value reset to 0");
    *val
}