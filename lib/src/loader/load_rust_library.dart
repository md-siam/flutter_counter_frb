import 'dart:io';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_io.dart';

ExternalLibrary loadRustLibrary() {
  if (Platform.isAndroid) {
    return ExternalLibrary.open('librust_lib.so');
  } else if (Platform.isIOS) {
    return ExternalLibrary.process(iKnowHowToUseIt: true);
  } else if (Platform.isMacOS) {
    return ExternalLibrary.open('librust_lib.dylib');
  } else if (Platform.isWindows) {
    return ExternalLibrary.open('rust_lib.dll');
  } else if (Platform.isLinux) {
    return ExternalLibrary.open('librust_lib.so');
  }

  throw UnsupportedError(
    'Unsupported platform: ${Platform.operatingSystem}',
  );
}
