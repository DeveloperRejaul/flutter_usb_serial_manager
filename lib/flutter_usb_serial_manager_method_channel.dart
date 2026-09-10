import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_usb_serial_manager_platform_interface.dart';

/// An implementation of [FlutterUsbSerialManagerPlatform] that uses method channels.
class MethodChannelFlutterUsbSerialManager extends FlutterUsbSerialManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_usb_serial_manager');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
