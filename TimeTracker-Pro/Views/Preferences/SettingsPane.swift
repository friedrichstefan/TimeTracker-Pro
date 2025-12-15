//
//  SettingsPane.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import SwiftUI

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

                // Setting Cards
                WorkTimeCard(timeModel: timeModel)
                MonitoringCard(timeModel: timeModel)
                TimerBehaviorCard(timeModel: timeModel)
                SmartPauseCard(timeModel: timeModel)
                AppTrackingCard(timeModel: timeModel)
                DataExportCard(timeModel: timeModel)
            }
            .padding(24)
        }
    }
}

// MARK: - Work Time Settings Card

private struct WorkTimeCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                CardHeader(
                    title: "Arbeitszeit",
                    subtitle: "Definiere deine täglichen Arbeitszeiten",
                    icon: "clock.badge.checkmark",
                    iconColor: .blue
                )
                
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
    }
}

// MARK: - Monitoring Card

private struct MonitoringCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                CardHeader(
                    title: "Arbeitszeit-Monitoring",
                    subtitle: "Überwachung und Erinnerungen für deine Arbeitszeit-Ziele",
                    icon: "bell.badge.fill",
                    iconColor: timeModel.workTimeMonitoringEnabled ? .blue : .secondary
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    ModernToggle(
                        title: "Arbeitszeit-Erinnerungen",
                        subtitle: "Benachrichtigungen über Tagesfortschritt und Ziele",
                        isOn: $timeModel.workTimeMonitoringEnabled
                    )
                    
                    if timeModel.workTimeMonitoringEnabled {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 14))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Du erhältst Benachrichtigungen bei:")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    
                                    Text("• 50% des Tagesziels erreicht")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("• 75% des Tagesziels erreicht")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("• 100% - Tagesziel erreicht")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("• Erinnerung bei wenig Arbeitszeit am Nachmittag")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        
                        ModernToggle(
                            title: "Fortschritt in StatusBar",
                            subtitle: "Zeigt Arbeitszeit-Prozent in der Menüleiste",
                            isOn: $timeModel.showWorkProgressInStatusBar
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Timer Behavior Card

private struct TimerBehaviorCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                CardHeader(
                    title: "Timer-Verhalten",
                    subtitle: "Automatische Funktionen und Erinnerungen",
                    icon: "timer",
                    iconColor: .green
                )
                
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
    }
}

// MARK: - Smart Pause Card

private struct SmartPauseCard: View {
    @ObservedObject var timeModel: TimeModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                CardHeader(
                    title: "Intelligentes Pausieren",
                    subtitle: "Automatische Timer-Steuerung basierend auf Rechner-Status und Arbeitszeiten",
                    icon: "brain.head.profile",
                    iconColor: (timeModel.enableAutoPause || timeModel.pauseOutsideWorkHours) ? .blue : .secondary
                )
                
