//
//  PreferencesView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

enum PrefsTab: String, CaseIterable, Hashable {  // private entfernt
    case timerDetails = "timerDetails"
    case chronik = "chronik"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .timerDetails: return "Timer-Details"
        case .chronik: return "Tagesverlauf"
        case .settings: return "Einstellungen"
        }
    }
    
    var systemImage: String {
        switch self {
        case .timerDetails: return "timer"
        case .chronik: return "clock.arrow.circlepath"
        case .settings: return "gearshape"
        }
    }
}

struct PreferencesView: View {
    @ObservedObject var timeModel: TimeModel
    @State private var selectedTab: PrefsTab = .timerDetails

    var body: some View {
        NavigationSplitView {
            // Moderne Sidebar
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("TimeTracker Pro")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("Einstellungen")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Navigation Items
                VStack(spacing: 4) {
                    ForEach(PrefsTab.allCases, id: \.self) { tab in
                        ModernSidebarItem(
                            tab: tab,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                Spacer()
            }
            .frame(minWidth: 200)
            .background(.regularMaterial)
        } detail: {
            // Detail View mit modernem Container
            ModernDetailContainer {
                Group {
                    switch selectedTab {
                    case .timerDetails:
                        TimerDetailView(timeModel: timeModel)
                    case .chronik:
                        ChronikView(timeModel: timeModel)
                    case .settings:
                        SettingsPane(timeModel: timeModel)
                    }
                }
            }
        }
        .frame(minWidth: 800, minHeight: 550)
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

struct ModernDetailContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
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
                    title: "Allgemeine Einstellungen",
                    subtitle: "Konfiguration der Uhr-Anzeige"
                )

                // Settings Card
                ModernCard {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Zeitanzeige")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            ModernToggle(
                                title: "Sekunden anzeigen",
                                subtitle: "Zeigt Sekunden in der Zeitanzeige",
                                isOn: $timeModel.showSeconds
                            )
                            
                            ModernToggle(
                                title: "24-Stunden-Format",
                                subtitle: "Verwendet 24h statt 12h Format",
                                isOn: $timeModel.use24Hour
                            )
                            
                            ModernToggle(
                                title: "Datum anzeigen",
                                subtitle: "Zeigt das aktuelle Datum an",
                                isOn: $timeModel.showDate
                            )
                        }
                    }
                }
            }
            .padding(24)
        }
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
