//
//  AppDelegate.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var prefsWindowController: PreferencesWindowController?
    let timeModel = TimeModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Dynamisches Erscheinungsbild aktivieren
        setupDynamicAppearance()
        
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
