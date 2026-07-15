//
//  ClockHandRotationEffect.swift
//  ClockHandKit
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

// MARK: - Private API Bridge

// Declared as a free generic function (not a protocol extension method) to avoid
// swift::irgen::methodRequiresReifiedVTableEntry crashing on body-less some View declarations.
// Calling convention is identical to the protocol extension method ABI: self (view) is the
// first explicit parameter, followed by value parameters, then implicit metatype + witness table.
@available(iOS 16.0, *)
@_silgen_name("$s7SwiftUI4ViewP9WidgetKitE24_clockHandRotationEffect_2in6anchorQrAD06_ClockghI0V6PeriodO_10Foundation8TimeZoneVAA9UnitPointVtF")
private func _clockHandImpl<V: View>(
    _ view: V,
    period: ClockHandPeriod,
    in timeZone: TimeZone,
    anchor: UnitPoint
) -> some View

// MARK: - ViewModifier

/// A `ViewModifier` that applies a clock-hand rotation effect to a widget view.
///
/// Can be used with `.modifier(ClockHandRotationEffect(...))` syntax.
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
        _clockHandImpl(content, period: period, in: timeZone, anchor: anchor)
    }
}

// MARK: - View Extension

@available(iOS 16.0, *)
public extension View {
    /// Applies a clock-hand rotation animation to a widget view.
    ///
    /// Calls WidgetKit's private `_clockHandRotationEffect(period:in:anchor:)` at the source level,
    /// so there are no binary compatibility issues unlike xcframework-based distributions.
    ///
    /// ```swift
    /// Image(systemName: "arrow.up")
    ///     .clockHandRotationEffect(period: .secondHand)
    /// ```
    ///
    /// - Parameters:
    ///   - period: The rotation period (`.hourHand`, `.minuteHand`, `.secondHand`, or `.custom(seconds)`).
    ///   - timeZone: The time zone used to calculate the current angle. Defaults to `.current`.
    ///   - anchor: The rotation anchor point. Defaults to `.center`.
    func clockHandRotationEffect(
        period: ClockHandPeriod,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) -> some View {
        _clockHandImpl(self, period: period, in: timeZone, anchor: anchor)
    }

    /// octree/ClockHandRotationKit-compatible API for drop-in migration.
    ///
    /// Existing code using `clockHandRotationEffect(period: TimeInterval)` works without modification —
    /// just replace the import.
    ///
    /// ```swift
    /// // Works as-is after switching to ClockHandKit
    /// view.clockHandRotationEffect(period: 60.0)
    /// ```
    ///
    /// - Parameters:
    ///   - period: The rotation period in seconds.
    ///   - timeZone: The time zone used to calculate the current angle. Defaults to `.current`.
    ///   - anchor: The rotation anchor point. Defaults to `.center`.
    func clockHandRotationEffect(
        period: TimeInterval,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) -> some View {
        clockHandRotationEffect(period: .custom(period), in: timeZone, anchor: anchor)
    }
}
