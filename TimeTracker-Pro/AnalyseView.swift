//
//  AnalyseView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI
import Charts
import Foundation  // HINZUGEFÜGT für cos/sin Funktionen

struct AnalyseView: View {
    @ObservedObject var timeModel: TimeModel
    @State private var selectedDate = Date()
    @State private var selectedCategory: TimerCategory = .work
    
    private var appUsages: [AppUsage] {
        timeModel.getAggregatedAppUsagesForDate(selectedDate, category: selectedCategory)
    }
    
    private var totalDuration: Int {
        appUsages.reduce(0) { $0 + $1.duration }
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ModernSectionHeader(
                    title: "App-Analyse",
                    subtitle: "Verwendete Apps während der Timer-Sessions"
                )
                
                // Controls
                HStack(spacing: 16) {
                    // Datum-Navigation
                    HStack(spacing: 12) {
                        Button(action: previousDay) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .buttonStyle(AnalyseDateNavigationButtonStyle())
                        
                        VStack(spacing: 5) {
                            Text(formatSelectedDate())
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if isToday {
                                Text("Heute")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                                    .textCase(.uppercase)
                            }
                        }
                        .frame(minWidth: 100)
                        
                        Button(action: nextDay) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .buttonStyle(AnalyseDateNavigationButtonStyle())
                        .disabled(isToday)
                    }
                    
                    Spacer()
                    
                    // Kategorie-Picker
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(TimerCategory.allCases, id: \.self) { category in
                            HStack {
                                Text(category.symbol)
                                Text(category.displayName)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 140)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    if !timeModel.isAppTrackingEnabled {
                        // App-Tracking aktivieren
                        ModernCard {
                            VStack(spacing: 16) {
                                Image(systemName: "apps.iphone.badge.plus")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                                
                                Text("App-Tracking aktivieren")
                                    .font(.headline)
                                
                                Text("Aktiviere das App-Tracking, um zu sehen, welche Apps du während deiner Arbeitszeit verwendest.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("App-Tracking aktivieren") {
                                    timeModel.isAppTrackingEnabled = true
                                }
                                .buttonStyle(EnableTrackingButtonStyle())
                            }
                            .padding(.vertical, 20)
                        }
                    } else if appUsages.isEmpty {
                        // Keine Daten
                        ModernCard {
                            EmptyAnalysisView(
                                category: selectedCategory,
                                isToday: isToday
                            )
                        }
                    } else {
                        // Chart und Liste - VEREINFACHT ohne Labels
                        VStack(spacing: 32) {
                            // Donut Chart ohne komplexe Labels
                            VStack(spacing: 16) {
                                Text("App-Verteilung")
                                    .font(.headline)
                                
                                SimpleDonutChartView(appUsages: appUsages)
                                    .frame(width: 300, height: 300)
                                
                                VStack(spacing: 4) {
                                    Text("Gesamtzeit")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                    
                                    Text(formatDuration(totalDuration))
                                        .font(.system(.title2, design: .monospaced))
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            // App-Liste
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Detailansicht")
                                    .font(.headline)
                                
                                ModernCard {
                                    LazyVStack(spacing: 0) {
                                        ForEach(Array(appUsages.prefix(10).enumerated()), id: \.element.id) { index, usage in
                                            AppUsageRowView(
                                                usage: usage,
                                                totalDuration: totalDuration,
                                                rank: index + 1
                                            )
                                            
                                            if index < min(appUsages.count - 1, 9) {
                                                Divider()
                                                    .padding(.horizontal, 16)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
    
    private func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
    
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: selectedDate)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

// VEREINFACHTE VERSION ohne komplexe Label-Berechnung
struct SimpleDonutChartView: View {
    let appUsages: [AppUsage]
    
    private var chartData: [(String, Double, Color)] {
        let total = Double(appUsages.reduce(0) { $0 + $1.duration })
        return appUsages.prefix(8).enumerated().map { index, usage in
            let percentage = Double(usage.duration) / total
            let color = colors[index % colors.count]
            return (usage.appName, percentage, color)
        }
    }
    
    private let colors: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan
    ]
    
    var body: some View {
        ZStack {
            // Donut Chart
            Chart(Array(chartData.enumerated()), id: \.offset) { index, data in
                SectorMark(
                    angle: .value("Usage", data.1),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(0.9)
                )
                .foregroundStyle(data.2)
                .opacity(0.8)
            }
            
            // Center Text
            VStack(spacing: 4) {
                Image(systemName: "app.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                
                Text("\(appUsages.count)")
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                
                Text("Apps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
    }
}

struct AppUsageRowView: View {
    let usage: AppUsage
    let totalDuration: Int
    let rank: Int
    
    private var percentage: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(usage.duration) / Double(totalDuration)
    }
    
    private let colors: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan
    ]
    
    var body: some View {
        HStack(spacing: 12) {
            // Rang
            Text("\(rank)")
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            // Farbe
            Circle()
                .fill(colors[(rank - 1) % colors.count])
                .frame(width: 12, height: 12)
            
            // App Info
            VStack(alignment: .leading, spacing: 2) {
                Text(usage.appName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(formatDuration(usage.duration))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Prozent
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(percentage * 100))%")
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.medium)
                
                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.quaternary)
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(colors[(rank - 1) % colors.count])
                            .frame(width: geometry.size.width * percentage, height: 4)
                    }
                }
                .frame(width: 60, height: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

struct EmptyAnalysisView: View {
    let category: TimerCategory
    let isToday: Bool
    
    var body: some View {
    
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("Keine App-Daten verfügbar")
                .font(.headline)
            
            Text(isToday ?
                 "Starte einen \(category.displayName)-Timer, um App-Daten zu sammeln." :
                 "An diesem Tag wurden keine Apps für \(category.displayName) getrackt.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Button Styles

struct EnableTrackingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.blue, in: RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct AnalyseDateNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? .blue : .primary)
            .frame(width: 28, height: 28)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.blue.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
