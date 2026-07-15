//
//  Bridge.swift
//  ClockHandBridge
//
//  Created by 길지훈 on 2026-07-15.
//

import SwiftUI
import Foundation

// MARK: - Period

/// The rotation period for a clock hand effect.
///
/// Memory layout is identical to `_ClockHandRotationEffect.Period` in WidgetKit.
/// Encoded as 8 bytes using Double extra-inhabitant trick for no-payload cases.
@available(iOS 16.0, *)
@frozen
public enum ClockHandPeriod: Hashable, Codable, Sendable {
    /// Hour hand — full rotation every 12 hours (43200 seconds).
    case hourHand
    /// Minute hand — full rotation every 60 minutes (3600 seconds).
    case minuteHand
    /// Second hand — full rotation every 60 seconds.
    case secondHand
    /// Custom rotation period, specified in seconds.
    case custom(Double)
}

// MARK: - Bridge

// Isolated in its own module so the caller (ClockHandKit) sees this as an
// external symbol — avoiding the methodRequiresReifiedVTableEntry IRGen crash
// that occurs when the declaration and call site share the same compilation unit.
@available(iOS 16.0, *)
@_silgen_name("$s7SwiftUI4ViewP9WidgetKitE24_clockHandRotationEffect_2in6anchorQrAD06_ClockghI0V6PeriodO_10Foundation8TimeZoneVAA9UnitPointVtF")
public func _clockHandRotationEffectBridge<V: View>(
    _ view: V,
    period: ClockHandPeriod,
    in timeZone: TimeZone,
    anchor: UnitPoint
) -> some View