                VStack(alignment: .leading, spacing: 16) {
                    ModernToggle(
                        title: "Intelligentes Pausieren aktivieren",
                        subtitle: "Automatische Timer-Steuerung während Arbeitszeiten wenn Rechner gesperrt wird",
                        isOn: $timeModel.enableAutoPause
                    )
                    
                    ModernToggle(
                        title: "Work-Timer außerhalb Arbeitszeit pausieren",
                        subtitle: "Arbeits-Timer pausieren wenn außerhalb der Kernarbeitszeit gesperrt (>10s)",
                        isOn: $timeModel.pauseOutsideWorkHours
                    )
                    
                    if timeModel.enableAutoPause || timeModel.pauseOutsideWorkHours {
                        VStack(spacing: 16) {
                            if timeModel.enableAutoPause {
                                ModernToggle(
                                    title: "Nur während Arbeitszeiten (Auto-Pause)",
                                    subtitle: "Automatik nur während der definierten Kern-Arbeitszeit",
                                    isOn: $timeModel.onlyDuringWorkHours
                                )
                            }
                            
                            ModernToggle(
                                title: "Vor Fortsetzung fragen (während Arbeitszeit)",
                                subtitle: "Nach Entsperren während Arbeitszeit nachfragen ob Timer fortgesetzt werden soll",
                                isOn: $timeModel.askBeforeResuming
                            )
                            
                            ModernToggle(
                                title: "Nach Pausierung fragen (außerhalb Arbeitszeit)",
                                subtitle: "Fragen ob Timer nach automatischer Pausierung außerhalb Arbeitszeit fortgesetzt werden soll",
                                isOn: $timeModel.askToResumeAfterPause
                            )
                            
                            if timeModel.enableAutoPause {
                                // Schwellwerte für Auto-Pause
                                VStack(spacing: 12) {
                                    Text("Schwellwerte")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Ignorier-Schwelle")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                            
                                            Text("Sperrungen unter dieser Zeit zählen zur Arbeitszeit")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            TextField("Sek", value: $timeModel.minimumPauseDurationSeconds, formatter: NumberFormatter())
                                                .textFieldStyle(.roundedBorder)
                                                .frame(width: 60)
                                            
                                            Text("Sekunden")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Mittagessen-Schwelle")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                            
                                            Text("Ab dieser Zeit wird Mittagessen statt Kaffeepause gezählt")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            TextField("Min", value: $timeModel.lunchThresholdMinutes, formatter: NumberFormatter())
                                                .textFieldStyle(.roundedBorder)
                                                .frame(width: 60)
                                            
                                            Text("Minuten")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    
                    // System-Status
                    HStack {
                        Text("Status:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Circle()
                                .fill(timeModel.systemStateMonitor.isLocked ? .red : .green)
                                .frame(width: 8, height: 8)
                            
                            Text(timeModel.systemStateMonitor.isLocked ? "Gesperrt" : "Aktiv")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            if timeModel.systemStateMonitor.isLocked,
                               let duration = timeModel.systemStateMonitor.currentLockDuration {
                                Text("(\(Int(duration).formatAsDuration()))")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                
                if timeModel.enableAutoPause || timeModel.pauseOutsideWorkHours {
                    // Info-Box mit Regeln
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                            .font(.system(size: 14))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Automatik-Regeln:")
                                .font(.caption)
                                .fontWeight(.medium)
                            
                            if timeModel.enableAutoPause {
                                Text("Während Arbeitszeit:")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                                
                                Text("• < \(timeModel.minimumPauseDurationSeconds)s: Zur Arbeitszeit addiert")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("• \(timeModel.minimumPauseDurationSeconds)s - \(timeModel.lunchThresholdMinutes)min: Kaffeepause")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("• > \(timeModel.lunchThresholdMinutes)min: Mittagessen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if timeModel.pauseOutsideWorkHours {
                                Text("Außerhalb Arbeitszeit:")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.orange)
                                    .padding(.top, 4)
                                
                                Text("• Work-Timer wird bei Sperrung >10s pausiert")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text("• Push-Benachrichtigung zum Fortsetzen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

// MARK: - App Tracking Card

private struct AppTrackingCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                CardHeader(
                    title: "App-Tracking",
                    subtitle: "Überwachung der App-Nutzung während der Arbeitszeit",
                    icon: "apps.iphone",
                    iconColor: .orange
                )
                
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
    }
}

// MARK: - Data Export Card

private struct DataExportCard: View {
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        ModernCard {
            VStack(alignment: .leading, spacing: 20) {
                CardHeader(
                    title: "Daten & Export",
                    subtitle: "Datenverwaltung und Export-Optionen",
                    icon: "externaldrive.badge.person.crop",
                    iconColor: .purple
                )
                
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
}

// MARK: - Preview

#Preview {
    SettingsPane(timeModel: TimeModel())
        .frame(width: 600, height: 800)
}
