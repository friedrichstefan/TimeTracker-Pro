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
        
        if let button = statusItem.button {
            button.imagePosition = .noImage
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        }
    }
    
    func updateForAppearanceChange() {
        setupMenu()
    }
    
    private func updateStatusBarTitle() {
        if let button = statusItem.button {
            let seconds = timeModel.getCurrentTimerSeconds()
            let timerText = formatTimerString(seconds)
            
            // Nur Fortschritt anzeigen wenn aktiviert
            var progressText = ""
            if timeModel.showWorkProgressInStatusBar {
                let todayWorkSeconds = timeModel.getWorkTimeForDate(Date())
                let targetSeconds = timeModel.targetWorkHours * 3600
                let progressPercentage = targetSeconds > 0 ? min(100, (todayWorkSeconds * 100) / targetSeconds) : 0
                progressText = " (\(progressPercentage)%)"
            }
            
            if let activeCategory = timeModel.activeCategory, timeModel.isTimerRunning {
                button.title = "\(activeCategory.symbol) \(timerText)\(progressText)"
            } else if seconds > 0 {
                let maxCategory = getMaxCategory()
                button.title = "\(maxCategory.symbol) \(timerText)\(progressText)"
            } else {
                button.title = "00:00\(progressText)"
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
        menu.appearance = nil

        let timerView = MenuTimerView(timeModel: timeModel)
        let timerHostingController = NSHostingController(rootView: timerView)
        let timerHostingView = timerHostingController.view
        
        timerHostingView.frame = NSRect(x: 0, y: 0, width: 380, height: 280)
        timerHostingView.translatesAutoresizingMaskIntoConstraints = true

        let timerMenuItem = NSMenuItem()
        timerMenuItem.view = timerHostingView
        timerMenuItem.isEnabled = false
        menu.addItem(timerMenuItem)

        menu.addItem(NSMenuItem.separator())
        
        let detailItem = NSMenuItem(title: "Details…", action: #selector(handleOpenDetails(_:)), keyEquivalent: "d")
        detailItem.target = self
        menu.addItem(detailItem)

        menu.addItem(NSMenuItem.separator())

        let prefsItem = NSMenuItem(title: "Einstellungen…", action: #selector(handleOpenPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)

        menu.addItem(NSMenuItem.separator())

        let quitTitle = "Beenden TimeTracker‑Pro"
        let quitItem = NSMenuItem(title: quitTitle, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = nil
        menu.addItem(quitItem)

        statusItem.menu = menu
    }
    
    @objc func handleOpenDetails(_ sender: Any?) {
        appDelegate?.openPreferencesWithAnalyse()
    }
    
    @objc func handleOpenPreferences(_ sender: Any?) {
        appDelegate?.openPreferencesWithSettings()
    }
}
