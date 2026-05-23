use log::{info, LevelFilter};
use std::sync::{Mutex, OnceLock};

static COUNTER: Mutex<i32> = Mutex::new(0);
static LOGGER_INIT: OnceLock<()> = OnceLock::new();

fn init_logger() {
    LOGGER_INIT.get_or_init(|| {
        #[cfg(target_os = "android")]
        {
            android_logger::init_once(
                android_logger::Config::default()
                    .with_max_level(LevelFilter::Debug)
                    .with_tag("RustCounter"),
            );
        }

        #[cfg(not(target_os = "android"))]
        {
            let _ = env_logger::builder()
                .filter_level(LevelFilter::Debug)
                .try_init();
        }
    });
}

pub fn get_counter() -> i32 {
    init_logger();
    *COUNTER.lock().unwrap()
}

pub fn increment() -> i32 {
    init_logger();

    let mut value = COUNTER.lock().unwrap();
    *value += 1;

    info!("increment() called -> new value: {}", *value);

    *value
}

pub fn decrement() -> i32 {
    init_logger();

    let mut value = COUNTER.lock().unwrap();
    *value -= 1;

    info!("decrement() called -> new value: {}", *value);

    *value
}

pub fn reset() -> i32 {
    init_logger();

    let mut value = COUNTER.lock().unwrap();
    *value = 0;

    info!("reset() called -> new value: {}", *value);

    *value
}
