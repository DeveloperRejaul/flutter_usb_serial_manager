## 0.0.7

* Test release: retry after fixing RELEASE_TOKEN's repository access and
  Contents permission (v0.0.6's tag push failed with "Permission to
  ... denied", i.e. the token existed but wasn't scoped correctly). No
  functional changes since 0.0.1.

## 0.0.6

* Test release: `actions/checkout` was persisting a credential for the
  default `GITHUB_TOKEN` that conflicted with the `RELEASE_TOKEN` used to
  push the release tag — the push "succeeded" but GitHub still treated it
  as `GITHUB_TOKEN`-authenticated and never triggered `publish.yml`
  (confirmed: v0.0.5's tag push triggered zero downstream runs). Fixed
  with `persist-credentials: false`. No functional changes since 0.0.1.

## 0.0.5

* Test release: fix `publish.yml`'s tag filter. GitHub Actions tag filters
  are glob patterns, not regex — a bare `+` outside `+(...)` is literal,
  so the old `v[0-9]+.[0-9]+.[0-9]+*` pattern only matched tags containing
  a literal "+" and never actually fired (confirmed: v0.0.4's tag push did
  not trigger it). Now `v*.*.*`. No functional changes since 0.0.1.

## 0.0.4

* Test release: verify pub.dev publishing succeeds now that the release
  tag is pushed with a personal access token (`RELEASE_TOKEN`), producing
  a genuine tag-ref-triggered run for pub.dev's trusted-publisher check.
  No functional changes since 0.0.1.

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
