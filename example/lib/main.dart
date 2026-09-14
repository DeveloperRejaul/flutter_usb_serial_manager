import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_usb_serial_manager/flutter_usb_serial_manager.dart';
import 'package:flutter_usb_serial_manager/modals/raw_read_config.dart';
import 'package:flutter_usb_serial_manager/modals/soil_sensor_config.dart';
import 'package:flutter_usb_serial_manager/modals/usb_device.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB Serial Manager example',
      home: const UsbSerialTestPage(),
    );
  }
}

class UsbSerialTestPage extends StatefulWidget {
  const UsbSerialTestPage({super.key});

  @override
  State<UsbSerialTestPage> createState() => _UsbSerialTestPageState();
}

class _UsbSerialTestPageState extends State<UsbSerialTestPage> {
  final _usb = FlutterUsbSerialManager();

  // --- device list / selection ---
  List<UsbDevice> _devices = [];
  UsbDevice? _selected;
  bool? _hasPermission;

  // --- connection ---
  final _baudRateCtrl = TextEditingController(text: '9600');
  bool _isConnected = false;
  UsbDevice? _connectedDevice;

  // --- write / one-shot read ---
  final _writeCtrl = TextEditingController(text: 'Hello device');
  final _readBufferCtrl = TextEditingController(text: '1024');
  final _readTimeoutCtrl = TextEditingController(text: '1000');
  String _readResult = '';

  // --- soil sensor one-shot ---
  final _slaveIdCtrl = TextEditingController(text: '1');
  final _startAddressCtrl = TextEditingController(text: '0');
  final _registerCountCtrl = TextEditingController(text: '8');
  final _responseDelayCtrl = TextEditingController(text: '300');
  Map<String, double>? _soilResult;

  // --- interval streaming ---
  final _intervalMsCtrl = TextEditingController(text: '1000');
  bool _rawStreaming = false;
  bool _soilStreaming = false;
  StreamSubscription<String>? _rawSub;
  StreamSubscription<Map<String, double>>? _soilSub;
  final List<String> _rawLog = [];
  final List<String> _soilLog = [];

  // --- generic status/output log for one-shot calls ---
  final List<String> _statusLog = [];

  @override
  void initState() {
    super.initState();
    _refreshDeviceList();
  }

  @override
  void dispose() {
    _rawSub?.cancel();
    _soilSub?.cancel();
    _baudRateCtrl.dispose();
    _writeCtrl.dispose();
    _readBufferCtrl.dispose();
    _readTimeoutCtrl.dispose();
    _slaveIdCtrl.dispose();
    _startAddressCtrl.dispose();
    _registerCountCtrl.dispose();
    _responseDelayCtrl.dispose();
    _intervalMsCtrl.dispose();
    super.dispose();
  }

  void _log(String message) {
    setState(() {
      _statusLog.insert(0, message);
      if (_statusLog.length > 30) _statusLog.removeLast();
    });
  }

  int _parseInt(TextEditingController c, int fallback) => int.tryParse(c.text) ?? fallback;

  // ---------------- device list ----------------

  Future<void> _refreshDeviceList() async {
    try {
      final devices = await _usb.getDeviceList();
      if (!mounted) return;
      setState(() {
        _devices = devices;
        if (_selected != null && !_devices.contains(_selected)) {
          _selected = null;
          _hasPermission = null;
        }
      });
      _log('getDeviceList -> ${devices.length} device(s)');
    } on PlatformException catch (e) {
      _log('getDeviceList ERROR: ${e.message}');
    }
  }

  void _selectDevice(UsbDevice device) {
    setState(() {
      _selected = device;
      _hasPermission = null;
    });
  }

  // ---------------- permission ----------------

  Future<void> _checkPermission() async {
    final device = _selected;
    if (device == null) return;
    try {
      final granted = await _usb.hasPermission(device);
      setState(() => _hasPermission = granted);
      _log('hasPermission -> $granted');
    } on PlatformException catch (e) {
      _log('hasPermission ERROR: ${e.message}');
    }
  }

  Future<void> _requestPermission() async {
    final device = _selected;
    if (device == null) return;
    try {
      final granted = await _usb.requestUsbPermission(device);
      setState(() => _hasPermission = granted);
      _log('requestUsbPermission -> $granted');
    } on PlatformException catch (e) {
      _log('requestUsbPermission ERROR: ${e.message}');
    }
  }

