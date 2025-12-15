//
//  PreferencesView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

private enum PrefsTab: Hashable {
    case settings
    case largeClock
}

struct PreferencesView: View {
    @ObservedObject var timeModel: TimeModel
    @State private var selection: PrefsTab? = .settings

    var body: some View {
        NavigationView {
            // Sidebar
            List(selection: $selection) {
                NavigationLink(
                    destination: SettingsPane(timeModel: timeModel),
                    tag: PrefsTab.settings,
                    selection: $selection
                ) {
                    Label("Einstellungen", systemImage: "gearshape")
                }
                .tag(PrefsTab.settings)

                NavigationLink(
                    destination: LargeClockPane(timeModel: timeModel),
                    tag: PrefsTab.largeClock,
                    selection: $selection
                ) {
                    Label("Große Uhr", systemImage: "clock")
                }
                .tag(PrefsTab.largeClock)
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 160) // Sidebar-Breite
            .toolbar {
                // Optional: hier könnten Toolbar-Buttons eingefügt werden
            }

            // Standard-Detail-View (wird angezeigt, wenn kein Eintrag gewählt)
            SettingsPane(timeModel: timeModel)
        }
        .frame(minWidth: 520, minHeight: 320)
    }
}

// MARK: - Sidebar Detail Views

private struct SettingsPane: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Allgemeine Zeiteinstellungen")
                .font(.title2)
                .padding(.bottom, 4)

            Toggle("Sekunden anzeigen", isOn: $timeModel.showSeconds)
            Toggle("24‑Stunden‑Format", isOn: $timeModel.use24Hour)
            Toggle("Datum anzeigen", isOn: $timeModel.showDate)

            Spacer()

            HStack {
                Spacer()
                Button("Schließen") {
                    closeWindow()
                }
            }
        }
        .padding()
    }

    private func closeWindow() {
        NSApp.keyWindow?.performClose(nil)
    }
}

private struct LargeClockPane: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        VStack(spacing: 12) {
            // Live‑Vorschau der großen Uhr
            LargeClockView(timeModel: timeModel)
                .frame(minHeight: 160)

            // Slider zur Anpassung der Schriftgröße
            HStack {
                Text("Schriftgröße")
                Slider(value: $timeModel.largeClockFontSize, in: 18...120, step: 1)
                    .frame(minWidth: 220)
                Text("\(Int(timeModel.largeClockFontSize)) pt")
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.horizontal)

            Spacer()

            HStack {
                Spacer()
                Button("Schließen") {
                    closeWindow()
                }
            }
        }
        .padding()
    }
// test ob das geht
    private func closeWindow() {
        NSApp.keyWindow?.performClose(nil)
    }
}
