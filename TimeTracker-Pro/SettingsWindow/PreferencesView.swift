//
//  PreferencesView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI
import Combine

enum PrefsTab: String, CaseIterable, Hashable {
    case timerDetails = "timerDetails"
    case chronik = "chronik"
    case analyse = "analyse"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .timerDetails: return "Timer-Details"
        case .chronik: return "Tagesverlauf"
        case .analyse: return "App-Analyse"
        case .settings: return "Einstellungen"
        }
    }
    
    var systemImage: String {
        switch self {
        case .timerDetails: return "timer"
        case .chronik: return "clock.arrow.circlepath"
        case .analyse: return "chart.pie"
        case .settings: return "gearshape"
        }
    }
    
    var isSettings: Bool {
        return self == .settings
    }
}

struct PreferencesView: View {
    @ObservedObject var timeModel: TimeModel
    @ObservedObject var preferencesState: PreferencesState
    
    init(timeModel: TimeModel, preferencesState: PreferencesState) {
        self.timeModel = timeModel
        self.preferencesState = preferencesState
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Moderne Sidebar mit verbesserter Struktur
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(spacing: 8) {
                        Text("TimeTracker Pro")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                        
                        Text("Einstellungen")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                }
                .padding(.top, 20)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                // Navigation Items - aufgeteilt in Bereiche
                VStack(spacing: 4) {
                    // Haupt-Navigation
                    ForEach(PrefsTab.allCases.filter { !$0.isSettings }, id: \.self) { tab in
                        ModernSidebarItem(
                            tab: tab,
                            isSelected: preferencesState.selectedTab == tab
                        ) {
                            preferencesState.selectedTab = tab
                        }
                    }
                    
                    // Trennlinie
                    Divider()
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    
                    // Einstellungen (separiert)
                    ForEach(PrefsTab.allCases.filter { $0.isSettings }, id: \.self) { tab in
                        ModernSidebarItem(
                            tab: tab,
                            isSelected: preferencesState.selectedTab == tab
                        ) {
                            preferencesState.selectedTab = tab
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                Spacer()
                
                // Footer mit drei Punkten (wie in Xcode)
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Optionales Aktions-Menu
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, 16)
                    .padding(.trailing, 16)
                }
            }
            .frame(minWidth: 200)
            .background(.regularMaterial)
        } detail: {
            // Detail View
            VStack(spacing: 0) {
                Group {
                    switch preferencesState.selectedTab {
                    case .timerDetails:
                        TimerDetailView(timeModel: timeModel)
                    case .chronik:
                        ChronikView(timeModel: timeModel)
                    case .analyse:
                        AnalyseView(timeModel: timeModel)
                    case .settings:
                        SettingsPane(timeModel: timeModel)
                    }
                }
                .background(Color(NSColor.windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                .padding(16)
                .background(Color(NSColor.controlBackgroundColor))
            }
        }
        .frame(minWidth: 800, minHeight: 550)
        .navigationSplitViewStyle(.balanced)
    }
}

// MARK: - Moderne UI Komponenten

struct ModernSidebarItem: View {
    let tab: PrefsTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.systemImage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 18)
                
