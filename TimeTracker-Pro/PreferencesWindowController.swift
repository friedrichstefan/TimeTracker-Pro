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

        // Erstelle ein modernes Fenster
        let window = NSWindow(contentViewController: hosting)
        window.title = "TimeTracker Pro"
        window.subtitle = "Einstellungen"
        
        // Moderne Fenster-Eigenschaften
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unifiedCompact
        
        // Größe und Position
        window.setContentSize(NSSize(width: 800, height: 550))
        window.minSize = NSSize(width: 700, height: 500)
        window.center()
        window.isReleasedWhenClosed = false
        
        // Traffic Light Buttons (rot, gelb, grün) schöner positionieren
        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = false
        
        // Moderne Hintergrund-Eigenschaften
        window.backgroundColor = NSColor.controlBackgroundColor
        window.hasShadow = true
        
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
}
