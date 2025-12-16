import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: TimerEntry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 20) {
            // Linke Seite - Haupttimer
            VStack(alignment: .leading, spacing: 12) {
                // Header mit Status
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TimeTracker Pro")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(entry.date.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Indikator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(entry.timerData.isTimerRunning ? .green : .gray.opacity(0.5))
                            .frame(width: 6, height: 6)
                        
                        Text(entry.timerData.isTimerRunning ? "LIVE" : "IDLE")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(entry.timerData.isTimerRunning ? .green : .secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                }
                
                // Hauptzeit-Display
                VStack(alignment: .leading, spacing: 4) {
                    if let activeCategory = entry.timerData.activeCategory, entry.timerData.isTimerRunning {
                        // Aktive Kategorie
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(activeCategory.color)
                                .frame(width: 4, height: 24)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(activeCategory.displayName.uppercased())
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .tracking(0.8)
                                
                                Text(formatTimer(entry.timerData.workSeconds))
                                    .font(.system(.title2, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                    } else {
                        // Tagesübersicht
                        HStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.blue)
                                .frame(width: 4, height: 24)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text("HEUTE GESAMT")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .tracking(0.8)
                                
                                Text(formatTime(entry.timerData.todayWorkSeconds))
                                    .font(.system(.title2, design: .monospaced))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // Fortschrittsbalken mit modernem Design
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("TAGESZIEL")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.secondary)
                            .tracking(0.5)
                        
                        Spacer()
                        
                        Text("\(Int(entry.timerData.workProgress * 100))%")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(entry.timerData.workProgress >= 1.0 ? .green : .blue)
                    }
                    
                    // Moderner Fortschrittsbalken
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.primary.opacity(colorScheme == .dark ? 0.1 : 0.08))
                            .frame(height: 6)
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: entry.timerData.workProgress >= 1.0 ?
                                        [Color.green, Color.green.opacity(0.8)] :
                                        [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: (140 * entry.timerData.workProgress), height: 6)
                            .shadow(
                                color: (entry.timerData.workProgress >= 1.0 ? Color.green : Color.blue).opacity(0.3),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                    }
                    .frame(width: 140)
                    
                    // Verbleibende Zeit UNTER dem Fortschrittsbalken (wenn nicht 100% erreicht)
                    if entry.timerData.workProgress < 1.0 {
                        let remaining = (Int(entry.timerData.targetWorkHours) * 3600) - entry.timerData.todayWorkSeconds
                        HStack {
                            Text("VERBLEIBEND:")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.secondary)
                                .tracking(0.5)
                            
                            Spacer()
                            
                            Text(formatTime(max(0, remaining)))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            // Moderne Trennlinie
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.primary.opacity(0.1),
                            Color.primary.opacity(0.3),
                            Color.primary.opacity(0.1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1)
            
            // Rechte Seite - Kategorien-Stats (zentriert)
            VStack(spacing: 0) {
                // Spacer für zentrierte Positionierung
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("STATISTIK")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                        .tracking(1.0)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        // Arbeit
                        StatRow(
                            label: "Arbeit",
                            value: formatTime(entry.timerData.workSeconds),
                            color: .blue,
                            isActive: entry.timerData.activeCategory == .work && entry.timerData.isTimerRunning
                        )
                        
                        // Pause
                        StatRow(
                            label: "Pause",
                            value: formatTime(entry.timerData.coffeeSeconds),
                            color: .orange,
                            isActive: entry.timerData.activeCategory == .coffee && entry.timerData.isTimerRunning
                        )
                        
                        // Mittag
                        StatRow(
                            label: "Mittag",
                            value: formatTime(entry.timerData.lunchSeconds),
                            color: .green,
                            isActive: entry.timerData.activeCategory == .lunch && entry.timerData.isTimerRunning
                        )
                    }
                }
                
                // Spacer für zentrierte Positionierung
                Spacer()
            }
        }
        .padding(16)
    }
}

// MARK: - Stat Row Component (Vereinfacht)

struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    let isActive: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            // Kategorie-Indikator
            Circle()
                .fill(isActive ? color : color.opacity(0.3))
                .frame(width: 8, height: 8)
                .shadow(
                    color: isActive ? color.opacity(0.4) : Color.clear,
                    radius: isActive ? 2 : 0,
                    x: 0,
                    y: 0
                )
            
            VStack(alignment: .trailing, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
                    .tracking(0.3)
                
                Text(value)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(isActive ? color : .primary)
            }
        }
    }
}

#Preview(as: .systemMedium) {
    TimeTrackerWidgets()
} timeline: {
    TimerEntry(
        date: Date(),
        timerData: WidgetTimerData(
            workSeconds: 14400,
            coffeeSeconds: 600,
            lunchSeconds: 1800,
            isTimerRunning: true,
            activeCategory: .work
        )
    )
}
