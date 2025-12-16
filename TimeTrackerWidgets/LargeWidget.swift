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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Header mit Status
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TimeTracker Pro")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(entry.date.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Indikator
                HStack(spacing: 6) {
                    Circle()
                        .fill(entry.timerData.isTimerRunning ? .green : .gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                    
                    Text(entry.timerData.isTimerRunning ? "LIVE" : "IDLE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(entry.timerData.isTimerRunning ? .green : .secondary)
                        .textCase(.uppercase)
                        .tracking(0.8)
                }
            }
            
            // Hauptbereich - Aktueller Timer
            VStack(spacing: 12) {
                if let activeCategory = entry.timerData.activeCategory, entry.timerData.isTimerRunning {
                    // Aktive Kategorie
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(activeCategory.color)
                            .frame(width: 6, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activeCategory.displayName.uppercased())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .tracking(1.0)
                            
                            Text(formatTimer(entry.timerData.workSeconds))
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(activeCategory.color)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Tagesübersicht
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.blue)
                            .frame(width: 6, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("HEUTIGE ARBEITSZEIT")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .tracking(1.0)
                            
                            Text(formatTime(entry.timerData.todayWorkSeconds))
                                .font(.system(size: 36, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            // Fortschrittsbereich
            VStack(spacing: 8) {
                HStack {
                    Text("TAGESZIEL")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .tracking(0.8)
                    
                    Spacer()
                    
                    Text("\(Int(entry.timerData.workProgress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(entry.timerData.workProgress >= 1.0 ? .green : .blue)
                }
                
                // Moderner Fortschrittsbalken
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.08))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: entry.timerData.workProgress >= 1.0 ?
                                    [Color.green, Color.green.opacity(0.8)] :
                                    [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: (280 * entry.timerData.workProgress), height: 8)
                        .shadow(
                            color: (entry.timerData.workProgress >= 1.0 ? Color.green : Color.blue).opacity(0.4),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                }
                .frame(width: 280)
                
                // Status-Zeile unter Fortschrittsbalken
                HStack {
                    Text("Von \(Int(entry.timerData.targetWorkHours))h Arbeitszeit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if entry.timerData.workProgress >= 1.0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("ZIEL ERREICHT!")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                                .tracking(0.5)
                        }
                    } else {
                        let remaining = (Int(entry.timerData.targetWorkHours) * 3600) - entry.timerData.todayWorkSeconds
                        Text("Noch \(formatTime(max(0, remaining)))")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Moderne Trennlinie
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.primary.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 40)
            
            // Kategorien-Statistik
            VStack(spacing: 12) {
                Text("STATISTIK")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(1.2)
                
                HStack(spacing: 20) {
                    // Arbeit
                    LargeStatColumn(
                        label: "ARBEIT",
                        value: formatTime(entry.timerData.workSeconds),
                        color: .blue,
                        isActive: entry.timerData.activeCategory == .work && entry.timerData.isTimerRunning
                    )
                    
                    // Pause
                    LargeStatColumn(
                        label: "PAUSE",
                        value: formatTime(entry.timerData.coffeeSeconds),
                        color: .orange,
                        isActive: entry.timerData.activeCategory == .coffee && entry.timerData.isTimerRunning
                    )
                    
                    // Mittag
                    LargeStatColumn(
                        label: "MITTAG",
                        value: formatTime(entry.timerData.lunchSeconds),
                        color: .green,
                        isActive: entry.timerData.activeCategory == .lunch && entry.timerData.isTimerRunning
                    )
                }
            }
        }
        .padding(20)
    }
}

// MARK: - Large Stat Column Component (Vereinfacht)

struct LargeStatColumn: View {
    let label: String
    let value: String
    let color: Color
    let isActive: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            // Kategorie-Indikator
            Circle()
                .fill(isActive ? color : color.opacity(0.3))
                .frame(width: 12, height: 12)
                .shadow(
                    color: isActive ? color.opacity(0.5) : Color.clear,
                    radius: isActive ? 3 : 0,
                    x: 0,
                    y: 1
                )
            
            VStack(spacing: 4) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .tracking(0.8)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(isActive ? color : .primary)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(as: .systemLarge) {
    TimeTrackerWidgets()
} timeline: {
    TimerEntry(
        date: Date(),
        timerData: WidgetTimerData(
            workSeconds: 21600,
            coffeeSeconds: 1200,
            lunchSeconds: 3600,
            isTimerRunning: false,
            targetWorkHours: 8,
            todayWorkSeconds: 21600
        )
    )
}
