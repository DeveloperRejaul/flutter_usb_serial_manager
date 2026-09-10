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

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
