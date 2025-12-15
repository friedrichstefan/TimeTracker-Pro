//
//  SystemStateMonitor.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import Foundation
import Combine
import AppKit

final class SystemStateMonitor: ObservableObject {
    @Published var isLocked = false
    @Published var lockStartTime: Date?
    
    // Callbacks für Timer-Integration
    var onSystemLocked: (() -> Void)?
    var onSystemUnlocked: ((TimeInterval, AutoPauseReason) -> Void)?
    
    private let notificationCenter = DistributedNotificationCenter.default
    private let workspaceCenter = NSWorkspace.shared.notificationCenter
    
    // WICHTIG: Minimale Schwellwerte hier definieren
    private let minimumLockDuration: TimeInterval = 10 // 10 Sekunden
    private let lunchThreshold: TimeInterval = 10 * 60 // 10 Minuten
    
    init() {
        setupSystemMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    private func setupSystemMonitoring() {
        // Screen Lock/Unlock
        notificationCenter.addObserver(
            self,
            selector: #selector(screenLocked),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(screenUnlocked),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
        
        // Sleep/Wake (für geschlossenen Laptop)
        workspaceCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        
        workspaceCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        // Screensaver
        notificationCenter.addObserver(
            self,
            selector: #selector(screensaverStarted),
            name: NSNotification.Name("com.apple.screensaver.didstart"),
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(screensaverStopped),
            name: NSNotification.Name("com.apple.screensaver.didstop"),
            object: nil
        )
    }
    
    @objc private func screenLocked() {
        handleSystemLocked(reason: "Screen locked")
    }
    
    @objc private func systemWillSleep() {
        handleSystemLocked(reason: "System sleeping")
    }
    
    @objc private func screensaverStarted() {
        handleSystemLocked(reason: "Screensaver started")
    }
    
    @objc private func screenUnlocked() {
        handleSystemUnlocked(reason: "Screen unlocked")
    }
    
    @objc private func systemDidWake() {
        handleSystemUnlocked(reason: "System woke up")
    }
    
    @objc private func screensaverStopped() {
        handleSystemUnlocked(reason: "Screensaver stopped")
    }
    
    private func handleSystemLocked(reason: String) {
        print("System locked: \(reason)")
        guard !isLocked else { return }
        
        // Publishing-Changes vermeiden durch dispatch
        DispatchQueue.main.async { [weak self] in
            self?.isLocked = true
            self?.lockStartTime = Date()
        }
        
        // Callback nach einem kurzen Delay um Publishing-Konflikte zu vermeiden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.onSystemLocked?()
        }
    }
    
    private func handleSystemUnlocked(reason: String) {
        print("System unlocked: \(reason)")
        guard isLocked, let startTime = lockStartTime else { return }
        
        let duration = Date().timeIntervalSince(startTime)
        print("System was locked for: \(duration) seconds")
        
        // Bestimme Pause-Grund basierend auf Dauer
        let pauseReason: AutoPauseReason
        if duration < minimumLockDuration {
            pauseReason = .ignored
        } else if duration < lunchThreshold {
            pauseReason = .coffee
        } else {
            pauseReason = .lunch
        }
        
        // Publishing-Changes vermeiden durch dispatch
        DispatchQueue.main.async { [weak self] in
            self?.isLocked = false
            self?.lockStartTime = nil
        }
        
        // Callback nach einem kurzen Delay um Publishing-Konflikte zu vermeiden
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.onSystemUnlocked?(duration, pauseReason)
        }
    }
    
    private func stopMonitoring() {
        notificationCenter.removeObserver(self)
        workspaceCenter.removeObserver(self)
    }
    
    var currentLockDuration: TimeInterval? {
        guard isLocked, let startTime = lockStartTime else { return nil }
        return Date().timeIntervalSince(startTime)
    }
}
