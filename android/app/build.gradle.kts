plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.flutter_counter_frb"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.flutter_counter_frb"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // ─── Rust FFI Native Libraries ───────────────────────────────────────────────
    //
    sourceSets {
        getByName("main") {
            // Tell Gradle where to find the pre-compiled Rust .so files.
            // Without this, the .so files would not be packaged into the APK/AAB
            // and the app would throw an UnsatisfiedLinkError at runtime.
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }

    defaultConfig {
        ndk {
            // Restrict the APK to only include .so files for these ABI targets.
            // This prevents Gradle from packaging unnecessary architectures,
            // keeping the APK size minimal.
            //
            // arm64-v8a   → Required for all modern 64-bit Android devices
            // armeabi-v7a → Required for legacy 32-bit ARM devices (Android < 5.0 era)
            // x86_64      → Required for Android emulators on Linux and macOS (Intel/AMD)
            //
            // Note: x86 (32-bit) is intentionally excluded — emulators now default
            // to x86_64 and physical x86 Android devices are extremely rare.
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }
}

flutter {
    source = "../.."
}
