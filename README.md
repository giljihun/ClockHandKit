**English** · [한국어](README.ko.md)

# ClockHandKit

A Swift package that keeps hour, minute, and second hands moving with real time
in iOS Home Screen widgets built with Xcode 26.1 and later.

> [!CAUTION]
> ClockHandKit uses undocumented WidgetKit APIs that may change without notice and may not pass App Review.

## Usage

```swift
import SwiftUI
import ClockHandKit

Image(systemName: "arrow.up")
    .clockHandRotationEffect(period: .secondHand)
```

Available periods:

| Value | Rotation period |
| --- | ---: |
| `.hourHand` | 43,200 seconds |
| `.minuteHand` | 3,600 seconds |
| `.secondHand` | 60 seconds |
| `.custom(seconds)` | The supplied duration |

A custom time zone and rotation anchor can also be supplied:

```swift
hand.clockHandRotationEffect(
    period: .minuteHand,
    in: TimeZone(identifier: "Asia/Seoul")!,
    anchor: .bottom
)
```

## Why ClockHandKit

[ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit) wraps
WidgetKit's undocumented clock-hand effect. Starting with iOS 26.1, that entry
point stops applying the effect to third-party apps when both the linked SDK and
the running OS are iOS 26.1 or later. The code still builds, but WidgetKit
returns the original view without the rotation modifier.

| Built with | Running on | Original entry point |
| --- | --- | --- |
| Xcode 26.0.1 | iOS 26.1 | Rotation applied |
| Xcode 26.1 | iOS 26.0.x | Rotation applied |
| Xcode 26.1 | iOS 26.1 | No rotation |

**Only the last combination fails:** the app must be built with the new SDK and
run on the new OS for the new WidgetKit behavior to take effect.

This is a WidgetKit runtime gate—not a Swift-version mismatch or a JSON-format
change. ClockHandKit constructs and applies the underlying modifier without
calling the gated entry point.

See the original [iOS 26.1 compatibility report](https://github.com/octree/ClockHandRotationKit/issues/11)
and the [WidgetKit binary diff](https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304).

## How it works

ClockHandKit:

1. Resolves `WidgetKit._ClockHandRotationEffect` at runtime.
2. Creates the modifier from its observed Codable representation.
3. Applies it as a SwiftUI `ViewModifier`.

If any step fails, ClockHandKit returns the original view and records the
failure through `OSLog`.

## Requirements

- iOS 16 or later
- Swift tools 6.2
- Xcode 26.1 or later
- SwiftUI and WidgetKit

## Tested environments

ClockHandKit has been tested in the following environments:

| Scope | Environments |
| --- | --- |
| Package builds | Xcode 26.1, 26.4, and 26.5 |
| Example app and both Widget Extensions | Xcode 26.5 |
| Runtime modifier bridge | iOS 26.1 and iOS 26.5 Simulators |

During root-cause analysis, a minimal ClockHandRotationKit consumer was compiled
and linked across this complete matrix:

| Dimension | Tested values |
| --- | --- |
| ClockHandRotationKit releases | 1.0.0, 1.0.1, 1.1.0 |
| Xcode | 26.0.1 (17A400), 26.1.1 (17B100), 26.5 (17F42) |
| Target | iOS device arm64, iOS Simulator arm64, iOS Simulator x86_64 |
| Configuration | Debug, Release |

That is **3 releases × 3 Xcode versions × 3 targets × 2 configurations = 54
consumer compile/link combinations**. All 54 succeeded, isolating the regression
to runtime behavior rather than compilation.

## Migrating from ClockHandRotationKit

Replace the import:

```diff
-import ClockHandRotationKit
+import ClockHandKit
```

ClockHandKit provides a `TimeInterval` overload for source-compatible
migration:

```swift
.clockHandRotationEffect(period: 60)
```

The typed API is recommended for new code:

```swift
.clockHandRotationEffect(period: .secondHand)
```

ClockHandKit requires iOS 16 or later, while ClockHandRotationKit declares iOS
14. Do not import both modules into the same target because their extension
methods may conflict.

## Limitations and diagnostics

- WidgetKit's private type name and Codable representation may change.
- If the runtime bridge fails, the widget remains visible without the rotation
  effect.

Runtime failures are logged with subsystem `com.clockhandkit` and category
`runtime-bridge`:

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening an issue or pull
request.

## Acknowledgements

ClockHandKit was inspired by
[octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit),
which established the original implementation and API design.

## License

ClockHandKit is available under the [MIT License](LICENSE).
