
import 'flutter_usb_serial_manager_platform_interface.dart';

class FlutterUsbSerialManager {
  Future<String?> getPlatformVersion() {
    return FlutterUsbSerialManagerPlatform.instance.getPlatformVersion();
  }
}
