package com.useserialmanager.flutter_usb_serial_manager

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.rezaul.usbserial.UsbManager
import com.rezaul.usbserial.SoilSensorConfig
import com.rezaul.usbserial.RawReadConfig

/** FlutterUsbSerialManagerPlugin */
class FlutterUsbSerialManagerPlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var usbManager: UsbManager

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_usb_serial_manager")
        channel.setMethodCallHandler(this)

        // handle usb manager
        usbManager = UsbManager(flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when(call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "getDeviceList" -> getDeviceList(call, result)
            "hasPermission" -> hasPermission(call, result)
            "requestUsbPermission" -> requestUsbPermission(call, result)
            "connect" -> connect(call, result)
            "isConnected" ->  isConnected(call, result)
            "disconnect" ->  disconnect(call, result)
            "write" ->  write(call, result)
            "read" ->  read(call, result)
            "getConnectedDevice" ->  getConnectedDevice(call, result)
            "readSoilData" ->  readSoilData(call, result)
            else -> result.notImplemented()
        }
    }

    fun getDeviceList(call: MethodCall, result: Result) {}
    fun hasPermission(call: MethodCall, result: Result) {}
    fun requestUsbPermission(call: MethodCall, result: Result) {}
    fun connect(call: MethodCall, result: Result) {}
    fun  isConnected(call: MethodCall, result: Result) {}
    fun  disconnect(call: MethodCall, result: Result) {}
    fun  write(call: MethodCall, result: Result) {}
    fun  read(call: MethodCall, result: Result) {}
    fun  getConnectedDevice(call: MethodCall, result: Result) {}
    fun  readSoilData(call: MethodCall, result: Result) {}

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
