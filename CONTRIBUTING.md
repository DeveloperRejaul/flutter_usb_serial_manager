# Contributing to flutter_usb_serial_manager

Thanks for taking the time to contribute! This project is a small, focused Android USB-serial plugin for Flutter, and contributions of all sizes — bug reports, docs fixes, tests, new features — are welcome.

By participating in this project you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md).

## Table of contents

- [Before you start](#before-you-start)
- [Project structure](#project-structure)
- [Development setup](#development-setup)
- [Running the example app](#running-the-example-app)
- [Coding style](#coding-style)
- [Commit message convention](#commit-message-convention)
- [Branch naming](#branch-naming)
- [Pull request checklist](#pull-request-checklist)
- [Reporting bugs](#reporting-bugs)
- [Suggesting features](#suggesting-features)
- [Releasing](#releasing)

## Before you start

- For anything beyond a small fix, please open an issue first to discuss the change — it saves everyone time if the approach needs adjusting.
- This plugin is **Android-only** by design (see the [README](README.md#supported-platforms)); iOS/web/desktop support is out of scope.
- Check open issues and pull requests to avoid duplicate work.

## Project structure

```
lib/                            # Dart API surface (platform interface + method channel + models)
  modals/                       # UsbDevice, RawReadConfig, SoilSensorConfig
android/                        # Native Android plugin implementation (Kotlin)
example/                        # Runnable example app / manual test console
doc/screenshots/                # Images used in the README
.github/workflows/              # CI: tagging + pub.dev publishing
```

## Development setup

1. Install the [Flutter SDK](https://docs.flutter.dev/get-started/install) (matching the version constraint in `pubspec.yaml`) and Android Studio / the Android SDK.
2. Fork the repo and clone your fork.
3. Fetch dependencies:

   ```sh
   flutter pub get
   cd example && flutter pub get && cd ..
   ```
4. Verify everything builds and lints cleanly before making changes:

   ```sh
   flutter analyze
   ```

## Running the example app

The [`example/`](example) app is a full manual test console for every plugin method — use it to verify changes against real USB serial hardware (a USB-OTG capable Android device is required; the Android emulator does not support USB host mode).

```sh
cd example
flutter run
```

If you change native (Kotlin) code, rebuild the APK to pick it up:

```sh
flutter build apk --debug
```

## Coding style

- Run `flutter analyze` and fix any warnings before opening a PR — CI enforces a clean `flutter_lints` run.
- Match the existing style: doc comments (`///`) on public Dart APIs, small focused methods on the native side, and `try`/`catch` around every native `MethodCall` handler that can throw.
- Keep the Dart models (`UsbDevice`, `RawReadConfig`, `SoilSensorConfig`) in sync with their native Kotlin counterparts (`com.rezaul.usbserial.*`) — field names and defaults should match on both sides.
- Prefer adding to the typed API over exposing raw `Map`/`dynamic` in public method signatures.

## Commit message convention

Please use [Conventional Commits](https://www.conventionalcommits.org/) style prefixes — they make the auto-generated release notes readable:

- `feat: ...` — a new feature
- `fix: ...` — a bug fix
- `docs: ...` — documentation only
- `chore: ...` — tooling, CI, formatting, dependency bumps
- `refactor: ...` — code change that neither fixes a bug nor adds a feature
- `test: ...` — adding or fixing tests

Example: `fix: correct vendorId in native usbDeviceToMap()`

## Branch naming

Branch off `main` using a short, descriptive name prefixed by type, e.g.:

- `feat/parity-config`
- `fix/connect-baud-rate-cast`
- `docs/readme-screenshots`

## Pull request checklist

Before opening a PR, please make sure:

- [ ] `flutter analyze` passes with no new warnings.
- [ ] Public API changes have doc comments and, if user-facing, are reflected in the [README](README.md#api-reference).
- [ ] `CHANGELOG.md` has a new entry under `## Unreleased` (or the next version) describing the change.
- [ ] Native (Kotlin) changes were tested on a real device via the example app — the Android emulator cannot exercise USB host mode.
- [ ] Commit messages follow the [convention above](#commit-message-convention).

## Reporting bugs

Please use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.yml) and include:

- Plugin version, Flutter/Dart version, and Android version/device.
- The exact USB device involved (vendor/product ID from `getDeviceList()`, if possible).
- Steps to reproduce, expected vs. actual behavior, and relevant `adb logcat` output.

## Suggesting features

Please use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.yml) and describe the use case, not just the desired API — it helps find the simplest solution that fits the plugin's scope.

## Releasing

Releases are automated; see [README → Releasing](README.md#releasing) for how version bumps become tagged GitHub Releases and pub.dev publishes. Only maintainers with pub.dev publishing access need to worry about the one-time trusted-publisher setup described there.
