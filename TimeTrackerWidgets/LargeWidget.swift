//
//  LargeWidget.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 16.12.25.
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text("TimeTracker Pro")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if entry.timerData.isTimerRunning {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                }
            }
            
            // Hauptbereich
            VStack(spacing: 10) {
                if let activeCategory = entry.timerData.activeCategory, entry.timerData.isTimerRunning {
                    // Aktiver Timer
                    VStack(spacing: 6) {
                        Text(activeCategory.symbol)
                            .font(.system(size: 28))
                        
                        Text(activeCategory.displayName)
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text(formatTimer(entry.timerData.workSeconds))
                            .font(.system(.largeTitle, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(activeCategory.color)
                    }
                } else {
                    // Übersicht
                    VStack(spacing: 6) {
                        Text("💼")
                            .font(.system(size: 28))
                        
                        Text("Heutige Arbeitszeit")
                            .font(.title3)
                            .fontWeight(.medium)
                        
                        Text(formatTime(entry.timerData.todayWorkSeconds))
                            .font(.system(.largeTitle, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Fortschrittsbereich
            VStack(spacing: 6) {
                ProgressView(value: entry.timerData.workProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 6)
                
                HStack {
                    Text("Tagesziel")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(entry.timerData.workProgress * 100))% von \(entry.timerData.targetWorkHours)h")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                if entry.timerData.workProgress < 1.0 {
                    let remaining = (entry.timerData.targetWorkHours * 3600) - entry.timerData.todayWorkSeconds
                    HStack {
                        Text("Verbleibend")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(formatTime(max(0, remaining)))
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Divider()
            
            // Kategorien-Übersicht
            HStack {
                ForEach([
                    ("💼", "Arbeit", entry.timerData.workSeconds),
                    ("☕️", "Kaffee", entry.timerData.coffeeSeconds),
                    ("🍽️", "Mittag", entry.timerData.lunchSeconds)
                ], id: \.1) { emoji, name, seconds in
                    VStack(spacing: 3) {
                        Text(emoji)
                            .font(.title2)
                        Text(name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formatTime(seconds))
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}

#Preview {
    LargeWidgetView(entry: TimerEntry(
        date: Date(),
        timerData: WidgetTimerData(
            workSeconds: 21600,
            coffeeSeconds: 1200,
            lunchSeconds: 3600,
            isTimerRunning: false,
            targetWorkHours: 8,
            todayWorkSeconds: 21600
        )
    ))
    .previewContext(WidgetPreviewContext(family: .systemLarge))
}
