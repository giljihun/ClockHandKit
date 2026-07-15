//
//  OctreeWidget.swift
//  OctreeWidget
//
//  Created by 길지훈 on 2026-07-15.
//

import WidgetKit
import SwiftUI

struct OctreeWidget: Widget {
    let kind = "OctreeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: OctreeProvider()) { _ in
            OctreeWidgetView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Octree")
        .description("Clock hand rotation using octree/ClockHandRotationKit (xcframework)")
        .supportedFamilies([.systemSmall])
    }
}

struct OctreeProvider: TimelineProvider {
    func placeholder(in context: Context) -> OctreeEntry {
        OctreeEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (OctreeEntry) -> Void) {
        completion(OctreeEntry(date: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<OctreeEntry>) -> Void) {
        completion(Timeline(entries: [OctreeEntry(date: .now)], policy: .never))
    }
}

struct OctreeEntry: TimelineEntry {
    let date: Date
}
