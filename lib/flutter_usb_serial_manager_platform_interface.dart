import 'package:flutter_usb_serial_manager/modals/usb_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_usb_serial_manager_method_channel.dart';

abstract class FlutterUsbSerialManagerPlatform extends PlatformInterface {
  /// Constructs a FlutterUsbSerialManagerPlatform.
  FlutterUsbSerialManagerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterUsbSerialManagerPlatform _instance = MethodChannelFlutterUsbSerialManager();

  /// The default instance of [FlutterUsbSerialManagerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterUsbSerialManager].
  static FlutterUsbSerialManagerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterUsbSerialManagerPlatform] when
  /// they register themselves.
  static set instance(FlutterUsbSerialManagerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

//  "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
//   "getDeviceList" -> getDeviceList(call, result)
//   "hasPermission" -> hasPermission(call, result)
//   "requestUsbPermission" -> requestUsbPermission(call, result)
//   "connect" -> connect(call, result)
//   "isConnected" ->  isConnected(call, result)
//   "disconnect" ->  disconnect(call, result)
//   "write" ->  write(call, result)
//   "read" ->  read(call, result)
//   "getConnectedDevice" ->  getConnectedDevice(call, result)
//   "readSoilData" ->  readSoilData(call, result)

  Future<List<UsbDevice>> getDeviceList() {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }



}
