import AppKit
import SwiftUI
import Combine

final class StatusBarController {
    private var statusItem: NSStatusItem
    private var cancellables = Set<AnyCancellable>()
    private let timeModel: TimeModel
    private weak var appDelegate: AppDelegate?

    init(timeModel: TimeModel, appDelegate: AppDelegate) {
        self.timeModel = timeModel
        self.appDelegate = appDelegate
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        setupStatusItem()
        setupMenu()
        
        // Subscribe zu allen Timer-Änderungen
        Publishers.CombineLatest4(
            timeModel.$workSeconds,
            timeModel.$coffeeSeconds,
            timeModel.$lunchSeconds,
            timeModel.$activeCategory
        )
        .combineLatest(timeModel.$isTimerRunning)
        .sink { [weak self] (timerData, isRunning) in
            DispatchQueue.main.async {
                self?.updateStatusBarTitle()
            }
        }
        .store(in: &cancellables)
    }
    
    private func setupStatusItem() {
        updateStatusBarTitle()
    }
    
    private func updateStatusBarTitle() {
        if let button = statusItem.button {
            let seconds = timeModel.getCurrentTimerSeconds()
            let timerText = formatTimerString(seconds)
            
            if let activeCategory = timeModel.activeCategory, timeModel.isTimerRunning {
                button.title = "\(activeCategory.symbol) \(timerText)"
            } else if seconds > 0 {
                // Zeige den Timer mit der meisten Zeit wenn nicht aktiv
                let maxCategory = getMaxCategory()
                button.title = "\(maxCategory.symbol) \(timerText)"
            } else {
                button.title = "00:00"
            }
            
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }
    }
    
    private func getMaxCategory() -> TimerCategory {
        let maxSeconds = max(timeModel.workSeconds, timeModel.coffeeSeconds, timeModel.lunchSeconds)
        
        if timeModel.workSeconds == maxSeconds {
            return .work
        } else if timeModel.coffeeSeconds == maxSeconds {
            return .coffee
        } else {
            return .lunch
        }
    }
    
    private func formatTimerString(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()

        // Timer-Steuerung
        let timerView = MenuTimerView(timeModel: timeModel)
        let timerHostingController = NSHostingController(rootView: timerView)
        let timerHostingView = timerHostingController.view
        
        // Höhe angepasst für größere Buttons
        timerHostingView.frame = NSRect(x: 0, y: 0, width: 380, height: 230)
        timerHostingView.translatesAutoresizingMaskIntoConstraints = true

        let timerMenuItem = NSMenuItem()
        timerMenuItem.view = timerHostingView
        timerMenuItem.isEnabled = false
        menu.addItem(timerMenuItem)

        menu.addItem(NSMenuItem.separator())
        
        // Detaills…
        let detailItem = NSMenuItem(title: "Detaills…", action: #selector(handleOpenPreferences(_:)), keyEquivalent: ",")
        detailItem.target = self
        menu.addItem(detailItem)

        menu.addItem(NSMenuItem.separator())

        // Einstellungen…
        let prefsItem = NSMenuItem(title: "Einstellungen…", action: #selector(handleOpenPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(NSMenuItem.separator())

        // Beenden
        let quitTitle = "Beenden TimeTracker‑Pro"
        let quitItem = NSMenuItem(title: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = nil
        menu.addItem(quitItem)

        statusItem.menu = menu
    }
    
    // KORRIGIERTE METHODE
    @objc func handleOpenPreferences(_ sender: Any?) {
        appDelegate?.openPreferences(sender)
    }
}
