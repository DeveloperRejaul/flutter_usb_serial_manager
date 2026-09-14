## 0.0.3

* Fix the release pipeline: the tag → publish steps now run in a single
  workflow job chain instead of relying on a tag push (made with the
  default `GITHUB_TOKEN`) to trigger a separate workflow, which GitHub
  Actions deliberately does not do. No functional changes since 0.0.1.

## 0.0.2

* Test release to verify the automated tag → GitHub Release → pub.dev
  publish pipeline (GitHub Actions + pub.dev trusted publishing) end to end.
  No functional changes since 0.0.1.

## 0.0.1

* Initial release (Android only).
* Device discovery, USB permission handling, connect/disconnect at a custom baud rate.
* Raw `write`/`read`, plus interval-based live raw serial streaming.
* Built-in Modbus RTU soil-sensor helper: one-shot `readSoilData` and a live `soilDataStream`.
* Typed models: `UsbDevice`, `RawReadConfig`, `SoilSensorConfig`.
