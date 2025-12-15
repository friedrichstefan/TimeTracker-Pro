//
//  AppDelegate.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var prefsWindowController: PreferencesWindowController?
    let timeModel = TimeModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Dynamisches Erscheinungsbild aktivieren
        setupDynamicAppearance()
        
        // Notification Delegate setzen
        UNUserNotificationCenter.current().delegate = self
        
        // Erstelle StatusBar mit Menu
        statusBarController = StatusBarController(timeModel: timeModel, appDelegate: self)

        // Main Menu mit Settings-Button
        setupMainMenu()
    }
    
    // NEUE METHODE: Dynamisches Erscheinungsbild
    private func setupDynamicAppearance() {
        // Automatisches Dark/Light Mode switching
        NSApp.appearance = nil // nil bedeutet "folge dem System"
        
        // Optional: Beobachte Änderungen des System-Erscheinungsbilds
        DistributedNotificationCenter.default.addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // Wird aufgerufen wenn User zwischen Dark/Light Mode wechselt
            self?.handleAppearanceChange()
        }
    }
    
    // NEUE METHODE: Handle Appearance Changes
    private func handleAppearanceChange() {
        // StatusBar und Fenster aktualisieren
        statusBarController?.updateForAppearanceChange()
        prefsWindowController?.updateForAppearanceChange()
    }

    private func setupMainMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        NSApp.mainMenu = mainMenu

        let appMenu = NSMenu()
        let appName = "TimeTracker‑Pro"

        appMenu.addItem(withTitle: "About \(appName)", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())

        // Settings-Button
        let prefsItem = NSMenuItem(title: "Einstellungen…", action: #selector(openPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = self
        appMenu.addItem(prefsItem)

        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        appMenuItem.submenu = appMenu
    }

    @objc func openPreferences(_ sender: Any?) {
        openPreferencesWithSettings()
    }
    
    func openPreferencesWithDetails() {
        openPreferencesWithTab(.chronik)
    }
    
    func openPreferencesWithAnalyse() {
        openPreferencesWithTab(.analyse)
    }
    
    func openPreferencesWithSettings() {
        openPreferencesWithTab(.settings)
    }
    
    private func openPreferencesWithTab(_ tab: PrefsTab) {
        prefsWindowController?.close()
        prefsWindowController = nil
        
        prefsWindowController = PreferencesWindowController(timeModel: timeModel)
        prefsWindowController?.setSelectedTab(tab)
        prefsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        prefsWindowController?.window?.makeKeyAndOrderFront(nil)
    }
}

// MARK: - Notification Delegate Extension

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Received notification response: \(response.actionIdentifier) for category: \(response.notification.request.content.categoryIdentifier)")
        
        switch response.actionIdentifier {
        case "RESUME_ACTION":
            print("User chose to resume work")
            DispatchQueue.main.async {
                self.timeModel.resumeWorkFromNotification()
            }
            
        case "DISMISS_ACTION":
            print("User dismissed resume request")
            DispatchQueue.main.async {
                self.timeModel.dismissResumeRequest()
            }
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped on notification itself - behandle als Resume
            print("User tapped notification - resuming work")
            DispatchQueue.main.async {
                self.timeModel.resumeWorkFromNotification()
            }
            
        case UNNotificationDismissActionIdentifier:
            print("User dismissed notification")
            DispatchQueue.main.async {
                self.timeModel.dismissResumeRequest()
            }
            
        default:
            print("Unknown notification action: \(response.actionIdentifier)")
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            print("Will present notification: \(notification.request.identifier)")
            
            // Benachrichtigungen auch anzeigen wenn App im Vordergrund ist
            if #available(macOS 11.0, *) {
                completionHandler([.banner, .sound])
            } else {
                completionHandler([.alert, .sound])
            }
        }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didDeliver notification: UNNotification) {
        print("Did deliver notification: \(notification.request.identifier)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("User requested to open notification settings")
        // Optional: Öffne Einstellungen wenn User auf "Manage" klickt
        openPreferencesWithSettings()
    }
}

// MARK: - Application Lifecycle

extension AppDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup beim Beenden der App
        print("Application will terminate - cleaning up...")
        
        // Timer stoppen
        if timeModel.isTimerRunning {
            timeModel.stopTimer()
        }
        
        // Notification Observer entfernen
        DistributedNotificationCenter.default.removeObserver(self)
        UNUserNotificationCenter.current().delegate = nil
        
        // StatusBar cleanup
        statusBarController = nil
        
        // Preferences cleanup
        prefsWindowController?.close()
        prefsWindowController = nil
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        print("Application did become active")
        // Optional: Aktualisiere UI wenn App aktiviert wird
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        print("Application did resign active")
        // Optional: Speichere Zustand wenn App deaktiviert wird
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // Verhalten wenn App-Icon im Dock geklickt wird
        if !flag {
            // Keine sichtbaren Fenster - öffne Einstellungen
            openPreferencesWithSettings()
        }
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        // Optional: Handle file opening (z.B. für Export-Dateien)
        print("Request to open file: \(filename)")
        return false
    }
}

// MARK: - Error Handling

extension AppDelegate {
    private func handleError(_ error: Error, context: String) {
        print("Error in \(context): \(error.localizedDescription)")
        
        // Optional: Zeige Error-Dialog für kritische Fehler
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Fehler"
            alert.informativeText = "Ein Fehler ist aufgetreten: \(error.localizedDescription)"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}

// MARK: - Debug Helpers

extension AppDelegate {
    #if DEBUG
    @objc private func debugMenuItems() -> [NSMenuItem] {
        let debugMenu = NSMenuItem(title: "Debug", action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "Debug")
        
        let printStateItem = NSMenuItem(title: "Print State", action: #selector(debugPrintState), keyEquivalent: "")
        printStateItem.target = self
        submenu.addItem(printStateItem)
        
        let testNotificationItem = NSMenuItem(title: "Test Notification", action: #selector(debugTestNotification), keyEquivalent: "")
        testNotificationItem.target = self
        submenu.addItem(testNotificationItem)
        
        debugMenu.submenu = submenu
        return [debugMenu]
    }
    
    @objc private func debugPrintState() {
        print("=== DEBUG STATE ===")
        print("Timer running: \(timeModel.isTimerRunning)")
        print("Active category: \(String(describing: timeModel.activeCategory))")
        print("Work seconds: \(timeModel.workSeconds)")
        print("Coffee seconds: \(timeModel.coffeeSeconds)")
        print("Lunch seconds: \(timeModel.lunchSeconds)")
        print("Auto pause enabled: \(timeModel.enableAutoPause)")
        print("System locked: \(timeModel.systemStateMonitor.isLocked)")
        print("Work time monitoring: \(timeModel.workTimeMonitoringEnabled)")
        print("==================")
    }
    
    @objc private func debugTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification from TimeTracker Pro"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "debug_test_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending test notification: \(error)")
            } else {
                print("Test notification scheduled")
            }
        }
    }
    #endif
}
