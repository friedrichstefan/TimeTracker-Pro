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
                    ActiveTimerCard(category: activeCategory, timeModel: timeModel)
                }
                
                // Timer-Kategorien Übersicht
                TimerCategoriesCard(timeModel: timeModel)
                
                // Reset-Bereich
                TimerManagementCard(timeModel: timeModel)
            }
            .padding(24)
        }
    }
}

// MARK: - Active Timer Card

private struct ActiveTimerCard: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ModernCard {
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
                
                Text(timeModel.getCurrentTimerSeconds().formatAsTimerDisplay())
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(category.color)
                
                Text("Gestartet: \(Date().formatTimeOnly())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Timer Categories Card

private struct TimerCategoriesCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Kategorien")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 12) {
                    ForEach(TimerCategory.allCases, id: \.self) { category in
                        TimerCategoryRow(category: category, timeModel: timeModel)
                    }
                }
            }
        }
    }
}

// MARK: - Timer Category Row

private struct TimerCategoryRow: View {
    let category: TimerCategory
    @ObservedObject var timeModel: TimeModel
    @Environment(\.colorScheme) var colorScheme
    
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
                    .fill(category.color)
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
                            .background(category.color, in: Capsule())
                    }
                }
                
                Text(categorySeconds.formatAsTimerDisplay())
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundStyle(isActive ? category.color : .primary)
                
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
                    .buttonStyle(StartButtonStyle(color: category.color))
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
                .fill(isActive ? category.color.opacity(0.1) : Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? category.color.opacity(0.3) : Color.clear, lineWidth: 1)
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

// MARK: - Timer Management Card

private struct TimerManagementCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
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
}

// MARK: - Preview

#Preview {
    TimerDetailView(timeModel: TimeModel())
        .frame(width: 600, height: 800)
}
