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
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Uhr-Einstellungen")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Sekunden anzeigen", isOn: $timeModel.showSeconds)
                    Toggle("24-Stunden-Format", isOn: $timeModel.use24Hour)
                    Toggle("Datum anzeigen", isOn: $timeModel.showDate)
                }
                .toggleStyle(.switch)
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.regularMaterial)
    }
}
