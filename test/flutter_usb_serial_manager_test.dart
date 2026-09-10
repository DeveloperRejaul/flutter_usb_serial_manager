import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_usb_serial_manager/flutter_usb_serial_manager.dart';
import 'package:flutter_usb_serial_manager/flutter_usb_serial_manager_platform_interface.dart';
import 'package:flutter_usb_serial_manager/flutter_usb_serial_manager_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterUsbSerialManagerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterUsbSerialManagerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterUsbSerialManagerPlatform initialPlatform = FlutterUsbSerialManagerPlatform.instance;

  test('$MethodChannelFlutterUsbSerialManager is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterUsbSerialManager>());
  });

  test('getPlatformVersion', () async {
    FlutterUsbSerialManager flutterUsbSerialManagerPlugin = FlutterUsbSerialManager();
    MockFlutterUsbSerialManagerPlatform fakePlatform = MockFlutterUsbSerialManagerPlatform();
    FlutterUsbSerialManagerPlatform.instance = fakePlatform;

    expect(await flutterUsbSerialManagerPlugin.getPlatformVersion(), '42');
  });
}
