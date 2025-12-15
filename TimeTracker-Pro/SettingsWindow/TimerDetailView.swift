//
//  TimerDetailView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct TimerDetailView: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                ModernSectionHeader(
                    title: "Timer-Übersicht",
                    subtitle: "Detaillierte Ansicht aller Timer-Kategorien"
                )
                
                // Aktiver Timer (falls läuft)
                if timeModel.isTimerRunning, let activeCategory = timeModel.activeCategory {
                    ModernCard {
                        ActiveTimerCardContent(category: activeCategory, timeModel: timeModel)
                    }
                }
                
                // Timer-Kategorien Übersicht
                ModernCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Kategorien")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                            ForEach(TimerCategory.allCases, id: \.self) { category in
                                TimerCategoryCard(category: category, timeModel: timeModel)
                            }
                        }
                    }
                }
                
                // Reset-Bereich
                ModernCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Timer-Verwaltung")
                            .font(.headline)
                        
                        HStack {
                            Button("Alle Timer zurücksetzen") {
                                timeModel.resetAllTimers()
                            }
                            .buttonStyle(DangerButtonStyle())
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

// Rename the existing ActiveTimerCard content to avoid conflicts
struct ActiveTimerCardContent: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        // ... existing ActiveTimerCard content without the card wrapper
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Aktiv")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green, in: Capsule())
                
                Spacer()
                
                Text(category.symbol)
                    .font(.title2)
            }
            
            Text(category.displayName)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(formatDetailedTime(timeModel.getCurrentTimerSeconds()))
                .font(.system(.title, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(colorForCategory(category))
        }
    }
    
    private func colorForCategory(_ category: TimerCategory) -> Color {
        switch category {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
}

struct ActiveTimerCard: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Aktiv")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green, in: Capsule())
                
                Spacer()
                
                Text(category.symbol)
                    .font(.title2)
            }
            
            Text(category.displayName)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(formatDetailedTime(timeModel.getCurrentTimerSeconds()))
                .font(.system(.title, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(colorForCategory(category))
            
            Text("Gestartet: \(formatStartTime())")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorForCategory(category).opacity(0.3), lineWidth: 1)
        )
    }
    
    private func formatStartTime() -> String {
        // Vereinfacht - könnte erweitert werden um tatsächliche Startzeit zu speichern
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }
    
    private func colorForCategory(_ category: TimerCategory) -> Color {
        switch category {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
}

struct TimerCategoryCard: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    
    private var categorySeconds: Int {
        switch category {
        case .work: return timeModel.workSeconds
        case .coffee: return timeModel.coffeeSeconds
        case .lunch: return timeModel.lunchSeconds
        }
    }
    
    private var isActive: Bool {
        timeModel.activeCategory == category && timeModel.isTimerRunning
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Symbol und Farbe
            VStack {
                Text(category.symbol)
                    .font(.title2)
                
                Circle()
                    .fill(colorForCategory(category))
                    .frame(width: 8, height: 8)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.displayName)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    if isActive {
                        Text("AKTIV")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(colorForCategory(category), in: Capsule())
                    }
                }
                
                Text(formatDetailedTime(categorySeconds))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(isActive ? colorForCategory(category) : .primary)
                
                if categorySeconds > 0 {
                    Text(formatProductivityInfo(categorySeconds))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Aktionen
            VStack(spacing: 8) {
                if isActive {
                    Button("Stopp") {
                        timeModel.stopTimer()
                    }
                    .buttonStyle(StopButtonStyle())
                } else {
                    Button("Start") {
                        timeModel.startTimer(for: category)
                    }
                    .buttonStyle(StartButtonStyle(color: colorForCategory(category)))
                }
                
                if categorySeconds > 0 {
                    Button("Reset") {
                        resetCategory()
                    }
                    .buttonStyle(ResetButtonStyle())
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isActive ? colorForCategory(category).opacity(0.1) : Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? colorForCategory(category).opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    private func resetCategory() {
        switch category {
        case .work:
            timeModel.workSeconds = 0
            UserDefaults.standard.set(0, forKey: "TimeTracker_WorkSeconds")
        case .coffee:
            timeModel.coffeeSeconds = 0
            UserDefaults.standard.set(0, forKey: "TimeTracker_CoffeeSeconds")
        case .lunch:
            timeModel.lunchSeconds = 0
            UserDefaults.standard.set(0, forKey: "TimeTracker_LunchSeconds")
        }
    }
    
    private func colorForCategory(_ category: TimerCategory) -> Color {
        switch category {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
    
    private func formatProductivityInfo(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        switch category {
        case .work:
            if hours > 0 {
                return "Produktive Zeit: \(hours)h \(minutes)m"
            } else {
                return "Produktive Zeit: \(minutes) Minuten"
            }
        case .coffee:
            return "Pausenzeit heute"
        case .lunch:
            return "Mittagspause heute"
        }
    }
}

// Hilfsfunktion für detaillierte Zeitformatierung
private func formatDetailedTime(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    
    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, secs)
    } else {
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// MARK: - Button Styles

struct StartButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 60, height: 28)
            .background(color, in: RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct StopButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .frame(width: 60, height: 28)
            .background(.red, in: RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ResetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .regular))
            .foregroundStyle(.secondary)
            .frame(width: 60, height: 24)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.1) : Color.clear)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.red)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.red.opacity(0.1) : Color.clear)
                    .stroke(Color.red.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
