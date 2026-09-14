## 0.0.1

* Initial release (Android only).
* Device discovery, USB permission handling, connect/disconnect at a custom baud rate.
* Raw `write`/`read`, plus interval-based live raw serial streaming.
* Built-in Modbus RTU soil-sensor helper: one-shot `readSoilData` and a live `soilDataStream`.
* Typed models: `UsbDevice`, `RawReadConfig`, `SoilSensorConfig`.
