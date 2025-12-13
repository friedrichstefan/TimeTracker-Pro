//
//  PreferencesWindowController.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import AppKit
import SwiftUI

class PreferencesWindowController: NSWindowController {
    init(timeModel: TimeModel) {
        let contentView = PreferencesView(timeModel: timeModel)
        let hosting = NSHostingController(rootView: contentView)

        // Erstelle ein resizables Fenster mit moderner Optik
        let window = NSWindow(contentViewController: hosting)
        window.title = "Einstellungen"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 360))
        window.center()
        window.isReleasedWhenClosed = false

        // Optional: moderne Titelbar-Eigenschaften (kann entfernt werden)
        window.titlebarAppearsTransparent = false
        window.standardWindowButton(.zoomButton)?.isHidden = false

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
