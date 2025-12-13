//
//  TimeTracker_ProApp.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

@main
struct TimeTrackerProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Kein sichtbares WindowGroup nötig für eine Menüleisten‑App
        Settings {
            EmptyView()
        }
    }
}
