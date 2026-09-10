import 'package:flutter_usb_serial_manager/modals/usb_device.dart';
import 'flutter_usb_serial_manager_platform_interface.dart';

class FlutterUsbSerialManager {
  Future<List<UsbDevice>> getDeviceList() {
    return FlutterUsbSerialManagerPlatform.instance.getDeviceList();
  }
}
