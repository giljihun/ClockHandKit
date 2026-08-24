**English** · [한국어](README.ko.md)

# ClockHandKit

> [!CAUTION]
> ClockHandKit uses a private WidgetKit API.
> It may change without notice,
> and apps using it may not pass App Review.

**ClockHandKit** helps you add **real-time clock-hand animations**
to iOS Home Screen widgets.

Apple uses the same effect in its Clock widget but does not expose it as a
public API.
**ClockHandKit** directly accesses WidgetKit's private
`_ClockHandRotationEffect` modifier.

## How rotation creates frame animation

<img src="Documentation/clockhand-frame-animation.gif" width=600>

Arrange multiple animation frames on a circular wheel.
**ClockHandKit** rotates the wheel while a fixed viewport reveals the frames
in sequence.

**ClockHandKit** controls only the rotation.
Your app builds the frame wheel and fixed viewport.

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

## Examples

### Playback speed

**`period` is the time for one full 360° rotation**, not the duration of a
single frame.

```text
period = total frame slots / target FPS
```

The GIF above uses eight slots—frames `1` through `4` repeated twice. A period
of eight seconds advances one slot per second and repeats the four-frame
sequence every four seconds:

```swift
.clockHandRotationEffect(period: .custom(8))
```

For one copy of a 120-frame sequence arranged around the wheel:

| Target rate | Frame interval | `period` |
| ---: | ---: | ---: |
| 12 FPS | 83.33 ms | 10 seconds |
| 24 FPS | 41.67 ms | 5 seconds |
| 30 FPS | 33.33 ms | 4 seconds |
| 60 FPS | 16.67 ms | 2 seconds |

If the same 120-frame sequence is placed twice around the wheel, double the
`period`. These values describe target timing; WidgetKit controls the actual
rendering cadence.

<!-- Add the standalone example repository and real-device playback samples here. -->

## Why ClockHandKit

[ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit) makes
WidgetKit's private clock-hand effect available to third-party widgets.

Starting with iOS 26.1, the behavior of its original entry point depends on
the linked SDK and the running OS:

| Linked SDK | Running OS | Result |
| --- | --- | --- |
| iOS 26.0 SDK | iOS 26.1 | Rotation applied |
| iOS 26.1 SDK | iOS 26.0.x | Rotation applied |
| iOS 26.1 SDK | iOS 26.1 | No rotation |

**Only the last combination fails.**

The code still builds, but WidgetKit returns the original view without the
rotation modifier.

This is a **WidgetKit runtime gate**.
It is not a Swift-version mismatch or a JSON-format change.

ClockHandKit constructs and applies the underlying modifier
without calling the gated entry point.

Further reading:

- [Original iOS 26.1 compatibility report](https://github.com/octree/ClockHandRotationKit/issues/11)
- [WidgetKit binary diff](https://github.com/blacktop/ipsw-diffs/blob/809573f26c4185c71fc786fb9adadab06c50ad0f/26_1_23B5044l__vs_26_1_23B5059e/DYLIBS/WidgetKit.md#L280-L304)

## How it works

1. Resolves `WidgetKit._ClockHandRotationEffect` at runtime.
2. Creates the modifier from its observed Codable representation.
3. Applies it as a SwiftUI `ViewModifier`.

If any step fails, ClockHandKit returns the original view.
The failure is recorded through `OSLog`.

## Requirements

- iOS 16 or later
- Swift tools 6.2
- Xcode 26.1 or later
- SwiftUI and WidgetKit

## Tested environments

### ClockHandKit

| Scope | Environments |
| --- | --- |
| Package builds | Xcode 26.1, 26.4, and 26.5 |
| Example app and both Widget Extensions | Xcode 26.5 |
| Runtime modifier bridge | iOS 26.1 and iOS 26.5 Simulators |

### ClockHandRotationKit compatibility matrix

During root-cause analysis, a minimal ClockHandRotationKit consumer was
compiled and linked across the following matrix.

This was a binary compile-and-link test, not an end-to-end widget runtime test.

| Dimension | Tested values |
| --- | --- |
| Releases | 1.0.0, 1.0.1, 1.1.0 |
| Xcode | 26.0.1 (17A400), 26.1.1 (17B100), 26.5 (17F42) |
| Build target | iOS arm64, Simulator arm64, Simulator x86_64 |
| Configuration | Debug, Release |

`3 releases × 3 Xcode versions × 3 targets × 2 configurations = 54`

**All 54 consumer compile/link combinations succeeded.**

This isolates the regression to runtime behavior rather than compilation or
linking.

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

ClockHandRotationKit declares iOS 14, but ClockHandKit requires iOS 16 or later.

Do not import both modules into the same target.
Their extension methods may conflict.

## Limitations and diagnostics

- **Private API stability:** WidgetKit's type name and Codable representation
  may change.
- **Fail-open behavior:** If the runtime bridge fails, the widget remains
  visible without the rotation effect.

Runtime failures are logged with subsystem `com.clockhandkit` and category
`runtime-bridge`:

```shell
log stream --predicate 'subsystem == "com.clockhandkit"'
```

## Contributing

Please read the [contribution guide](CONTRIBUTING.md)
before opening an issue or pull request.

## Acknowledgements

ClockHandKit was inspired by
[octree/ClockHandRotationKit](https://github.com/octree/ClockHandRotationKit),
which established the original implementation and API design.

## License

ClockHandKit is available under the [MIT License](LICENSE).
