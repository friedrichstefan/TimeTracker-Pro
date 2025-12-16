//
//  SmallWidget.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 16.12.25.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: TimerEntry
    
    var body: some View {
        VStack(spacing: 6) {
            // Status Header
            HStack {
                Text("TimeTracker")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if entry.timerData.isTimerRunning {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                }
            }
            
            // Hauptanzeige
            VStack(spacing: 4) {
                if let activeCategory = entry.timerData.activeCategory, entry.timerData.isTimerRunning {
                    Text(activeCategory.symbol)
                        .font(.title2)
                    
                    Text(formatTimer(entry.timerData.workSeconds))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.8)
                } else {
                    Text("💼")
                        .font(.title2)
                    
                    Text(formatTime(entry.timerData.todayWorkSeconds))
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(.blue)
                        .minimumScaleFactor(0.8)
                }
            }
            
            Spacer(minLength: 2)
            
            // Fortschrittsbalken
            VStack(spacing: 2) {
                ProgressView(value: entry.timerData.workProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 3)
                
                Text("\(Int(entry.timerData.workProgress * 100))%")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .background(.regularMaterial)
    }
}

#Preview {
    SmallWidgetView(entry: TimerEntry(
        date: Date(),
        timerData: WidgetTimerData(
            workSeconds: 14400,
            isTimerRunning: true,
            activeCategory: .work
        )
    ))
    .previewContext(WidgetPreviewContext(family: .systemSmall))
}
