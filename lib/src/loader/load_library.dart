export 'load_library_stub.dart' // default (web)
    if (dart.library.io) 'load_library_native.dart'; // mobile/desktop
