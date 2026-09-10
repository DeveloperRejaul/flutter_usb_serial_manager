import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_serial_manager/modals/usb_device.dart';

import 'flutter_usb_serial_manager_platform_interface.dart';

/// An implementation of [FlutterUsbSerialManagerPlatform] that uses method channels.
class MethodChannelFlutterUsbSerialManager extends FlutterUsbSerialManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_usb_serial_manager');


  @override
  Future<List<UsbDevice>> getDeviceList() async {
    final deviceList = await methodChannel.invokeMethod<List<dynamic>>('getDeviceList');
    return deviceList?.map((device) => UsbDevice.fromMap(device)).toList() ?? [];
  }

}
