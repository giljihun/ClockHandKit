# Contributing to ClockHandKit

Thank you for helping investigate and document WidgetKit's clock-hand rotation
behavior.

ClockHandKit is an experimental private-API research project. Contributions
should improve reproducibility, compatibility knowledge, diagnostics, tests, or
documentation. Changes intended to conceal private-API usage, evade review, or
present the package as App Store-safe will not be accepted.

## Before opening an issue

Please search existing issues and separate the stage that failed:

1. Package compilation
2. App or widget extension linking
3. Runtime type lookup and payload decoding
4. Modifier construction
5. Visible animation in an installed Home Screen widget
6. App Store Connect processing, TestFlight, or App Review

“It works” and “it does not work” are not sufficient on their own. A successful
build does not establish runtime behavior, and successful processing does not
establish App Store compliance.

## Compatibility reports

Compatibility reports are the most valuable contribution at this stage. Please
include:

- ClockHandKit revision or release
- Xcode version and build number
- Linked iOS SDK version
- Runtime iOS version and build number
- Physical device model or simulator model
- Whether the result came from an app preview, simulator app, widget gallery,
  or installed Home Screen widget
- Test app and widget bundle identifiers; use disposable test identifiers and
  do not publish credentials or production secrets
- Whether each of the six stages above passed or failed
- Relevant `com.clockhandkit` / `runtime-bridge` logs
- A minimal reproduction project when possible

Useful version commands include:

```shell
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
```

Filter ClockHandKit logs with:

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

For visible animation reports, a short screen recording is especially helpful.

## Local development

ClockHandKit is an iOS-only Swift package. List available simulator destinations
and then build and test against an installed iOS Simulator:

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

Substitute a destination that exists on your machine. Also verify that the
package manifest can be loaded:

```shell
swift package dump-package
```

Runtime construction tests are not a substitute for installing the example
widget and confirming its animation in the actual widget host.

## Pull requests

Before submitting a pull request:

1. Open an issue first for behavior changes or substantial API changes.
2. Keep the change focused and avoid unrelated formatting.
3. Add or update tests for payload and period behavior when applicable.
4. Build and test against an iOS Simulator.
5. Update both `README.md` and `README.ko.md` when user-facing facts change.
6. State exactly what was verified and what remains unverified.
7. Include the Xcode, SDK, and runtime versions used for verification.

Do not describe simulator probes as physical-device results or TestFlight
processing as App Store approval.

## Implementation guidelines

- Preserve fail-open behavior: if a private runtime step fails, return the
  original view instead of crashing the widget.
- Keep runtime bridge failures observable through structured logging.
- Treat type names, Codable layouts, and private conformances as unstable.
- Support claims about private-framework behavior with a reproducible probe,
  binary evidence, or both.
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
