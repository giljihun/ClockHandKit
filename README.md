# ClockHandKit

![Status](https://img.shields.io/badge/status-WIP-orange)
![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Xcode](https://img.shields.io/badge/Xcode-26.1%2B-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

A pure-source Swift Package that exposes WidgetKit's private `_clockHandRotationEffect` API for smooth clock hand animations in widgets — a modern replacement for [`octree/ClockHandRotationKit`](https://github.com/octree/ClockHandRotationKit) that breaks on Xcode 26.1+.

## Status

| Component        | State           |
|------------------|-----------------|
| Compile          | ✅ Verified     |
| Runtime bridge   | 🚧 Testing      |
| Widget rendering | ❓ Unverified   |
| Production ready | ❌ Not yet      |

> ⚠️ **Experimental** — Under active development. API may change without notice. Not recommended for production use until v1.0.

## How It Works

Uses Swift runtime type lookup (`_typeByName`) + Codable + existential opening to bridge to WidgetKit's private `_ClockHandRotationEffect` type — avoiding the `@_silgen_name` IRGen compiler crash that occurs with body-less `some View` return types in Swift 6.2+.

See `Sources/ClockHandKit/ClockHandRotationEffect.swift` for the implementation.

## Usage

```swift
import ClockHandKit

struct MyWidgetView: View {
    var body: some View {
        Image(systemName: "arrow.up")
            .clockHandRotationEffect(period: .secondHand)
    }
}
```

## Debugging

Runtime bridge logs are emitted via `OSLog` under subsystem `com.clockhandkit`. Filter in Console.app to see per-step status.

## License

MIT