                Text(tab.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .blue : .clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Detail Views

struct SettingsPane: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                ModernSectionHeader(
                    title: "Einstellungen",
                    subtitle: "Konfiguration für Arbeitszeit und App-Tracking"
                )

                // Arbeitszeit-Einstellungen
                ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Arbeitszeit")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Definiere deine täglichen Arbeitszeiten")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "clock.badge.checkmark")
                                .font(.system(size: 24))
                                .foregroundStyle(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Tägliche Arbeitszeit
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tägliche Arbeitszeit")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Ziel-Arbeitszeit pro Tag")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    TextField("Stunden", value: $timeModel.targetWorkHours, formatter: NumberFormatter())
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 60)
                                    
                                    Text("Stunden")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // Arbeitszeiten
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Kern-Arbeitszeit")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Von - Bis (für Benachrichtigungen)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    DatePicker("", selection: $timeModel.workStartTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(width: 80)
                                    
                                    Text("bis")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    DatePicker("", selection: $timeModel.workEndTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(width: 80)
                                }
                            }
                            
                            ModernToggle(
                                title: "Wochenenden einbeziehen",
                                subtitle: "Arbeitszeit-Ziele auch für Samstag und Sonntag",
                                isOn: $timeModel.includeWeekends
                            )
                        }
                    }
                }
                
                // Timer-Verhalten
                ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Timer-Verhalten")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Automatische Funktionen und Erinnerungen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "timer")
                                .font(.system(size: 24))
                                .foregroundStyle(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ModernToggle(
                                title: "Auto-Stopp nach Inaktivität",
                                subtitle: "Timer automatisch stoppen nach 30 Min. Inaktivität",
                                isOn: $timeModel.autoStopOnInactivity
                            )
                            
                            ModernToggle(
                                title: "Benachrichtigungen",
                                subtitle: "Erinnerungen für Pausen und Arbeitszeit-Ende",
                                isOn: $timeModel.notificationsEnabled
                            )
                            
                            if timeModel.notificationsEnabled {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Pausenerinnerung")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text("Erinnerung alle X Minuten")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 8) {
                                        TextField("Min", value: $timeModel.breakReminderInterval, formatter: NumberFormatter())
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 60)
                                        
                                        Text("Minuten")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.leading, 16)
                            }
                        }
                    }
                }
                
                // App-Tracking
                ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("App-Tracking")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Überwachung der App-Nutzung während der Arbeitszeit")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "apps.iphone")
                                .font(.system(size: 24))
                                .foregroundStyle(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ModernToggle(
                                title: "App-Tracking aktivieren",
                                subtitle: "Zeichnet alle 5 Sekunden die aktive App während Arbeits-Timern auf",
                                isOn: $timeModel.isAppTrackingEnabled
                            )
                            
                            if timeModel.isAppTrackingEnabled {
                                ModernToggle(
                                    title: "Nur produktive Apps tracken",
                                    subtitle: "Ignoriert Spiele und Social Media Apps",
                                    isOn: $timeModel.trackOnlyProductiveApps
                                )
                                
                                ModernToggle(
                                    title: "Warnungen bei unproduktiven Apps",
                                    subtitle: "Benachrichtigung wenn > 10 Min auf nicht-produktiven Apps",
                                    isOn: $timeModel.warnUnproductiveApps
                                )
                            }
                        }
                        
                        if timeModel.isAppTrackingEnabled {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 14))
                                
                                Text("App-Tracking läuft nur während 'Arbeiten'-Sessions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                
                // Datenschutz & Export
                ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daten & Export")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Datenverwaltung und Export-Optionen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "externaldrive.badge.person.crop")
                                .font(.system(size: 24))
                                .foregroundStyle(.purple)
                        }
                        
                        VStack(spacing: 12) {
                            HStack {
                                Button("CSV Export") {
                                    timeModel.exportToCSV()
                                }
                                .buttonStyle(ExportButtonStyle(color: .blue))
                                
                                Button("JSON Export") {
                                    timeModel.exportToJSON()
                                }
                                .buttonStyle(ExportButtonStyle(color: .green))
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("Daten automatisch löschen nach:")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Picker("", selection: $timeModel.dataRetentionDays) {
                                    Text("Nie").tag(0)
                                    Text("30 Tage").tag(30)
                                    Text("90 Tage").tag(90)
                                    Text("1 Jahr").tag(365)
                                }
                                .pickerStyle(MenuPickerStyle())
                                .frame(width: 100)
                            }
                            
                            if timeModel.dataRetentionDays > 0 {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(.orange)
                                        .font(.system(size: 12))
                                    
                                    Text("Daten älter als \(timeModel.dataRetentionDays) Tage werden automatisch gelöscht")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Button Styles

struct ExportButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color, in: RoundedRectangle(cornerRadius: 6))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Moderne UI Komponenten

struct ModernSectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ModernCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.quaternary, lineWidth: 0.5)
        )
    }
}

struct ModernToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle())
        }
        .padding(.vertical, 4)
    }
}
