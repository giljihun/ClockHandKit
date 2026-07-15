//
//  ClockHandWidget.swift
//  ClockHandWidget
//
//  Created by 길지훈 on 2026-07-15.
//

import WidgetKit
import SwiftUI

struct ClockHandWidget: Widget {
    let kind = "ClockHandWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockHandProvider()) { _ in
            ClockHandWidgetView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("ClockHandKit")
        .description("Clock hand rotation using ClockHandKit (SPM source)")
        .supportedFamilies([.systemSmall])
    }
}

struct ClockHandProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockHandEntry {
        ClockHandEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockHandEntry) -> Void) {
        completion(ClockHandEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockHandEntry>) -> Void) {
        completion(Timeline(entries: [ClockHandEntry(date: .now)], policy: .never))
    }
}

struct ClockHandEntry: TimelineEntry {
    let date: Date
}
