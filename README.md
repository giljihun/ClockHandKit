**English** · [한국어](README.ko.md)

> [!CAUTION]
> **Experimental private-API research project.**
>
> ClockHandKit depends on undocumented WidgetKit internals and an underscored
> Swift runtime lookup. Apple may change or remove either without notice.
> [App Review Guideline 2.5.1](https://developer.apple.com/app-store/review/guidelines/#software-requirements)
> requires apps to use public APIs. An app using this package may be rejected,
> and passing a local build or TestFlight upload does not establish App Store
> compliance.
>
> Physical-device, TestFlight, and App Store verification is still pending.
> Do not treat this package as production-ready.

# ClockHandKit

An experimental, source-based Swift package for applying WidgetKit's
undocumented clock-hand rotation modifier to widget views.

ClockHandKit was created in response to an iOS 26.1 behavior change: the direct
private `_clockHandRotationEffect` entry point used by
[ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit) becomes a
runtime no-op for third-party apps in a specific linked-SDK/runtime combination.

This is an independent implementation. It is not affiliated with or endorsed
by Apple or the ClockHandRotationKit maintainers.

## Why this project exists

Starting with iOS 26.1, binary inspection and runtime probes indicate that
WidgetKit conditionally applies the private entry point according to the app's
linked SDK and bundle identifier. For a third-party app linked against the iOS
26.1 SDK and running on iOS 26.1, the entry point returns the original view
without applying the modifier.

The legacy entry point was reproduced as follows:

| Runtime | Linked SDK | Bundle | Result |
| --- | --- | --- | --- |
| iOS 26.0 | iOS 26.0 or 26.1 | Third-party | Modifier returned |
| iOS 26.1 | iOS 26.0 | Third-party | Modifier returned |
| iOS 26.1 | iOS 26.1 | Third-party | Original view returned |
| iOS 26.1 | iOS 26.1 | Apple Clock bundle prefix | Modifier returned |

This is a runtime linked-SDK/OS interaction—not a general compilation failure,
a Swift-language-version mismatch, or an iOS 26.1 JSON-format migration. Xcode
26.1 appears to trigger the regression because it links against the iOS 26.1
SDK; the underlying change is inside the iOS 26.1 WidgetKit implementation.

See the original [iOS 26.1 compatibility report](https://github.com/octree/ClockHandRotationKit/issues/11)
and the [WidgetKit binary diff](https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304).

## How it works

ClockHandKit does not call the gated private entry point. Instead, it:

1. Resolves `WidgetKit._ClockHandRotationEffect` at runtime with `_typeByName`.
2. Encodes the requested period, time zone, and anchor using the private type's
   observed Codable representation.
3. Decodes that payload into the dynamically resolved type.
4. Casts the value to `any ViewModifier`.
5. Applies the modifier through Swift existential opening.

This path also avoids the Swift 6.2 IRGen failure encountered when declaring
the body-less private `some View` function with `@_silgen_name`.

The payload correction in [pull request #1](https://github.com/giljihun/ClockHandKit/pull/1)
fixed ClockHandKit's original guessed representation: `period` is a
`TimeInterval`, while `timeZone` and `anchor` use the Codable formats synthesized
by `TimeZone` and `UnitPoint`. It was a fix to ClockHandKit's initial
implementation, not evidence of an iOS 26.1 JSON-format change.

If lookup, decoding, or casting fails, ClockHandKit returns the original view
without the rotation effect and records the failed step through `OSLog`.

## Requirements

- iOS 16 or later
- Swift tools 6.2 (Xcode 26 or later)
- SwiftUI and WidgetKit

The package is intended for widget views. Declaring iOS 16 as the deployment
target does not mean every OS version has received end-to-end runtime testing.

## Installation

There is no tagged release yet. In Xcode, choose **File → Add Package
Dependencies**, enter:

```text
https://github.com/giljihun/ClockHandKit.git
```

and select the `main` branch.

For a package manifest:

```swift
dependencies: [
    .package(
        url: "https://github.com/giljihun/ClockHandKit.git",
        branch: "main"
    )
]
```

Because `main` may change while the project is experimental, pin an exact
revision when reproducibility matters.

## Usage

```swift
import SwiftUI
import ClockHandKit

Image(systemName: "arrow.up")
    .clockHandRotationEffect(period: .secondHand)
```

Available periods:

| Value | Encoded duration |
| --- | ---: |
| `.hourHand` | 43,200 seconds |
| `.minuteHand` | 3,600 seconds |
| `.secondHand` | 60 seconds |
| `.custom(seconds)` | The supplied duration |

A custom time zone and anchor can also be supplied:

```swift
hand.clockHandRotationEffect(
    period: .minuteHand,
    in: TimeZone(identifier: "Asia/Seoul")!,
    anchor: .bottom
)
```

## Verification status

Build success, runtime modifier construction, visible widget animation, and
distribution approval are different verification layers.

| Scope | Environment | Status |
| --- | --- | --- |
| Package build | Xcode 26.1, 26.4, and 26.5 | Passed — maintainer-reported |
| Example app and both widget extensions | Xcode 26.5 | Passed — independently reproduced |
| Dynamic modifier construction | Xcode 26.1 SDK → iOS 26.1 simulator, third-party bundle ID | Passed — resulting `ModifiedContent` verified |
| Private type and Codable payload | iOS 26.5 simulator | Passed — lookup, decoding, and conformances verified |
| Visible Home Screen widget animation | Installed widget | Pending |
| Physical device | iOS device | Pending |
| TestFlight processing and testing | App Store Connect | Pending |
| App Store review | App Review | Not App Store-safe; rejection risk is high |

Creating `ModifiedContent` is strong evidence for the runtime bridge, but it is
not proof of visible Home Screen animation or App Store acceptance.

## Migrating from ClockHandRotationKit

1. Remove the `ClockHandRotationKit` package or XCFramework from the target.
2. Add ClockHandKit.
3. Replace the import:

```diff
-import ClockHandRotationKit
+import ClockHandKit
```

ClockHandKit includes a `TimeInterval` overload for source-compatible migration:

```swift
.clockHandRotationEffect(period: 60)
```

The typed API is recommended for new code:

```swift
.clockHandRotationEffect(period: .secondHand)
```

ClockHandKit requires iOS 16 or later, while the upstream package declares iOS
14. Do not import both modules into the same target because their extension
methods may conflict.

## Limitations and diagnostics

- The private type name, conformances, and Codable storage can change at any
  time.
- The bridge fails open: the widget remains visible but stops rotating if an
  internal step fails.
- WidgetKit controls animation scheduling, snapshots, Low Power Mode behavior,
  and refresh behavior.
- The implementation uses `AnyView` type erasure.
- The public API may change before the first stable release.
- App Store acceptance is neither tested nor guaranteed.

ClockHandKit logs each bridge stage with subsystem `com.clockhandkit` and
category `runtime-bridge`. Filter for that subsystem in Console.app, or run:

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## TestFlight and App Store distribution

Apple's [App Review Guideline 2.5.1](https://developer.apple.com/app-store/review/guidelines/#software-requirements)
permits only public APIs, and the
[Apple Developer Program License Agreement](https://developer.apple.com/support/terms/apple-developer-program-license-agreement/)
requires documented APIs to be used in their prescribed manner. Runtime lookup
does not turn a private type into a public API.

In practice:

- An archive may build successfully and App Store Connect may process it, but
  automatic validation can still reject it as non-public API usage.
- Internal TestFlight distribution may become available if processing succeeds;
  that does not make the implementation compliant.
- The [first external TestFlight build](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview)
  is subject to Beta App Review, and an App Store submission is subject to App
  Review. Both have a high rejection risk.
- Passing a previous review would not guarantee future updates, re-scans, or OS
  releases.

Do not hide this behavior from review. If you perform a submission experiment,
describe how to add the widget, the required OS/device, and the expected
animation in Review Notes. Disclosure improves review reproducibility but does
not cure the private-API issue.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull
request. Reproducible compatibility and physical-device reports are especially
valuable.

## Acknowledgements

- [octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit),
  which established the original implementation and API shape.
- [@b5nt](https://github.com/b5nt), who identified and fixed the runtime payload
  representation in [pull request #1](https://github.com/giljihun/ClockHandKit/pull/1).
- The contributors to upstream issue #11 for documenting the compatibility
  matrix.

## License

ClockHandKit is available under the [MIT License](LICENSE).
