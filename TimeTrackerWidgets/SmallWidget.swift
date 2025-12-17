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
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Status Indikator
                Circle()
                    .fill(entry.timerData.isTimerRunning ? .green : .secondary)
                    .frame(width: 6, height: 6)
            }
            
            // Hauptzeit-Display
            VStack(spacing: 4) {
                if let activeCategory = entry.timerData.activeCategory, entry.timerData.isTimerRunning {
                    // Aktive Kategorie
                    HStack(spacing: 8) {
                        Text(activeCategory.symbol)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activeCategory.displayName.uppercased())
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(formatTimer(entry.timerData.workSeconds))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(activeCategory.color)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Tagesübersicht
                    VStack(spacing: 4) {
                        Text("HEUTE")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(formatTime(entry.timerData.todayWorkSeconds))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Fortschrittsbalken
            VStack(spacing: 4) {
                HStack {
                    Text("\(Int(entry.timerData.workProgress * 100))% Tagesziel")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 3)
                        
                        Rectangle()
                            .fill(entry.timerData.workProgress >= 1.0 ? .green : .blue)
                            .frame(
                                width: geometry.size.width * entry.timerData.workProgress,
                                height: 3
                            )
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 3)
            }
        }
        .padding(12)
    }
}
