import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_usb_serial_manager/flutter_usb_serial_manager.dart';
import 'package:flutter_usb_serial_manager/modals/usb_device.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<UsbDevice> _deviceList = [];
  final _flutterUsbSerialManagerPlugin = FlutterUsbSerialManager();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    List<UsbDevice> deviceList;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      deviceList = await _flutterUsbSerialManagerPlugin.getDeviceList();
    } on PlatformException {
      deviceList = [];
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _deviceList = deviceList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Device List:'),
            for (var device in _deviceList)
              Text('Device: ${device.vendorId}, Vendor ID: ${device.vendorId}, Product ID: ${device.productId}'),
          ],
        )
        ),
      ),
    );
  }
}
