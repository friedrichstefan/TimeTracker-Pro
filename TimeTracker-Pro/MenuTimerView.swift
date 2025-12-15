//
//  MenuTimerView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct MenuTimerView: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        VStack(spacing: 0) {
            // Header mit aktueller Zeit - FESTE HÖHE
            VStack(spacing: 4) {
                HStack {
                    if let activeCategory = timeModel.activeCategory, timeModel.isTimerRunning {
                        Text(activeCategory.symbol)
                            .font(.system(size: 13))
                        Text(formatTimerTime(timeModel.getCurrentTimerSeconds()))
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(.primary)
                    } else {
                        Text(formatTimerTime(timeModel.getCurrentTimerSeconds()))
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // STATUS TEXT MIT FESTER HÖHE
                Text(timeModel.isTimerRunning ? "LÄUFT" : "BEREIT")
                    .font(.caption2)
                    .foregroundStyle(timeModel.isTimerRunning ? .blue : .secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .frame(height: 12)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            
            // Kategorie-Buttons mit ANGEPASSTER HÖHE
            HStack(spacing: 8) {
                ForEach(TimerCategory.allCases, id: \.self) { category in
                    CategoryTimerButton(
                        category: category,
                        timeModel: timeModel
                    )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 90)
            
            // Stopp/Reset Bereich
            VStack(spacing: 8) {
                if timeModel.isTimerRunning {
                    Button("Stopp") {
                        timeModel.stopTimer()
                    }
                    .buttonStyle(StoppButtonStyle())
                } else {
                    // Unsichtbarer Platzhalter
                    Text("")
                        .frame(height: 32)
                }
                
                if timeModel.workSeconds > 0 || timeModel.coffeeSeconds > 0 || timeModel.lunchSeconds > 0 {
                    Button("Zurücksetzen") {
                        timeModel.resetAllTimers()
                    }
                    .buttonStyle(MenuResetButtonStyle()) // UMBENANNT
                } else {
                    // Unsichtbarer Platzhalter
                    Text("")
                        .frame(height: 26)
                }
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .frame(width: 360, height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private func formatTimerTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

struct CategoryTimerButton: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    
    private var isActive: Bool {
        timeModel.activeCategory == category && timeModel.isTimerRunning
    }
    
    private var categorySeconds: Int {
        switch category {
        case .work: return timeModel.workSeconds
        case .coffee: return timeModel.coffeeSeconds
        case .lunch: return timeModel.lunchSeconds
        }
    }
    
    var body: some View {
        Button(action: {
            if isActive {
                timeModel.stopTimer()
            } else {
                timeModel.startTimer(for: category)
            }
        }) {
            VStack(spacing: 8) {
                // Symbol
                Text(category.symbol)
                    .font(.system(size: 22))
                
                // Name
                Text(category.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isActive ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Zeit
                Text(formatTime(categorySeconds))
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(isActive ? .white.opacity(0.9) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 74)
        }
        .buttonStyle(CategoryButtonStyle(isActive: isActive, category: category))
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%02d:%02d", minutes, seconds % 60)
        }
    }
    
    private func accentColor() -> Color {
        switch category {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
}

// MARK: - Button Styles

struct CategoryButtonStyle: ButtonStyle {
    let isActive: Bool
    let category: TimerCategory
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColorForState(configuration.isPressed))
                    .shadow(
                        color: shadowColorForState(),
                        radius: isActive ? 4 : 0,
                        x: 0,
                        y: isActive ? 2 : 0
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
    
    private func backgroundColorForState(_ isPressed: Bool) -> Color {
        if isActive {
            return accentColor()
        } else if isPressed {
            return Color.primary.opacity(0.15)
        } else {
            return Color.primary.opacity(0.08)
        }
    }
    
    private func shadowColorForState() -> Color {
        return isActive ? accentColor().opacity(0.4) : Color.clear
    }
    
    private func accentColor() -> Color {
        switch category {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
}

struct StoppButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .frame(height: 32)
            .frame(maxWidth: 220)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.red)
                    .shadow(color: .red.opacity(0.4), radius: 4, x: 0, y: 2)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// UMBENANNT von ResetButtonStyle zu MenuResetButtonStyle
struct MenuResetButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.secondary)
            .frame(height: 26)
            .frame(maxWidth: 220)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.15) : Color.primary.opacity(0.08))
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
