**English** · [한국어](CONTRIBUTING.ko.md)

# Contributing to ClockHandKit

Thank you for helping investigate and document
WidgetKit's clock-hand rotation behavior.

ClockHandKit relies on private WidgetKit behavior. Reproducible compatibility
reports, diagnostics, tests, and documentation are especially valuable.

## Before opening an issue

Search existing issues first. Then identify where the failure occurs:

1. Package compilation or linking
2. Runtime lookup, payload decoding, or modifier construction
3. Visible animation in an installed Home Screen widget
4. App Store Connect processing, TestFlight, or App Review

A successful build does not establish runtime behavior.

Describe what you tested, where you tested it, and what you observed.

## Compatibility reports

Please include:

- ClockHandKit release or commit
- Xcode version, build number, and linked iOS SDK
- iOS version, build number, and device or simulator model
- Where the result was observed: preview, simulator app, widget gallery, or an
  installed Home Screen widget
- Test app and widget bundle identifiers; use non-production identifiers
- Expected behavior, observed behavior, and the stage that failed
- Relevant `com.clockhandkit` / `runtime-bridge` logs
- A minimal reproduction project or short screen recording when possible

Useful version commands include:

```shell
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
```

Filter ClockHandKit logs with:

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## Local development

ClockHandKit is an iOS-only Swift package. List available destinations, then
build and test against an installed iOS Simulator:

```shell
xcodebuild -scheme ClockHandKit -showdestinations

xcodebuild \
  -scheme ClockHandKit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  build

xcodebuild \
  -scheme ClockHandKit \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  test
```

Replace the destination with one installed on your machine. Also verify that
the package manifest can be loaded:

```shell
swift package dump-package
```

Runtime bridge tests do not replace installing the example widget and checking
its animation in the widget host.

## Pull requests

Before submitting a pull request:

1. Open an issue first for behavior changes or substantial API changes.
2. Keep the change focused.
3. Add or update relevant tests.
4. Build and test against an iOS Simulator.
5. Keep the English and Korean documentation in sync.
6. State exactly what was verified, including Xcode, SDK, runtime, and test
   environment details.

## Implementation guidelines

- Preserve fail-open behavior: return the original view if a private runtime
  step fails.
- Keep runtime bridge failures observable through structured logging.
- Treat type names, Codable layouts, and private conformances as unstable.
- Support private-framework claims with a reproducible probe, binary evidence,
  or both.
- Prefer small public APIs and keep reverse-engineering details internal.
- Do not add telemetry or collect user data.

## Documentation and attribution

Use neutral, evidence-based language. Clearly distinguish confirmed behavior,
maintainer reports, independent reproduction, and inference.

Preserve attribution to
[octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit)
and credit contributors whose research or code a change builds upon.

## License

By submitting a contribution, you agree that it may be distributed under the
project's [MIT License](LICENSE).
