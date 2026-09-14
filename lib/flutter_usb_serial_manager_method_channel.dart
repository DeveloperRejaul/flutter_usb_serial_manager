import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_serial_manager/modals/raw_read_config.dart';
import 'package:flutter_usb_serial_manager/modals/soil_sensor_config.dart';
import 'package:flutter_usb_serial_manager/modals/usb_device.dart';

import 'flutter_usb_serial_manager_platform_interface.dart';

/// An implementation of [FlutterUsbSerialManagerPlatform] that uses method channels.
class MethodChannelFlutterUsbSerialManager extends FlutterUsbSerialManagerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_usb_serial_manager');

  /// The event channel the native side pushes interval-read data on.
  @visibleForTesting
  final eventChannel = const EventChannel('flutter_usb_serial_manager/events');

  Stream<Map<String, dynamic>>? _events;

  /// Broadcast stream of every `{event, data}` payload sent from native,
  /// shared by [serialDataStream] and [soilDataStream].
  Stream<Map<String, dynamic>> get _rawEvents {
    return _events ??= eventChannel.receiveBroadcastStream().map(
          (event) => Map<String, dynamic>.from(event as Map),
        );
  }

  @override
  Future<List<UsbDevice>> getDeviceList() async {
    final deviceList = await methodChannel.invokeMethod<List<dynamic>>('getDeviceList');
    return deviceList
            ?.whereType<Map>()
            .map((device) => UsbDevice.fromMap(Map<String, dynamic>.from(device)))
            .toList() ??
        [];
  }

  @override
  Future<bool> hasPermission(UsbDevice device) async {
    final result = await methodChannel.invokeMethod<bool>('hasPermission', {
      'vendorId': device.vendorId,
      'productId': device.productId,
    });
    return result ?? false;
  }

  @override
  Future<bool> requestUsbPermission(UsbDevice device) async {
    final result = await methodChannel.invokeMethod<bool>('requestUsbPermission', {
      'vendorId': device.vendorId,
      'productId': device.productId,
    });
    return result ?? false;
  }

  @override
  Future<bool> connect(UsbDevice device, {int baudRate = 9600}) async {
    final result = await methodChannel.invokeMethod<bool>('connect', {
      'vendorId': device.vendorId,
      'productId': device.productId,
      'baudRate': baudRate,
    });
    return result ?? false;
  }

  @override
  Future<bool> isConnected() async {
    final result = await methodChannel.invokeMethod<bool>('isConnected');
    return result ?? false;
  }

  @override
  Future<void> disconnect() {
    return methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<void> write(String data) {
    // Native reads this under the "Data" key (capital D).
    return methodChannel.invokeMethod<void>('write', {'Data': data});
  }

  @override
  Future<String> read({RawReadConfig config = const RawReadConfig()}) async {
    final result = await methodChannel.invokeMethod<String>('read', config.toMap());
    return result ?? '';
  }

  @override
  Future<UsbDevice?> getConnectedDevice() async {
    final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('getConnectedDevice');
    if (result == null) return null;
    return UsbDevice.fromMap(Map<String, dynamic>.from(result));
  }

  @override
  Future<Map<String, double>?> readSoilData({
    SoilSensorConfig config = const SoilSensorConfig(),
  }) async {
    final result =
        await methodChannel.invokeMethod<Map<dynamic, dynamic>>('readSoilData', config.toMap());
    if (result == null) return null;
    return result.map((key, value) => MapEntry(key as String, (value as num).toDouble()));
  }

  @override
  Future<void> onReadInterval({
    RawReadConfig config = const RawReadConfig(),
    int intervalMs = 1000,
  }) {
    return methodChannel.invokeMethod<void>('onReadInterval', {
      ...config.toMap(),
      'intervalMs': intervalMs,
    });
  }

  @override
  Future<void> offReadInterval() {
    return methodChannel.invokeMethod<void>('offReadInterval');
  }

  @override
  Future<void> onReadSoilDataInterval({
    SoilSensorConfig config = const SoilSensorConfig(),
    int intervalMs = 1000,
  }) {
    return methodChannel.invokeMethod<void>('onReadSoilDataInterval', {
      ...config.toMap(),
      'intervalMs': intervalMs,
    });
  }

  @override
  Future<void> offReadSoilDataInterval() {
    return methodChannel.invokeMethod<void>('offReadSoilDataInterval');
  }

  @override
  Stream<String> get serialDataStream {
    return _rawEvents
        .where((event) => event['event'] == 'USB_SERIAL_DATA')
        .map((event) => (event['data'] as Map)['data'] as String? ?? '');
  }

  @override
  Stream<Map<String, double>> get soilDataStream {
    return _rawEvents.where((event) => event['event'] == 'USB_SOIL_DATA').map((event) {
      final data = Map<String, dynamic>.from(event['data'] as Map);
      return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
    });
  }
}