  // ---------------- connection ----------------

  Future<void> _connect() async {
    final device = _selected;
    if (device == null) return;
    try {
      final baudRate = _parseInt(_baudRateCtrl, 9600);
      final connected = await _usb.connect(device, baudRate: baudRate);
      setState(() => _isConnected = connected);
      _log('connect(baudRate: $baudRate) -> $connected');
    } on PlatformException catch (e) {
      _log('connect ERROR: ${e.message}');
    }
  }

  Future<void> _disconnect() async {
    try {
      await _usb.disconnect();
      setState(() {
        _isConnected = false;
        _rawStreaming = false;
        _soilStreaming = false;
      });
      await _rawSub?.cancel();
      await _soilSub?.cancel();
      _log('disconnect() done');
    } on PlatformException catch (e) {
      _log('disconnect ERROR: ${e.message}');
    }
  }

  Future<void> _refreshIsConnected() async {
    try {
      final connected = await _usb.isConnected();
      setState(() => _isConnected = connected);
      _log('isConnected -> $connected');
    } on PlatformException catch (e) {
      _log('isConnected ERROR: ${e.message}');
    }
  }

  Future<void> _refreshConnectedDevice() async {
    try {
      final device = await _usb.getConnectedDevice();
      setState(() => _connectedDevice = device);
      _log('getConnectedDevice -> $device');
    } on PlatformException catch (e) {
      _log('getConnectedDevice ERROR: ${e.message}');
    }
  }

  // ---------------- write / read ----------------

  Future<void> _write() async {
    try {
      await _usb.write(_writeCtrl.text);
      _log('write("${_writeCtrl.text}") done');
    } on PlatformException catch (e) {
      _log('write ERROR: ${e.message}');
    }
  }

  Future<void> _read() async {
    try {
      final config = RawReadConfig(
        bufferSize: _parseInt(_readBufferCtrl, 1024),
        timeout: _parseInt(_readTimeoutCtrl, 1000),
      );
      final data = await _usb.read(config: config);
      setState(() => _readResult = data);
      _log('read() -> ${data.length} char(s)');
    } on PlatformException catch (e) {
      _log('read ERROR: ${e.message}');
    }
  }

  // ---------------- soil sensor one-shot ----------------

  SoilSensorConfig get _soilConfig => SoilSensorConfig(
        slaveId: _parseInt(_slaveIdCtrl, 1),
        startAddress: _parseInt(_startAddressCtrl, 0),
        registerCount: _parseInt(_registerCountCtrl, 8),
        responseDelayMs: _parseInt(_responseDelayCtrl, 300),
      );

  Future<void> _readSoilData() async {
    try {
      final data = await _usb.readSoilData(config: _soilConfig);
      setState(() => _soilResult = data);
      _log('readSoilData -> $data');
    } on PlatformException catch (e) {
      _log('readSoilData ERROR: ${e.message}');
    }
  }

  // ---------------- interval streams ----------------

  Future<void> _toggleRawInterval() async {
    if (_rawStreaming) {
      await _usb.offReadInterval();
      await _rawSub?.cancel();
      setState(() => _rawStreaming = false);
      _log('offReadInterval() done');
      return;
    }

    try {
      final config = RawReadConfig(
        bufferSize: _parseInt(_readBufferCtrl, 1024),
        timeout: _parseInt(_readTimeoutCtrl, 1000),
      );
      _rawSub = _usb.serialDataStream.listen((data) {
        setState(() {
          _rawLog.insert(0, data);
          if (_rawLog.length > 50) _rawLog.removeLast();
        });
      });
      await _usb.onReadInterval(config: config, intervalMs: _parseInt(_intervalMsCtrl, 1000));
      setState(() => _rawStreaming = true);
      _log('onReadInterval() started');
    } on PlatformException catch (e) {
      _log('onReadInterval ERROR: ${e.message}');
    }
  }

