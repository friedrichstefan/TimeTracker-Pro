//
//  SettingsView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Zeiteinstellungen")
                .font(.headline)

            Toggle("Sekunden anzeigen", isOn: $timeModel.showSeconds)
            Toggle("24‑Stunden‑Format", isOn: $timeModel.use24Hour)
            Toggle("Datum anzeigen", isOn: $timeModel.showDate)

            Divider()

            HStack {
                Spacer()
                Button("Schließen") {
                    // Popover schließt automatisch bei transient; falls man explizit schließen will:
                    if let window = NSApp.keyWindow {
                        window.performClose(nil)
                    }
                }
            }
        }
        .padding()
    }
}
