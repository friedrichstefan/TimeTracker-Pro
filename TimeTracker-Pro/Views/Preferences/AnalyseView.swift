import SwiftUI
import Charts
import Foundation

struct AnalyseView: View {
    @ObservedObject var timeModel: TimeModel
    @State private var selectedDate = Date()
    @State private var selectedCategory: TimerCategory = .work
    @Environment(\.colorScheme) var colorScheme
    
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
            AnalysisHeader(
                selectedDate: $selectedDate,
                selectedCategory: $selectedCategory,
                isToday: isToday
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    if !timeModel.isAppTrackingEnabled {
                        // App-Tracking aktivieren
                        EnableTrackingCard(timeModel: timeModel)
                    } else if appUsages.isEmpty {
                        // Keine Daten
                        EmptyAnalysisCard(category: selectedCategory, isToday: isToday)
                    } else {
                        // Chart und Liste
                        AnalysisContentView(
                            appUsages: appUsages,
                            totalDuration: totalDuration
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - Analysis Header

private struct AnalysisHeader: View {
    @Binding var selectedDate: Date
    @Binding var selectedCategory: TimerCategory
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            ModernSectionHeader(
                title: "analysis.title".localized,
                subtitle: "analysis.subtitle".localized
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
                        Text(selectedDate.formatSelectedDate())
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
    }
    
    private func previousDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextDay() {
        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
    }
}

// MARK: - Enable Tracking Card

private struct EnableTrackingCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
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
    }
}

// MARK: - Empty Analysis Card

private struct EmptyAnalysisCard: View {
    let category: TimerCategory
    let isToday: Bool
    
    var body: some View {
        ModernCard {
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
}

// MARK: - Analysis Content View

private struct AnalysisContentView: View {
    let appUsages: [AppUsage]
    let totalDuration: Int
    
    var body: some View {
        VStack(spacing: 32) {
            // Interactive Donut Chart
            ChartSectionView(appUsages: appUsages, totalDuration: totalDuration)
            
            // App-Liste
            AppListSectionView(appUsages: appUsages, totalDuration: totalDuration)
        }
    }
}

// MARK: - Chart Section View

private struct ChartSectionView: View {
    let appUsages: [AppUsage]
    let totalDuration: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("App-Verteilung")
                .font(.headline)
            
            InteractiveDonutChartView(appUsages: appUsages, totalDuration: totalDuration)
                .frame(width: 350, height: 350)
            
            VStack(spacing: 4) {
                Text("Gesamtzeit")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                
                Text(totalDuration.formatAsTime())
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - App List Section View

private struct AppListSectionView: View {
    let appUsages: [AppUsage]
    let totalDuration: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailansicht")
                .font(.headline)
            
            ModernCard {
                LazyVStack(spacing: 0) {
                    ForEach(Array(appUsages.prefix(10).enumerated()), id: \.element.id) { index, usage in
                        AppUsageRowWithIconView(
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

// MARK: - Interactive Donut Chart

private struct InteractiveDonutChartView: View {
    let appUsages: [AppUsage]
    let totalDuration: Int
    @State private var hoveredIndex: Int? = nil
    @State private var selectedAngle: Double? = nil
    @State private var appIcons: [String: NSImage] = [:]
    @Environment(\.colorScheme) var colorScheme
    
    private var chartData: [(String, Double, Color, Int, String)] {
        let total = Double(totalDuration)
        return appUsages.prefix(8).enumerated().map { index, usage in
            let percentage = Double(usage.duration) / total
            let color = colors[index % colors.count]
            return (usage.appName, percentage, color, usage.duration, usage.bundleID)
        }
    }
    
    private let colors: [Color] = [
        .blue, .green, .orange, .red, .purple, .pink, .yellow, .cyan
    ]
    
    var body: some View {
        ZStack {
            // Donut Chart mit Hover-Effekten
            Chart(Array(chartData.enumerated()), id: \.offset) { index, data in
                SectorMark(
                    angle: .value("Usage", data.1),
                    innerRadius: .ratio(0.45),
                    outerRadius: .ratio(hoveredIndex == index ? 0.95 : 0.85),
                    angularInset: 1.0
                )
                .foregroundStyle(data.2)
                .opacity(hoveredIndex == nil || hoveredIndex == index ? 0.9 : 0.5)
                .shadow(
                    color: hoveredIndex == index ? data.2.opacity(colorScheme == .dark ? 0.6 : 0.3) : .clear,
                    radius: colorScheme == .dark ? 4 : 2,
                    x: 0,
                    y: 1
                )
            }
            .chartAngleSelection(value: $selectedAngle)
            .onHover { isHovering in
                if !isHovering {
                    withAnimation(.easeOut(duration: 0.2)) {
                        hoveredIndex = nil
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let center = CGPoint(x: 175, y: 175)
                        let vector = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                        let distance = sqrt(vector.x * vector.x + vector.y * vector.y)
                        
                        let innerRadius = 175 * 0.45
                        let outerRadius = 175 * 0.95
                        
                        if distance >= innerRadius && distance <= outerRadius {
                            let angle = atan2(vector.y, vector.x)
                            let normalizedAngle = angle < 0 ? angle + 2 * .pi : angle
                            
                            var cumulativeAngle: Double = -(.pi / 2)
                            if cumulativeAngle < 0 { cumulativeAngle += 2 * .pi }
                            
                            for (index, data) in chartData.enumerated() {
                                let sectorAngle = data.1 * 2 * .pi
                                let endAngle = cumulativeAngle + sectorAngle
                                
                                if (normalizedAngle >= cumulativeAngle && normalizedAngle <= endAngle) ||
                                   (cumulativeAngle > endAngle && (normalizedAngle >= cumulativeAngle || normalizedAngle <= endAngle)) {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        hoveredIndex = index
                                    }
                                    break
                                }
                                cumulativeAngle = endAngle
                                if cumulativeAngle >= 2 * .pi { cumulativeAngle -= 2 * .pi }
                            }
                        } else {
                            withAnimation(.easeOut(duration: 0.2)) {
                                hoveredIndex = nil
                            }
                        }
                    }
                    .onEnded { _ in
                        // Hover bleibt bis explizit entfernt
                    }
            )
            
            // Center Content mit Animation und APP-ICON
            VStack(spacing: 8) {
                if let hoveredIndex = hoveredIndex, hoveredIndex < chartData.count {
                    let hoveredData = chartData[hoveredIndex]
                    
                    VStack(spacing: 4) {
                        Group {
                            if let appIcon = appIcons[hoveredData.4] {
                                Image(nsImage: appIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Image(systemName: "app.fill")
                                    .foregroundStyle(hoveredData.2)
                            }
                        }
                        .frame(width: 24, height: 24)
                        .cornerRadius(5)
                        .shadow(
                            color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                            radius: colorScheme == .dark ? 2 : 1,
                            x: 0,
                            y: 1
                        )
                        
                        Text(hoveredData.0)
                            .font(.system(size: 14, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Text(hoveredData.3.formatAsTime())
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundStyle(.secondary)
                        
                        Text("\(Int(hoveredData.1 * 100))%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(hoveredData.2)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
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
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 120, height: 120)
            .animation(.easeInOut(duration: 0.25), value: hoveredIndex)
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.2)) {
                hoveredIndex = nil
            }
        }
        .animation(.easeInOut(duration: 0.2), value: hoveredIndex)
        .onAppear {
            loadAllAppIcons()
        }
    }
    
    private func loadAllAppIcons() {
        for data in chartData {
            let bundleID = data.4
            loadAppIcon(for: bundleID)
        }
    }
    
    private func loadAppIcon(for bundleID: String) {
        DispatchQueue.global(qos: .background).async {
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
                return
            }
            
            let icon = NSWorkspace.shared.icon(forFile: appURL.path)
            
            DispatchQueue.main.async {
                self.appIcons[bundleID] = icon
            }
        }
    }
}

// MARK: - App Usage Row With Icon

private struct AppUsageRowWithIconView: View {
    let usage: AppUsage
    let totalDuration: Int
    let rank: Int
    
    @State private var appIcon: NSImage?
    @Environment(\.colorScheme) var colorScheme
    
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
            
            // APP-ICON
            Group {
                if let appIcon = appIcon {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "app.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 16, height: 16)
            .cornerRadius(3)
            .shadow(
                color: .black.opacity(colorScheme == .dark ? 0.3 : 0.1),
                radius: colorScheme == .dark ? 1 : 0.5,
                x: 0,
                y: 0.5
            )
            
            // App Info
            VStack(alignment: .leading, spacing: 2) {
                Text(usage.appName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(usage.duration.formatAsTime())
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
                            .shadow(
                                color: colors[(rank - 1) % colors.count].opacity(colorScheme == .dark ? 0.6 : 0.3),
                                radius: colorScheme == .dark ? 1 : 0.5,
                                x: 0,
                                y: 0.5
                            )
                    }
                }
                .frame(width: 60, height: 4)
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onAppear {
            loadAppIcon()
        }
    }
    
    private func loadAppIcon() {
        DispatchQueue.global(qos: .background).async {
            guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: usage.bundleID) else {
                return
            }
            
            let icon = NSWorkspace.shared.icon(forFile: appURL.path)
            
            DispatchQueue.main.async {
                self.appIcon = icon
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AnalyseView(timeModel: TimeModel())
        .frame(width: 800, height: 600)
}
