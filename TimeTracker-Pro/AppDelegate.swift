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

        // Optional: lege ein Main Menu an, damit Cmd-, zuverlässig funktioniert
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

        let prefsItem = NSMenuItem(title: "Einstellungen…", action: #selector(openPreferences(_:)), keyEquivalent: ",")
        prefsItem.target = self
        appMenu.addItem(prefsItem)

        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit \(appName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        appMenuItem.submenu = appMenu
    }

    @objc func openPreferences(_ sender: Any?) {
        if prefsWindowController == nil {
            prefsWindowController = PreferencesWindowController(timeModel: timeModel)
        }
        prefsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
