import AppKit
import SwiftUI

class PreferencesWindowController: NSWindowController {
    private var preferencesState = PreferencesState()
    private var timeModel: TimeModel
    
    init(timeModel: TimeModel) {
        self.timeModel = timeModel
        let contentView = PreferencesView(timeModel: timeModel, preferencesState: preferencesState)
        let hosting = NSHostingController(rootView: contentView)

        // Fenster mit Dark/Light Mode Support
        let window = NSWindow(contentViewController: hosting)
        window.title = "TimeTracker Pro"
        
        // Moderne Fenster-Eigenschaften mit Dark/Light Mode
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.toolbarStyle = .unified
        
        // Größe und Position
        window.setContentSize(NSSize(width: 900, height: 600))
        window.minSize = NSSize(width: 800, height: 500)
        window.center()
        window.isReleasedWhenClosed = false
        
        // WICHTIG: Automatische Dark/Light Mode Unterstützung
        window.appearance = nil  // nil = folgt dem System automatisch
        window.backgroundColor = NSColor.windowBackgroundColor  // Passt sich automatisch an
        window.hasShadow = true
        
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelectedTab(_ tab: PrefsTab) {
        preferencesState.setSelectedTab(tab)
    }
    
    // NEUE METHODE: Update für Appearance Changes
    func updateForAppearanceChange() {
        // Fenster-Appearance aktualisieren falls nötig
        window?.appearance = nil
        
        // Content View neu zeichnen lassen
        if let hostingController = window?.contentViewController as? NSHostingController<PreferencesView> {
            hostingController.rootView = PreferencesView(timeModel: timeModel, preferencesState: preferencesState)
        }
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
        NSApp.activate(ignoringOtherApps: true)
    }
}
