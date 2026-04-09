use std::sync::{Mutex, OnceLock};
use log::{info, LevelFilter};
use android_logger::Config;

static COUNTER: Mutex<i64> = Mutex::new(0);
static LOGGER_INIT: OnceLock<()> = OnceLock::new();

fn init_logger() {
    LOGGER_INIT.get_or_init(|| {
        android_logger::init_once(
            Config::default()
                .with_max_level(LevelFilter::Debug)
                .with_tag("RustCounter"),
        );
    });
}

#[no_mangle]
pub extern "C" fn get_counter() -> i64 {
    init_logger();
    *COUNTER.lock().unwrap()
}

#[no_mangle]
pub extern "C" fn increment() -> i64 {
    init_logger();
    let mut val = COUNTER.lock().unwrap();
    *val += 1;
    info!("increment() called → new value: {}", *val);
    *val
}

#[no_mangle]
pub extern "C" fn decrement() -> i64 {
    init_logger();
    let mut val = COUNTER.lock().unwrap();
    *val -= 1;
    info!("decrement() called → new value: {}", *val);
    *val
}

#[no_mangle]
pub extern "C" fn reset() -> i64 {
    init_logger();
    let mut val = COUNTER.lock().unwrap();
    *val = 0;
    info!("reset() called → value reset to 0");
    *val
}