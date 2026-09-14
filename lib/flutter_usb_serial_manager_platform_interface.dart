import 'package:flutter_usb_serial_manager/modals/raw_read_config.dart';
import 'package:flutter_usb_serial_manager/modals/soil_sensor_config.dart';
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

  /// Returns the list of USB devices currently attached to the host.
  Future<List<UsbDevice>> getDeviceList() {
    throw UnimplementedError('getDeviceList() has not been implemented.');
  }

  /// Whether the app already has permission to access [device].
  Future<bool> hasPermission(UsbDevice device) {
    throw UnimplementedError('hasPermission() has not been implemented.');
  }

  /// Shows the Android USB-permission dialog for [device] and resolves once
  /// the user answers it (or immediately if permission was already granted).
  Future<bool> requestUsbPermission(UsbDevice device) {
    throw UnimplementedError('requestUsbPermission() has not been implemented.');
  }

  /// Opens a serial connection to [device] at [baudRate].
  Future<bool> connect(UsbDevice device, {int baudRate = 9600}) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  /// Whether a device is currently connected.
  Future<bool> isConnected() {
    throw UnimplementedError('isConnected() has not been implemented.');
  }

  /// Closes the current serial connection.
  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Writes [data] to the currently connected device.
  Future<void> write(String data) {
    throw UnimplementedError('write() has not been implemented.');
  }

  /// Reads raw bytes according to [config].
  Future<String> read({RawReadConfig config = const RawReadConfig()}) {
    throw UnimplementedError('read() has not been implemented.');
  }

  /// Returns the currently connected device, or null if none.
  Future<UsbDevice?> getConnectedDevice() {
    throw UnimplementedError('getConnectedDevice() has not been implemented.');
  }

  /// Reads one Modbus soil-sensor sample according to [config].
  Future<Map<String, double>?> readSoilData({
    SoilSensorConfig config = const SoilSensorConfig(),
  }) {
    throw UnimplementedError('readSoilData() has not been implemented.');
  }

  /// Starts emitting raw serial reads on [serialDataStream] every [intervalMs],
  /// using [config] for each individual read.
  Future<void> onReadInterval({
    RawReadConfig config = const RawReadConfig(),
    int intervalMs = 1000,
  }) {
    throw UnimplementedError('onReadInterval() has not been implemented.');
  }

  /// Stops the raw-read interval started by [onReadInterval].
  Future<void> offReadInterval() {
    throw UnimplementedError('offReadInterval() has not been implemented.');
  }

  /// Starts emitting soil-sensor samples on [soilDataStream] every [intervalMs],
  /// using [config] for each individual read.
  Future<void> onReadSoilDataInterval({
    SoilSensorConfig config = const SoilSensorConfig(),
    int intervalMs = 1000,
  }) {
    throw UnimplementedError('onReadSoilDataInterval() has not been implemented.');
  }

  /// Stops the soil-read interval started by [onReadSoilDataInterval].
  Future<void> offReadSoilDataInterval() {
    throw UnimplementedError('offReadSoilDataInterval() has not been implemented.');
  }

  /// Raw bytes pushed by the native side while [onReadInterval] is active.
  Stream<String> get serialDataStream {
    throw UnimplementedError('serialDataStream has not been implemented.');
  }

  /// Soil-sensor samples pushed by the native side while
  /// [onReadSoilDataInterval] is active.
  Stream<Map<String, double>> get soilDataStream {
    throw UnimplementedError('soilDataStream has not been implemented.');
  }
}
