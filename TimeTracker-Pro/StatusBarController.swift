import AppKit
import SwiftUI
import Combine

final class StatusBarController {
    private var statusItem: NSStatusItem
    private var cancellable: AnyCancellable?
    private let timeModel: TimeModel

    init(timeModel: TimeModel, appDelegate: AppDelegate) {
        self.timeModel = timeModel
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // initial title
        if let button = statusItem.button {
            button.title = timeModel.timeString
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }

        // Erstelle Menu
        let menu = NSMenu()

        // 1) NSMenuItem mit SwiftUI-View (eingebettete große Uhr)
        let hostingController = NSHostingController(rootView: MenuClockView(timeModel: timeModel))
        let hostingView = hostingController.view
        // Stelle eine sinnvolle Größe ein, sonst bleibt das Menü sehr klein
        hostingView.frame = NSRect(x: 0, y: 0, width: 360, height: 100)
        hostingView.translatesAutoresizingMaskIntoConstraints = true

        let clockMenuItem = NSMenuItem()
        clockMenuItem.view = hostingView
        // Nicht auswählbar machen
        clockMenuItem.isEnabled = false
        menu.addItem(clockMenuItem)

        menu.addItem(NSMenuItem.separator())

        // 2) Einstellungen… (Cmd-,) -> Ziel ist AppDelegate.openPreferences
        let prefsItem = NSMenuItem(title: "Einstellungen…", action: #selector(AppDelegate.openPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = appDelegate
        menu.addItem(prefsItem)

        menu.addItem(NSMenuItem.separator())

        // 3) Beenden (Cmd-Q)
        let quitTitle = "Beenden TimeTracker‑Pro"
        let quitItem = NSMenuItem(title: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = nil // NSApp behandelt terminate
        menu.addItem(quitItem)

        statusItem.menu = menu

        // Subscribe: Aktualisiere das StatusItem-Title mit der formatierten Zeit
        cancellable = timeModel.$timeString.sink { [weak self] newString in
            DispatchQueue.main.async {
                self?.statusItem.button?.title = newString
            }
        }
    }
}
