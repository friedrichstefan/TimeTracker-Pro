//
//  MenuTimerView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct MenuTimerView: View {
    @ObservedObject var timeModel: TimeModel
    @Environment(\.colorScheme) var colorScheme
    
    private var todayWorkTime: Int {
        timeModel.getWorkTimeForDate(Date())
    }
    
    private var targetWorkTime: Int {
        timeModel.targetWorkHours * 3600
    }
    
    private var workProgress: Double {
        guard targetWorkTime > 0 else { return 0 }
        return min(1.0, Double(todayWorkTime) / Double(targetWorkTime))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header mit aktueller Zeit
            VStack(spacing: 4) {
                HStack {
                    if let activeCategory = timeModel.activeCategory, timeModel.isTimerRunning {
                        Text(activeCategory.symbol)
                            .font(.system(size: 13))
                        Text(timeModel.getCurrentTimerSeconds().formatAsTimerDisplay()) // ✅ Extension verwenden
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(.primary)
                    } else {
                        Text(timeModel.getCurrentTimerSeconds().formatAsTimerDisplay()) // ✅ Extension verwenden
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(timeModel.isTimerRunning ? "timer.running".localized : "timer.ready".localized)
                    .font(.caption2)
                    .foregroundStyle(timeModel.isTimerRunning ? .blue : .secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                    .frame(height: 12)
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            
            // Arbeitszeit-Fortschritt - NUR WENN AKTIVIERT
            if timeModel.workTimeMonitoringEnabled {
                VStack(spacing: 8) {
                    HStack {
                        Text("timeline.today".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(todayWorkTime.formatAsTime()) / \(targetWorkTime.formatAsTime())") // ✅ Extension verwenden
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                    }
                    
                    // Fortschrittsbalken
                    ProgressView(value: workProgress)
                        .progressViewStyle(WorkProgressStyle())
                        .frame(height: 6)
                    
                    HStack {
                        Text("\(Int(workProgress * 100))% erreicht")
                            .font(.caption2)
                            .foregroundStyle(workProgress >= 1.0 ? .green : .secondary)
                        
                        Spacer()
                        
                        if workProgress >= 1.0 {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption2)
                                Text("Ziel erreicht!")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                            }
                        } else {
                            let remaining = targetWorkTime - todayWorkTime
                            Text("noch \(remaining.formatAsTime())") // ✅ Extension verwenden
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 16)
            }
            
            // Kategorie-Buttons
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
                    Button("timer.stop".localized) {
                        timeModel.stopTimer()
                    }
                    .buttonStyle(StoppButtonStyle())
                } else {
                    Text("")
                        .frame(height: 32)
                }
                
                if timeModel.workSeconds > 0 || timeModel.coffeeSeconds > 0 || timeModel.lunchSeconds > 0 {
                    Button("Zurücksetzen") {
                        timeModel.resetAllTimers()
                    }
                    .buttonStyle(MenuResetButtonStyle())
                } else {
                    Text("")
                        .frame(height: 26)
                }
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .frame(width: 360, height: timeModel.workTimeMonitoringEnabled ? 280 : 210) // Dynamische Höhe
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 20, x: 0, y: 8)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.1 : 0.05), radius: 1, x: 0, y: 1)
    }
}

struct WorkProgressStyle: ProgressViewStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.quaternary)
                    .frame(height: 6)
                
                Rectangle()
                    .fill(progressColor(for: configuration.fractionCompleted ?? 0))
                    .frame(
                        width: geometry.size.width * CGFloat(configuration.fractionCompleted ?? 0),
                        height: 6
                    )
                    .shadow(
                        color: progressColor(for: configuration.fractionCompleted ?? 0).opacity(colorScheme == .dark ? 0.6 : 0.3),
                        radius: colorScheme == .dark ? 2 : 1,
                        x: 0,
                        y: 1
                    )
                    .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)
            }
        }
        .clipShape(Capsule())
    }
    
    private func progressColor(for progress: Double) -> Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.75 {
            return .blue
        } else if progress >= 0.5 {
            return .orange
        } else {
            return .red
        }
    }
}

struct CategoryTimerButton: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    @Environment(\.colorScheme) var colorScheme
    
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
                Text(categorySeconds.formatAsTime()) // ✅ Extension verwenden
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundStyle(isActive ? .white.opacity(0.9) : .secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 74)
        }
        .buttonStyle(CategoryButtonStyle(isActive: isActive, category: category))
    }
}

// MARK: - Button Styles

struct CategoryButtonStyle: ButtonStyle {
    let isActive: Bool
    let category: TimerCategory
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColorForState(configuration.isPressed))
                    .shadow(
                        color: shadowColorForState(),
                        radius: isActive ? (colorScheme == .dark ? 6 : 4) : 0,
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
            return category.color // ✅ Extension aus Models.swift verwenden
        } else if isPressed {
            return Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.15)
        } else {
            return Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.08)
        }
    }
    
    private func shadowColorForState() -> Color {
        return isActive ? category.color.opacity(colorScheme == .dark ? 0.6 : 0.4) : Color.clear // ✅ Extension verwenden
    }
}

struct StoppButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .frame(height: 32)
            .frame(maxWidth: 220)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.red)
                    .shadow(color: .red.opacity(colorScheme == .dark ? 0.6 : 0.4), radius: colorScheme == .dark ? 6 : 4, x: 0, y: 2)
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MenuResetButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.secondary)
            .frame(height: 26)
            .frame(maxWidth: 220)
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color.primary.opacity(colorScheme == .dark ? 0.2 : 0.15) : Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.08))
                    .shadow(
                        color: .black.opacity(colorScheme == .dark ? 0.2 : 0.05),
                        radius: colorScheme == .dark ? 2 : 1,
                        x: 0,
                        y: 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
