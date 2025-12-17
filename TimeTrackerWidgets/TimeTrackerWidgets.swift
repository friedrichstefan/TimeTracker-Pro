//
//  TimeTrackerWidgets.swift
//  TimeTrackerWidgets
//
//  Created by Friedrich, Stefan on 16.12.25.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct TimerEntry: TimelineEntry {
    let date: Date
    let timerData: WidgetTimerData
}

// MARK: - Widget Provider
struct TimerProvider: TimelineProvider {
    func placeholder(in context: Context) -> TimerEntry {
        TimerEntry(
            date: Date(),
            timerData: WidgetTimerData(
                workSeconds: 25200,
                coffeeSeconds: 900,
                lunchSeconds: 1800,
                isTimerRunning: true,
                activeCategory: .work,
                targetWorkHours: 8,
                todayWorkSeconds: 25200
            )
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TimerEntry) -> ()) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let timerData = WidgetDataManager.shared.loadTimerData()
        let entry = TimerEntry(date: Date(), timerData: timerData)

        let updateInterval: TimeInterval = timerData.isTimerRunning ? 30 : 900
        let nextUpdate = Date().addingTimeInterval(updateInterval)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Main Widget View (KOMPLETT NEU)
struct TimeTrackerWidgetView: View {
    let entry: TimerEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        // Direkte Widget-Views ohne Rendering-Modi-Komplexität
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            case .systemExtraLarge:
                LargeWidgetView(entry: entry)
            @unknown default:
                SmallWidgetView(entry: entry)
            }
        }
        // NEUER Container Background Ansatz
        .containerBackground(for: .widget) {
            Rectangle()
                .fill(.clear)
        }
    }
}

// MARK: - Widget Configuration
struct TimeTrackerWidgets: Widget {
    let kind: String = "TimeTrackerWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerProvider()) { entry in
            TimeTrackerWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Rectangle().fill(.clear)
                }
        }
        .configurationDisplayName("TimeTracker Pro")
        .description("Zeigt deine Timer und Arbeitsfortschritt")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
