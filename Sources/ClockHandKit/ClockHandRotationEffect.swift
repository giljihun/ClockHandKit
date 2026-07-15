//
//  ClockHandRotationEffect.swift
//  ClockHandKit
//
//  Created by 길지훈 on 2026-07-15.
//

import SwiftUI
import Foundation
@_exported import ClockHandBridge

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
        _clockHandRotationEffectBridge(content, period: period, in: timeZone, anchor: anchor)
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
        _clockHandRotationEffectBridge(self, period: period, in: timeZone, anchor: anchor)
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
