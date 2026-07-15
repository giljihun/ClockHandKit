//
//  OctreeWidgetView.swift
//  OctreeWidget
//
//  Created by 길지훈 on 2026-07-15.
//

import SwiftUI
import ClockHandRotationEffect

struct OctreeWidgetView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)

            // Clock face
            Circle()
                .stroke(Color.secondary, lineWidth: 2)
                .padding(8)

            // Hour hand — 43200 seconds
            ClockHand(length: 0.28, width: 5, color: .primary)
                .clockHandRotationEffect(period: 43200)

            // Minute hand — 3600 seconds
            ClockHand(length: 0.38, width: 3, color: .primary)
                .clockHandRotationEffect(period: 3600)

            // Second hand — 60 seconds
            ClockHand(length: 0.42, width: 1.5, color: .red)
                .clockHandRotationEffect(period: 60)

            // Center dot
            Circle()
                .fill(Color.primary)
                .frame(width: 6, height: 6)
        }
    }
}

private struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            Capsule()
                .fill(color)
                .frame(width: width, height: size * length)
                .offset(y: -(size * length) / 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
