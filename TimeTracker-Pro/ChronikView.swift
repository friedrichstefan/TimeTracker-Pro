//
//  ChronikView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct ChronikView: View {
    @ObservedObject var timeModel: TimeModel
    @State private var selectedDate = Date()
    
    private var sessionsForSelectedDate: [TimerSession] {
        timeModel.getSessionsForDate(selectedDate)
    }
    
    private var totalTimeForDate: Int {
        timeModel.getTotalTimeForDate(selectedDate)
    }
    
    private var workTimeForDate: Int {
        timeModel.getWorkTimeForDate(selectedDate)
    }
    
    private var breakTimeForDate: Int {
        timeModel.getBreakTimeForDate(selectedDate)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header mit Datum-Navigation
            VStack(spacing: 16) {
                ModernSectionHeader(
                    title: "Tagesverlauf",
                    subtitle: "Chronik deiner Timer-Aktivitäten"
                )
                
                // Datum-Auswahl
                HStack(spacing: 16) {
                    Button(action: previousDay) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(DateNavigationButtonStyle())
                    
                    VStack(spacing: 4) {
                        Text(formatSelectedDate())
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if isToday {
                            Text("Heute")
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        } else {
                            Text(formatWeekday())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minWidth: 120)
                    
                    Button(action: nextDay) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .buttonStyle(DateNavigationButtonStyle())
                    .disabled(Calendar.current.isDateInToday(selectedDate))
                    
                    Spacer()
                    
                    if !isToday {
                        Button("Heute") {
                            selectedDate = Date()
                        }
                        .buttonStyle(TodayButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Statistik-Karten
                    HStack(spacing: 16) {
                        StatisticCard(
                            title: "Gesamtzeit",
                            value: formatTime(totalTimeForDate),
                            color: .primary,
                            icon: "clock"
                        )
                        
                        StatisticCard(
                            title: "Arbeitszeit",
                            value: formatTime(workTimeForDate),
                            color: .blue,
                            icon: "briefcase"
                        )
                        
                        StatisticCard(
                            title: "Pausenzeit",
                            value: formatTime(breakTimeForDate),
                            color: .orange,
                            icon: "cup.and.saucer"
                        )
                    }
                    
                    // Timeline
                    ModernCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Aktivitäten")
                                    .font(.headline)
                                
                                Text("(\(sessionsForSelectedDate.count))")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                if !sessionsForSelectedDate.isEmpty {
                                    Button("Tag löschen") {
                                        timeModel.clearSessionsForDate(selectedDate)
                                    }
                                    .buttonStyle(ClearButtonStyle())
                                }
                            }
                            
                            if sessionsForSelectedDate.isEmpty {
                                EmptyDayView(date: selectedDate, isToday: isToday)
                            } else {
                                TimelineView(sessions: sessionsForSelectedDate)
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
    
    private func formatWeekday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return "0m"
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            
            Text(value)
                .font(.system(.title3, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }
}

struct TimelineView: View {
    let sessions: [TimerSession]
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                TimelineRowView(
                    session: session,
                    isLast: index == sessions.count - 1
                )
            }
        }
    }
}

struct TimelineRowView: View {
    let session: TimerSession
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline-Punkt und Linie
            VStack(spacing: 0) {
                Circle()
                    .fill(colorForCategory(session.category))
                    .frame(width: 12, height: 12)
                
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 2, height: 60)
                }
            }
            .frame(width: 12)
            
            // Session-Details
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text(session.category.symbol)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.category.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack(spacing: 6) {
                            Text(formatTimeOnly(session.startTime))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("→")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let endTime = session.endTime {
                                Text(formatTimeOnly(endTime))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("läuft...")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Dauer
                    Text(formatDuration(session.duration))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(colorForCategory(session.category), in: Capsule())
                }
                
                Divider()
                    .opacity(isLast ? 0 : 1)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func colorForCategory(_ category: TimerCategory) -> Color {
        switch category {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
    
    private func formatTimeOnly(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return "< 1m"
        }
    }
}

struct EmptyDayView: View {
    let date: Date
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isToday ? "clock.badge.questionmark" : "calendar.badge.minus")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(isToday ? "Noch keine Aktivitäten heute" : "Keine Aktivitäten an diesem Tag")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text(isToday ? "Starte einen Timer, um deinen Tagesverlauf zu verfolgen." : "An diesem Tag wurden keine Timer gestartet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// Button Styles
struct DateNavigationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? .blue : .primary)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.blue.opacity(0.1) : Color.primary.opacity(0.05))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TodayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.1) : Color.clear)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct ClearButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.red)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(configuration.isPressed ? Color.red.opacity(0.1) : Color.clear)
                    .stroke(Color.red.opacity(0.3), lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
