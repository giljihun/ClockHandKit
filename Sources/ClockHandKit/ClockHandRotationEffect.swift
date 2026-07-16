//
//  ClockHandRotationEffect.swift
//  ClockHandKit
//
//  Created by 길지훈 on 2026-07-15.
//

import SwiftUI
import Foundation
import OSLog

// Logger visible in Console.app under subsystem "com.clockhandkit"
@available(iOS 16.0, *)
private let clockHandLog = Logger(subsystem: "com.clockhandkit", category: "runtime-bridge")

// MARK: - Period

/// The rotation period for a clock hand effect.
@available(iOS 16.0, *)
public enum ClockHandPeriod {
    case hourHand
    case minuteHand
    case secondHand
    case custom(Double)
}

// MARK: - Codable JSON structures matching WidgetKit._ClockHandRotationEffect

/// Mirrors the default Codable synthesis of `WidgetKit._ClockHandRotationEffect`.
/// The struct layout and CodingKeys must match WidgetKit's private type exactly.
private struct _ClockHandData: Encodable {
    let period: PeriodPayload
    let timeZone: TimeZonePayload
    let anchor: AnchorPayload

    enum PeriodPayload: Encodable {
        case hourHand
        case minuteHand
        case secondHand
        case custom(Double)

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .hourHand:
                try container.encode(EmptyPayload(), forKey: .hourHand)
            case .minuteHand:
                try container.encode(EmptyPayload(), forKey: .minuteHand)
            case .secondHand:
                try container.encode(EmptyPayload(), forKey: .secondHand)
            case .custom(let value):
                var nested = container.nestedContainer(keyedBy: CustomKeys.self, forKey: .custom)
                try nested.encode(value, forKey: ._0)
            }
        }

        enum CodingKeys: String, CodingKey {
            case hourHand, minuteHand, secondHand, custom
        }
        enum CustomKeys: String, CodingKey {
            case _0
        }
    }

    struct EmptyPayload: Encodable {}
    struct TimeZonePayload: Encodable {
        let identifier: String
    }
    struct AnchorPayload: Encodable {
        let x: Double
        let y: Double
    }
}

// MARK: - Runtime bridge to WidgetKit's private modifier

/// Looks up `WidgetKit._ClockHandRotationEffect` at runtime via `_typeByName` and
/// applies it as a modifier using Codable round-tripping + existential opening.
///
/// This avoids the Swift compiler crash that occurs with `@_silgen_name` on a
/// body-less `some View` function (`methodRequiresReifiedVTableEntry` / opaque
/// type descriptor emission bug in Swift 6.2+).
@available(iOS 16.0, *)
private func applyClockHandModifier<V: View>(
    to view: V,
    period: ClockHandPeriod,
    timeZone: TimeZone,
    anchor: UnitPoint
) -> AnyView {
    // Step 1: Look up the private type at runtime by mangled name
    guard let clockHandType = _typeByName("9WidgetKit24_ClockHandRotationEffectV") else {
        clockHandLog.error("[Step 1 FAIL] _typeByName returned nil — mangled name may be wrong or WidgetKit not loaded")
        return AnyView(view)
    }
    clockHandLog.debug("[Step 1 OK] Found type: \(String(describing: clockHandType))")

    // Step 2: The type must be Decodable for JSON-based construction
    guard let decodableType = clockHandType as? any Decodable.Type else {
        clockHandLog.error("[Step 2 FAIL] Type does not conform to Decodable")
        return AnyView(view)
    }
    clockHandLog.debug("[Step 2 OK] Type conforms to Decodable")

    // Step 3: Build the JSON payload matching WidgetKit's Codable format
    let periodPayload: _ClockHandData.PeriodPayload
    switch period {
    case .hourHand:
        periodPayload = .hourHand
    case .minuteHand:
        periodPayload = .minuteHand
    case .secondHand:
        periodPayload = .secondHand
    case .custom(let seconds):
        periodPayload = .custom(seconds)
    }

    let data = _ClockHandData(
        period: periodPayload,
        timeZone: .init(identifier: timeZone.identifier),
        anchor: .init(x: Double(anchor.x), y: Double(anchor.y))
    )

    let jsonData: Data
    do {
        jsonData = try JSONEncoder().encode(data)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            clockHandLog.debug("[Step 3 OK] Encoded JSON: \(jsonString, privacy: .public)")
        }
    } catch {
        clockHandLog.error("[Step 3 FAIL] JSON encoding error: \(error.localizedDescription, privacy: .public)")
        return AnyView(view)
    }

    // Step 4: Decode as the private WidgetKit type (returned as `any Decodable`)
    let decoded: any Decodable
    do {
        decoded = try JSONDecoder().decode(decodableType, from: jsonData)
        clockHandLog.debug("[Step 4 OK] Decoded into _ClockHandRotationEffect")
    } catch {
        clockHandLog.error("[Step 4 FAIL] JSON decode error — Codable format likely mismatched: \(error.localizedDescription, privacy: .public)")
        clockHandLog.error("[Step 4 FAIL] Full error: \(String(describing: error), privacy: .public)")
        return AnyView(view)
    }

    // Step 5: Cast to `any ViewModifier` — succeeds because `_ClockHandRotationEffect: ViewModifier`
    guard let modifier = decoded as? any ViewModifier else {
        clockHandLog.error("[Step 5 FAIL] Decoded value is not a ViewModifier — protocol conformance not found")
        return AnyView(view)
    }
    clockHandLog.debug("[Step 5 OK] Cast to any ViewModifier succeeded")

    // Step 6: Existential opening: unwraps `any ViewModifier` into a concrete M: ViewModifier
    clockHandLog.info("[ALL OK] Applying WidgetKit._ClockHandRotationEffect via runtime bridge")
    return AnyView(_applyModifier(view, modifier: modifier))
}

@available(iOS 16.0, *)
private func _applyModifier<V: View, M: ViewModifier>(_ view: V, modifier: M) -> some View {
    view.modifier(modifier)
}

// MARK: - ViewModifier

/// A `ViewModifier` that applies a clock-hand rotation effect to a widget view.
@available(iOS 16.0, *)
public struct ClockHandRotationEffect: ViewModifier {
    public let period: ClockHandPeriod
    public let timeZone: TimeZone
    public let anchor: UnitPoint

    public init(
        period: ClockHandPeriod,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) {
        self.period = period
        self.timeZone = timeZone
        self.anchor = anchor
    }

    public func body(content: Content) -> some View {
        applyClockHandModifier(to: content, period: period, timeZone: timeZone, anchor: anchor)
    }
}

// MARK: - View Extension

@available(iOS 16.0, *)
public extension View {
    /// Applies a clock-hand rotation animation to a widget view.
    func clockHandRotationEffect(
        period: ClockHandPeriod,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) -> some View {
        applyClockHandModifier(to: self, period: period, timeZone: timeZone, anchor: anchor)
    }

    /// octree/ClockHandRotationKit-compatible API for drop-in migration.
    func clockHandRotationEffect(
        period: TimeInterval,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) -> some View {
        clockHandRotationEffect(period: .custom(period), in: timeZone, anchor: anchor)
    }
}
