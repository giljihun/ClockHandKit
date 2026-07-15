//
//  ClockHandRotationEffect.swift
//  ClockHandKit
//
//  Created by 길지훈 on 2026-07-15.
//

import SwiftUI
import Foundation

// MARK: - Public Period Type

/// 시계 바늘의 회전 주기를 나타내는 열거형.
///
/// `_ClockHandRotationEffect.Period`와 동일한 메모리 레이아웃을 가짐.
/// `custom(Double)` payload 케이스를 포함하므로 8바이트 크기로 인코딩됨.
@available(iOS 16.0, *)
@frozen
public enum ClockHandPeriod: Hashable, Codable, Sendable {
    /// 시침 (12시간 = 43200초)
    case hourHand
    /// 분침 (1시간 = 3600초)
    case minuteHand
    /// 초침 (1분 = 60초)
    case secondHand
    /// 커스텀 주기 (초 단위)
    case custom(Double)
}

// MARK: - Private API Bridge

@available(iOS 16.0, *)
private extension View {
    /// WidgetKit private symbol `_clockHandRotationEffect(period:in:anchor:)` 직접 바인딩.
    ///
    /// - Parameter period: `ClockHandPeriod` — `_ClockHandRotationEffect.Period`와 동일 ABI 레이아웃.
    /// - Parameter timeZone: 위젯이 표시될 타임존.
    /// - Parameter anchor: 회전 중심점. 기본값 `.center`.
    @_silgen_name("$s7SwiftUI4ViewP9WidgetKitE24_clockHandRotationEffect_2in6anchorQrAD06_ClockghI0V6PeriodO_10Foundation8TimeZoneVAA9UnitPointVtF")
    func _clockHandImpl(
        period: ClockHandPeriod,
        in timeZone: TimeZone,
        anchor: UnitPoint
    ) -> some View
}

// MARK: - ViewModifier

/// `clockHandRotationEffect(period:in:anchor:)` 를 `ViewModifier` 형태로 감싼 타입.
///
/// `.modifier(ClockHandRotationEffect(...))` 구문으로도 사용 가능.
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
        content._clockHandImpl(period: period, in: timeZone, anchor: anchor)
    }
}

// MARK: - View Extension (Public API)

@available(iOS 16.0, *)
public extension View {
    /// 위젯 위에서 시계 바늘처럼 회전하는 애니메이션 효과를 적용합니다.
    ///
    /// WidgetKit의 `_clockHandRotationEffect(period:in:anchor:)` private API를 소스 레벨에서 호출합니다.
    /// SPM 소스 배포 방식이므로 xcframework 바이너리 호환성 문제가 없습니다.
    ///
    /// ```swift
    /// Image(systemName: "arrow.up")
    ///     .clockHandRotationEffect(period: .secondHand)
    /// ```
    ///
    /// - Parameter period: 회전 주기 (`.hourHand`, `.minuteHand`, `.secondHand`, `.custom(seconds)`)
    /// - Parameter timeZone: 기준 타임존. 기본값 `.current`
    /// - Parameter anchor: 회전 중심점. 기본값 `.center`
    func clockHandRotationEffect(
        period: ClockHandPeriod,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) -> some View {
        _clockHandImpl(period: period, in: timeZone, anchor: anchor)
    }

    /// octree/ClockHandRotationKit 호환 API.
    ///
    /// 기존 `clockHandRotationEffect(period: TimeInterval)` 코드를 수정 없이 마이그레이션할 수 있습니다.
    ///
    /// ```swift
    /// // 기존 octree 코드 그대로 동작
    /// view.clockHandRotationEffect(period: 60.0)
    /// ```
    ///
    /// - Parameter period: 회전 주기 (초 단위 `TimeInterval`)
    /// - Parameter timeZone: 기준 타임존. 기본값 `.current`
    /// - Parameter anchor: 회전 중심점. 기본값 `.center`
    func clockHandRotationEffect(
        period: TimeInterval,
        in timeZone: TimeZone = .current,
        anchor: UnitPoint = .center
    ) -> some View {
        clockHandRotationEffect(period: .custom(period), in: timeZone, anchor: anchor)
    }
}
