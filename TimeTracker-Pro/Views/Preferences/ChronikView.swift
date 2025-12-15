import SwiftUI

struct ChronikView: View {
    @ObservedObject var timeModel: TimeModel
    @State private var selectedDate = Date()
    @Environment(\.colorScheme) var colorScheme
    
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
            VStack(spacing: 20) {
                ModernSectionHeader(
                    title: "Tagesverlauf",
                    subtitle: "Chronik deiner Timer-Aktivitäten"
                )
                
                DateNavigationHeader(
                    selectedDate: $selectedDate,
                    isToday: isToday
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Arbeitszeit-Zusammenfassung
                    WorkTimeSummaryCard(
                        todayWorkTime: workTimeForDate,
                        targetWorkTime: timeModel.targetWorkHours * 3600,
                        isToday: isToday
                    )
                    
                    // Statistik-Karten
                    StatisticCardsRow(
                        totalTime: totalTimeForDate,
                        workTime: workTimeForDate,
                        breakTime: breakTimeForDate
                    )
                    
                    // Timeline
                    TimelineCard(
                        sessions: sessionsForSelectedDate,
                        selectedDate: selectedDate,
                        isToday: isToday,
                        onClearDay: {
                            timeModel.clearSessionsForDate(selectedDate)
                        }
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Date Navigation Header

private struct DateNavigationHeader: View {
    @Binding var selectedDate: Date
    let isToday: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            Button(action: previousDay) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(DateNavigationButtonStyle())
            
            VStack(spacing: 6) {
                Text(selectedDate.formatSelectedDate())
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if isToday {
                    Text("Heute")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .textCase(.uppercase)
                        .tracking(0.5)
                } else {
                    Text(selectedDate.formatWeekday())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 140)
            
            Button(action: nextDay) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
            }
            .buttonStyle(DateNavigationButtonStyle())
            .disabled(Calendar.current.isDateInToday(selectedDate))
            
            Spacer()
            
            // Heute-Button
            if !isToday {
                Button("Heute") {
                    selectedDate = Date()
                }
                .buttonStyle(TodayButtonStyle())
            }
        }
    }
    
    private func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
}

// MARK: - Work Time Summary Card

private struct WorkTimeSummaryCard: View {
    let todayWorkTime: Int
    let targetWorkTime: Int
    let isToday: Bool
    @Environment(\.colorScheme) var colorScheme
    
    private var progress: Double {
        guard targetWorkTime > 0 else { return 0 }
        return min(1.0, Double(todayWorkTime) / Double(targetWorkTime))
    }
    
    private var remainingTime: Int {
        return max(0, targetWorkTime - todayWorkTime)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isToday ? "Heutiger Fortschritt" : "Tagesfortschritt")
                        .font(.headline)
                    
                    Text("Arbeitszeit-Ziel: \(targetWorkTime.formatAsTime())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            progressColor(),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 60)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(progressColor())
                }
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Gearbeitet:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(todayWorkTime.formatAsTime())
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.semibold)
                }
                
                if remainingTime > 0 && isToday {
                    HStack {
                        Text("Verbleibend:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(remainingTime.formatAsTime())
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                } else if progress >= 1.0 {
                    HStack {
                        Text("Status:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline)
                            Text("Ziel erreicht!")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(progressColor().opacity(0.3), lineWidth: 1)
        )
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
            radius: colorScheme == .dark ? 8 : 4,
            x: 0,
            y: 2
        )
    }
    
    private func progressColor() -> Color {
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

// MARK: - Statistic Cards Row

private struct StatisticCardsRow: View {
    let totalTime: Int
    let workTime: Int
    let breakTime: Int
    
    var body: some View {
        HStack(spacing: 20) {
            StatisticCard(
                title: "Gesamtzeit",
                value: totalTime.formatAsTime(),
                color: .primary,
                icon: "clock"
            )
            
            StatisticCard(
                title: "Arbeitszeit",
                value: workTime.formatAsTime(),
                color: .blue,
                icon: "briefcase"
            )
            
            StatisticCard(
                title: "Pausenzeit",
                value: breakTime.formatAsTime(),
                color: .orange,
                icon: "cup.and.saucer"
            )
        }
    }
}

// MARK: - Statistic Card

private struct StatisticCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    @Environment(\.colorScheme) var colorScheme
    
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
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.2 : 0.05),
            radius: colorScheme == .dark ? 4 : 2,
            x: 0,
            y: 1
        )
    }
}

// MARK: - Timeline Card

private struct TimelineCard: View {
    let sessions: [TimerSession]
    let selectedDate: Date
    let isToday: Bool
    let onClearDay: () -> Void
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Aktivitäten")
                        .font(.headline)
                    
                    Text("(\(sessions.count))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if !sessions.isEmpty {
                        Button("Tag löschen") {
                            onClearDay()
                        }
                        .buttonStyle(ClearButtonStyle())
                    }
                }
                
                if sessions.isEmpty {
                    EmptyDayView(date: selectedDate, isToday: isToday)
                } else {
                    TimelineView(sessions: sessions)
                }
            }
        }
    }
}

// MARK: - Timeline View

private struct TimelineView: View {
    let sessions: [TimerSession]
    @Environment(\.colorScheme) var colorScheme
    
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

// MARK: - Timeline Row View

private struct TimelineRowView: View {
    let session: TimerSession
    let isLast: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Timeline-Punkt und Linie
            VStack(spacing: 0) {
                Circle()
                    .fill(session.category.color)
                    .frame(width: 12, height: 12)
                    .shadow(
                        color: session.category.color.opacity(colorScheme == .dark ? 0.6 : 0.3),
                        radius: colorScheme == .dark ? 3 : 2,
                        x: 0,
                        y: 1
                    )
                
                if !isLast {
                    Rectangle()
                        .fill(Color.secondary.opacity(colorScheme == .dark ? 0.3 : 0.2))
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
                            Text(session.startTime.formatTimeOnly())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text("→")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if let endTime = session.endTime {
                                Text(endTime.formatTimeOnly())
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
                    Text(session.duration.formatAsDuration())
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(session.category.color, in: Capsule())
                        .shadow(
                            color: session.category.color.opacity(colorScheme == .dark ? 0.5 : 0.3),
                            radius: colorScheme == .dark ? 2 : 1,
                            x: 0,
                            y: 1
                        )
                }
                
                Divider()
                    .opacity(isLast ? 0 : 1)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Empty Day View

private struct EmptyDayView: View {
    let date: Date
    let isToday: Bool
    @Environment(\.colorScheme) var colorScheme
    
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

// MARK: - Preview

#Preview {
    ChronikView(timeModel: TimeModel())
        .frame(width: 800, height: 600)
}
