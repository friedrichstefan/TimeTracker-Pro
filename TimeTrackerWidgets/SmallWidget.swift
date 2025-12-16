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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            // Header mit Status
            HStack {
                Text("TimeTracker Pro")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Status Indikator
                HStack(spacing: 3) {
                    Circle()
                        .fill(entry.timerData.isTimerRunning ? .green : .gray.opacity(0.5))
                        .frame(width: 5, height: 5)
                    
                    Text(entry.timerData.isTimerRunning ? "LIVE" : "IDLE")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundColor(entry.timerData.isTimerRunning ? .green : .secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
            }
            
            // Hauptzeit-Display
            VStack(spacing: 6) {
                if let activeCategory = entry.timerData.activeCategory, entry.timerData.isTimerRunning {
                    // Aktive Kategorie
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(activeCategory.color)
                            .frame(width: 3, height: 20)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text(activeCategory.displayName.uppercased())
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                                .tracking(0.6)
                            
                            Text(formatTimer(entry.timerData.workSeconds))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .minimumScaleFactor(0.8)
                        }
                    }
                } else {
                    // Tagesübersicht
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(.blue)
                            .frame(width: 3, height: 20)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("HEUTE GESAMT")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(.secondary)
                                .tracking(0.6)
                            
                            Text(formatTime(entry.timerData.todayWorkSeconds))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
            }
            
            Spacer(minLength: 4)
            
            // Fortschrittsbalken
            VStack(spacing: 3) {
                HStack {
                    Text("TAGESZIEL")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.secondary)
                        .tracking(0.4)
                    
                    Spacer()
                    
                    Text("\(Int(entry.timerData.workProgress * 100))%")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(entry.timerData.workProgress >= 1.0 ? .green : .blue)
                }
                
                // Fortschrittsbalken
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.08))
                        .frame(height: 4)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: entry.timerData.workProgress >= 1.0 ?
                                    [Color.green, Color.green.opacity(0.8)] :
                                    [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: (120 * entry.timerData.workProgress), height: 4)
                }
                .frame(width: 120)
            }
        }
        .padding(12)
    }
}
