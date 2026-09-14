import 'package:flutter_usb_serial_manager/modals/raw_read_config.dart';
import 'package:flutter_usb_serial_manager/modals/soil_sensor_config.dart';
import 'package:flutter_usb_serial_manager/modals/usb_device.dart';
import 'flutter_usb_serial_manager_platform_interface.dart';

class FlutterUsbSerialManager {
  /// Lists USB devices currently attached to the host.
  Future<List<UsbDevice>> getDeviceList() {
    return FlutterUsbSerialManagerPlatform.instance.getDeviceList();
  }

  /// Whether the app already has permission to access [device].
  Future<bool> hasPermission(UsbDevice device) {
    return FlutterUsbSerialManagerPlatform.instance.hasPermission(device);
  }

  /// Shows the Android USB-permission dialog for [device].
  Future<bool> requestUsbPermission(UsbDevice device) {
    return FlutterUsbSerialManagerPlatform.instance.requestUsbPermission(device);
  }

  /// Opens a serial connection to [device] at [baudRate].
  Future<bool> connect(UsbDevice device, {int baudRate = 9600}) {
    return FlutterUsbSerialManagerPlatform.instance.connect(device, baudRate: baudRate);
  }

  /// Whether a device is currently connected.
  Future<bool> isConnected() {
    return FlutterUsbSerialManagerPlatform.instance.isConnected();
  }

  /// Closes the current serial connection.
  Future<void> disconnect() {
    return FlutterUsbSerialManagerPlatform.instance.disconnect();
  }

  /// Writes [data] to the currently connected device.
  Future<void> write(String data) {
    return FlutterUsbSerialManagerPlatform.instance.write(data);
  }

  /// Reads raw bytes according to [config].
  Future<String> read({RawReadConfig config = const RawReadConfig()}) {
    return FlutterUsbSerialManagerPlatform.instance.read(config: config);
  }

  /// Returns the currently connected device, or null if none.
  Future<UsbDevice?> getConnectedDevice() {
    return FlutterUsbSerialManagerPlatform.instance.getConnectedDevice();
  }

  /// Reads one Modbus soil-sensor sample according to [config].
  Future<Map<String, double>?> readSoilData({
    SoilSensorConfig config = const SoilSensorConfig(),
  }) {
    return FlutterUsbSerialManagerPlatform.instance.readSoilData(config: config);
  }

  /// Starts periodic raw reads (using [config] per read); results arrive on
  /// [serialDataStream].
  Future<void> onReadInterval({
    RawReadConfig config = const RawReadConfig(),
    int intervalMs = 1000,
  }) {
    return FlutterUsbSerialManagerPlatform.instance.onReadInterval(
      config: config,
      intervalMs: intervalMs,
    );
  }

  /// Stops the raw-read interval started by [onReadInterval].
  Future<void> offReadInterval() {
    return FlutterUsbSerialManagerPlatform.instance.offReadInterval();
  }

  /// Starts periodic soil-sensor reads (using [config] per read); results
  /// arrive on [soilDataStream].
  Future<void> onReadSoilDataInterval({
    SoilSensorConfig config = const SoilSensorConfig(),
    int intervalMs = 1000,
  }) {
    return FlutterUsbSerialManagerPlatform.instance.onReadSoilDataInterval(
      config: config,
      intervalMs: intervalMs,
    );
  }

  /// Stops the soil-read interval started by [onReadSoilDataInterval].
  Future<void> offReadSoilDataInterval() {
    return FlutterUsbSerialManagerPlatform.instance.offReadSoilDataInterval();
  }

  /// Raw bytes pushed by native while [onReadInterval] is active.
  Stream<String> get serialDataStream {
    return FlutterUsbSerialManagerPlatform.instance.serialDataStream;
  }

  /// Soil-sensor samples pushed by native while [onReadSoilDataInterval] is active.
  Stream<Map<String, double>> get soilDataStream {
    return FlutterUsbSerialManagerPlatform.instance.soilDataStream;
  }
}
