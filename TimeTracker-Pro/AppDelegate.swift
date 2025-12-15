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
        // Erstelle StatusBar mit Menu
        statusBarController = StatusBarController(timeModel: timeModel, appDelegate: self)

        // Main Menu mit Settings-Button
        setupMainMenu()
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

        // Settings-Button WIEDER HINZUFÜGEN - aber mit unserer Custom-Methode
        let prefsItem = NSMenuItem(title: "Einstellungen…", action: #selector(openPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = self  // WICHTIG: Ziel auf self setzen
        appMenu.addItem(prefsItem)

        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        appMenuItem.submenu = appMenu
    }

    // Diese Methode wird für Cmd+, UND den Menü-Button aufgerufen
    @objc func openPreferences(_ sender: Any?) {
        openPreferencesWithSettings()
    }
    
    // Öffentliche Methoden für verschiedene Tabs
    func openPreferencesWithDetails() {
        openPreferencesWithTab(.chronik)
    }
    
    func openPreferencesWithAnalyse() {
        openPreferencesWithTab(.analyse)
    }
    
    func openPreferencesWithSettings() {
        openPreferencesWithTab(.settings)
    }
    
    // Private Hilfsmethode
    private func openPreferencesWithTab(_ tab: PrefsTab) {
        // Fenster schließen falls bereits offen (verhindert Duplikate)
        prefsWindowController?.close()
        prefsWindowController = nil
        
        // Neues Fenster erstellen
        prefsWindowController = PreferencesWindowController(timeModel: timeModel)
        
        // Tab setzen vor dem Anzeigen
        prefsWindowController?.setSelectedTab(tab)
        prefsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        // Fenster in den Vordergrund bringen
        prefsWindowController?.window?.makeKeyAndOrderFront(nil)
    }
}
