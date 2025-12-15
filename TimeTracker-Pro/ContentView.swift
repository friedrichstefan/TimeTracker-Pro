//
//  ContentView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
            TabView {
                SettingsView(timeModel: timeModel)
                    .tabItem { Text("Einstellungen") }
                    .tag(0)
                LargeClockView(timeModel: timeModel)
                    .tabItem { Text("Große Uhr") }
                    .tag(1)
            }
            .frame(width: 700, height: 200)
            .tabViewStyle(.sidebarAdaptable)
        }
}
