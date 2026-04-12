//! # Rust Counter Library
//!
//! Exposes a thread-safe counter to Flutter via flutter_rust_bridge v2.
//! All public functions in the `api` module are auto-discovered by codegen
//! and generate corresponding async Dart functions in frb_generated.dart.

// Required by flutter_rust_bridge codegen — do not remove
mod frb_generated;

pub mod api;