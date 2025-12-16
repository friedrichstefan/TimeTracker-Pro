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

// MARK: - Main Widget View
struct TimeTrackerWidgetView: View {
    let entry: TimerEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.widgetRenderingMode) var renderingMode
    
    var body: some View {
        ZStack {
            switch renderingMode {
            case .fullColor:
                fullColorView
            case .accented:
                accentedView
            case .vibrant:
                vibrantView
            default:
                fullColorView
            }
        }
        .containerBackground(for: .widget) {
            // Kein expliziter Hintergrund - System übernimmt
        }
    }
    
    @ViewBuilder
    private var fullColorView: some View {
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
    
    @ViewBuilder
    private var accentedView: some View {
        VStack(spacing: 8) {
            // Hauptinhalt - wird akzentuiert
            VStack(spacing: 6) {
                Text("TimeTracker Pro")
                    .font(.system(size: family == .systemLarge ? 16 : 12, weight: .bold))
                
                if entry.timerData.isTimerRunning, let activeCategory = entry.timerData.activeCategory {
                    Text(activeCategory.displayName)
                        .font(.system(size: family == .systemLarge ? 14 : 10, weight: .medium))
                    
                    Text(formatTimer(entry.timerData.workSeconds))
                        .font(.system(size: family == .systemLarge ? 24 : 16, weight: .bold, design: .monospaced))
                } else {
                    Text("HEUTE")
                        .font(.system(size: family == .systemLarge ? 14 : 10, weight: .medium))
                    
                    Text(formatTime(entry.timerData.todayWorkSeconds))
                        .font(.system(size: family == .systemLarge ? 24 : 16, weight: .bold, design: .monospaced))
                }
            }
            .widgetAccentable()
            
            // Sekundärer Inhalt - wird nicht akzentuiert
            Text("\(Int(entry.timerData.workProgress * 100))% Tagesziel")
                .font(.caption)
        }
    }
    
    @ViewBuilder
    private var vibrantView: some View {
        VStack(spacing: 6) {
            Text("TimeTracker Pro")
                .font(.system(size: family == .systemLarge ? 14 : 10, weight: .semibold))
            
            if entry.timerData.isTimerRunning, let activeCategory = entry.timerData.activeCategory {
                Text(activeCategory.symbol)
                    .font(.system(size: family == .systemLarge ? 20 : 16))
                
                Text(formatTimer(entry.timerData.workSeconds))
                    .font(.system(size: family == .systemLarge ? 20 : 14, weight: .bold, design: .monospaced))
            } else {
                Text("📊")
                    .font(.system(size: family == .systemLarge ? 20 : 16))
                
                Text(formatTime(entry.timerData.todayWorkSeconds))
                    .font(.system(size: family == .systemLarge ? 20 : 14, weight: .bold, design: .monospaced))
            }
            
            Text("\(Int(entry.timerData.workProgress * 100))%")
                .font(.caption)
        }
    }
}

// MARK: - Widget Configuration
struct TimeTrackerWidgets: Widget {
    let kind: String = "TimeTrackerWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TimerProvider()) { entry in
            TimeTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("TimeTracker Pro")
        .description("Zeigt deine Timer und Arbeitsfortschritt")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
