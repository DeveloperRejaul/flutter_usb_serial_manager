package com.useserialmanager.flutter_usb_serial_manager

import android.hardware.usb.UsbDevice
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.rezaul.usbserial.UsbManager
import com.rezaul.usbserial.SoilSensorConfig
import com.rezaul.usbserial.RawReadConfig
import io.flutter.plugin.common.EventChannel

class FlutterUsbSerialManagerPlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler{
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var usbManager: UsbManager

    // handle event
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private val handler = Handler(Looper.getMainLooper())


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_usb_serial_manager")
        channel.setMethodCallHandler(this)

        // handle event
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_usb_serial_manager/events")
        eventChannel.setStreamHandler(this)

        // handle usb manager
        usbManager = UsbManager(flutterPluginBinding.applicationContext)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
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
            "onReadInterval" ->  onReadInterval(call, result)
            "offReadInterval" ->  offReadInterval(call, result)
            "onReadSoilDataInterval" ->  onReadSoilDataInterval(call, result)
            "offReadSoilDataInterval" ->  offReadSoilDataInterval(call, result)
            else -> result.notImplemented()
        }
    }

    fun onReadSoilDataInterval (call: MethodCall, result: Result) {
        try {
            val slaveId = call.argument<Int>("slaveId") ?: 1
            val startAddress = call.argument<Int>("startAddress") ?: 0x0000
            val registerCount = call.argument<Int>("registerCount") ?: 8
            val responseDelayMs = call.argument<Int>("responseDelayMs") ?: 300
            val intervalMs = call.argument<Int>("intervalMs") ?: 1000
            val soilConfig = SoilSensorConfig(slaveId, startAddress, registerCount, responseDelayMs)

            usbManager.utils.onReadSoilDataInterval(
                intervalMs = intervalMs.toLong(),
                onDataReceived = { soilData: Map<String, Double?> ->
                    val map = mutableMapOf<String, Any>()

                    soilData.forEach { (key: String, value: Double?) ->
                        if (value != null) {
                            map[key]= value
                        }
                    }

                    sendEvent("USB_SOIL_DATA", map)
                },
                config = soilConfig
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun offReadSoilDataInterval (call: MethodCall, result: Result) {
        try {
            usbManager.utils.offReadSoilDataInterval()
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(),e.message.toString() )
        }
    }
    fun onReadInterval (call: MethodCall, result: Result) {
        try {
            val bufferSize = call.argument<Int>("bufferSize") ?: 1024
            val timeout = call.argument<Int>("timeout") ?: 1000
            val intervalMs = call.argument<Int>("intervalMs") ?: 1000
            val readConfig = RawReadConfig(bufferSize, timeout)

            usbManager.onReadInterval(
                intervalMs = intervalMs.toLong(),
                onDataReceived = { bytes: ByteArray ->
                    val map = mutableMapOf<String, Any>()
                    map["data"]=String(bytes)
                    sendEvent("USB_SERIAL_DATA", map)
                },
                config = readConfig
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun offReadInterval (call: MethodCall, result: Result) {
        try {
            usbManager.offReadInterval()
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun getDeviceList(call: MethodCall, result: Result) {
        val devices: List<UsbDevice> = usbManager.getDeviceList()
        val payload : List<Map<String, Any?>> = devices.map { it -> usbDeviceToMap(it)}
        result.success(payload)
    }
    fun hasPermission(call: MethodCall, result: Result) {
        try {
            val vendorId = call.argument<Int>("vendorId") ?: 0
            val productId = call.argument<Int>("productId") ?:  0
            val map = mapOf("vendorId" to vendorId, "productId" to productId)
            val usbDevice = readableMapToUsbDevice(map)

            if (usbDevice == null) {
                result.error("ERROR", "DEVICE_NOT_FOUND", "USB device not found")
                return
            }

            val hasPermission = usbManager.hasPermission(usbDevice)
            result.success(hasPermission)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun requestUsbPermission(call: MethodCall, result: Result) {
        try {
            val vendorId = call.argument<Int>("vendorId") ?: 0
            val productId = call.argument<Int>("productId") ?:  0
            val map = mapOf("vendorId" to vendorId, "productId" to productId)
            val usbDevice = readableMapToUsbDevice(map)
            if (usbDevice == null) {
                result.error("DEVICE_NOT_FOUND", "USB device not found", "USB device not found")
                return
            }

            usbManager.requestUsbPermission(usbDevice) { granted ->
                result.success(granted)
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun connect(call: MethodCall, result: Result) {
        try {
            val vendorId = call.argument<Int>("vendorId") ?: 0
            val productId = call.argument<Int>("productId") ?:  0
            // MethodChannel sends whatever numeric type Dart used (int or
            // double), so accept either instead of assuming Double.
            val baud = (call.argument<Any>("baudRate") as? Number)?.toInt() ?: 9600
            val map = mapOf("vendorId" to vendorId, "productId" to productId)

            val usbDevice = readableMapToUsbDevice(map)
            if (usbDevice == null) {
                result.error("DEVICE_NOT_FOUND", "USB device not found","USB device not found")
                return
            }

            val connected = usbManager.connect(usbDevice, baud)
            result.success(connected)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(),e.message.toString() )
        }
    }
    fun  isConnected(call: MethodCall, result: Result) {
        try {
            val connected = usbManager.isConnected()
            result.success(connected)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(),e.message.toString())
        }
    }
    fun  disconnect(call: MethodCall, result: Result) {
        try {
            usbManager.offReadInterval()
            usbManager.utils.offReadSoilDataInterval()
            usbManager.disconnect()
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun  write(call: MethodCall, result: Result) {
        try {
            val data = call.argument<String>("Data") ?: ""
            usbManager.write(data.toByteArray())
            result.success(null)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(),e.message.toString())
        }
    }
    fun  read(call: MethodCall, result: Result) {
        try {
            val bufferSize = call.argument<Int>("bufferSize") ?: 1024
            val timeoutVal = call.argument<Int>("timeout") ?: 1000
            val data = usbManager.read(bufferSize, timeoutVal)
            result.success(String(data))
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }
    fun  getConnectedDevice(call: MethodCall, result: Result) {
        try {
            val device = usbManager.getConnectedDevice()
            if (device == null) {
                result.success(null)
            } else {
                result.success(usbDeviceToMap(device))
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(),e.message.toString() )
        }
    }
    fun  readSoilData(call: MethodCall, result: Result) {
        try {
            val slaveId = call.argument<Int>("slaveId") ?: 1
            val startAddress = call.argument<Int>("startAddress") ?: 0x0000
            val registerCount = call.argument<Int>("registerCount") ?: 8
            val responseDelayMs = call.argument<Int>("responseDelayMs") ?: 300

            val data = usbManager.utils.readSoilData(slaveId, startAddress, registerCount, responseDelayMs)
            if (data == null) {
                result.success(null)
                return
            }

            val map = mutableMapOf<String, Any>()
            data.forEach { (key: String, value: Double?) ->
                if (value != null) {
                   map[key]= value
                }
            }

            result.success(map)
        } catch (e: Exception) {
            result.error("ERROR", e.message.toString(), e.message.toString())
        }
    }


    private fun readableMapToUsbDevice(map: Map<String, Int>): UsbDevice? {
        val devices = usbManager.getDeviceList()
        val vendorId = map["vendorId"]
        val productId = map["productId"]

        for (device in devices) {
            if (device.vendorId == vendorId && device.productId == productId) {
                return device
            }
        }
        return null
    }
    private fun usbDeviceToMap(device: UsbDevice): Map<String, Any?> {
      return mapOf<String, Any?>(
           "vendorId" to device.vendorId,
           "productId" to device.productId,
           "manufacturer" to device.manufacturerName,
      )
    }


    private fun sendEvent(event: String, data: Map<String, Any>) {
        handler.post {
            eventSink?.success(
                mapOf(
                    "event" to event,
                    "data" to data
                )
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