  Future<void> _toggleSoilInterval() async {
    if (_soilStreaming) {
      await _usb.offReadSoilDataInterval();
      await _soilSub?.cancel();
      setState(() => _soilStreaming = false);
      _log('offReadSoilDataInterval() done');
      return;
    }

    try {
      _soilSub = _usb.soilDataStream.listen((data) {
        setState(() {
          _soilLog.insert(0, data.toString());
          if (_soilLog.length > 50) _soilLog.removeLast();
        });
      });
      await _usb.onReadSoilDataInterval(
        config: _soilConfig,
        intervalMs: _parseInt(_intervalMsCtrl, 1000),
      );
      setState(() => _soilStreaming = true);
      _log('onReadSoilDataInterval() started');
    } on PlatformException catch (e) {
      _log('onReadSoilDataInterval ERROR: ${e.message}');
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('USB Serial Manager — test console')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section(
            title: 'Devices',
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDeviceList,
            ),
            children: [
              if (_devices.isEmpty) const Text('No USB device found.'),
              for (final device in _devices)
                RadioListTile<UsbDevice>(
                  contentPadding: EdgeInsets.zero,
                  value: device,
                  groupValue: _selected,
                  onChanged: (_) => _selectDevice(device),
                  title: Text('vendorId: ${device.vendorId}, productId: ${device.productId}'),
                  subtitle: Text('manufacturer: ${device.manufacturer ?? '-'}'),
                ),
            ],
          ),
          _section(
            title: 'Permission',
            children: [
              Text('Selected: ${_selected ?? '-'}'),
              Text('hasPermission: ${_hasPermission ?? '-'}'),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _selected == null ? null : _checkPermission,
                    child: const Text('hasPermission()'),
                  ),
                  ElevatedButton(
                    onPressed: _selected == null ? null : _requestPermission,
                    child: const Text('requestUsbPermission()'),
                  ),
                ],
              ),
            ],
          ),
          _section(
            title: 'Connection',
            children: [
              TextField(
                controller: _baudRateCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'baudRate'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _selected == null ? null : _connect,
                    child: const Text('connect()'),
                  ),
                  ElevatedButton(onPressed: _disconnect, child: const Text('disconnect()')),
                  OutlinedButton(
                    onPressed: _refreshIsConnected,
                    child: const Text('isConnected()'),
                  ),
                  OutlinedButton(
                    onPressed: _refreshConnectedDevice,
                    child: const Text('getConnectedDevice()'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('isConnected: $_isConnected'),
              Text('connectedDevice: ${_connectedDevice ?? '-'}'),
            ],
          ),
          _section(
            title: 'Write / Read',
            children: [
              TextField(
                controller: _writeCtrl,
                decoration: const InputDecoration(labelText: 'data to write'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _write, child: const Text('write()')),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _readBufferCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'bufferSize'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _readTimeoutCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'timeout (ms)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _read, child: const Text('read()')),
              const SizedBox(height: 8),
              Text('result: $_readResult'),
            ],
          ),
          _section(
            title: 'Soil sensor (one-shot)',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _slaveIdCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'slaveId'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _startAddressCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'startAddress'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _registerCountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'registerCount'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _responseDelayCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'responseDelayMs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: _readSoilData, child: const Text('readSoilData()')),
              const SizedBox(height: 8),
              Text('result: ${_soilResult ?? '-'}'),
            ],
          ),
          _section(
            title: 'Interval streams',
            children: [
              TextField(
                controller: _intervalMsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'intervalMs (shared)'),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _toggleRawInterval,
                    style: _rawStreaming
                        ? ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100)
                        : null,
                    child: Text(_rawStreaming ? 'offReadInterval()' : 'onReadInterval()'),
                  ),
                  ElevatedButton(
                    onPressed: _toggleSoilInterval,
                    style: _soilStreaming
                        ? ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100)
                        : null,
                    child: Text(
                      _soilStreaming ? 'offReadSoilDataInterval()' : 'onReadSoilDataInterval()',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('serialDataStream:', style: TextStyle(fontWeight: FontWeight.bold)),
              _logBox(_rawLog),
              const SizedBox(height: 8),
              const Text('soilDataStream:', style: TextStyle(fontWeight: FontWeight.bold)),
              _logBox(_soilLog),
            ],
          ),
          _section(
            title: 'Call log',
            children: [_logBox(_statusLog)],
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _logBox(List<String> lines) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: lines.isEmpty
          ? const Text('—', style: TextStyle(color: Colors.white38))
          : ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) => Text(
                lines[index],
                style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 12),
              ),
            ),
    );
  }
}
