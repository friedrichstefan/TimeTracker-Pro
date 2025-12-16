//
//  WidgetModels.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 16.12.25.
//

import Foundation
import SwiftUI

// MARK: - Widget Timer Data

struct WidgetTimerData: Codable {
    let workSeconds: Int
    let coffeeSeconds: Int
    let lunchSeconds: Int
    let isTimerRunning: Bool
    let activeCategory: TimerCategory?
    let targetWorkHours: Double
    let todayWorkSeconds: Int
    let lastUpdate: Date
    
    init(
        workSeconds: Int = 0,
        coffeeSeconds: Int = 0,
        lunchSeconds: Int = 0,
        isTimerRunning: Bool = false,
        activeCategory: TimerCategory? = nil,
        targetWorkHours: Double = 8.0,
        todayWorkSeconds: Int = 0,
        lastUpdate: Date = Date()
    ) {
        self.workSeconds = workSeconds
        self.coffeeSeconds = coffeeSeconds
        self.lunchSeconds = lunchSeconds
        self.isTimerRunning = isTimerRunning
        self.activeCategory = activeCategory
        self.targetWorkHours = targetWorkHours
        self.todayWorkSeconds = todayWorkSeconds
        self.lastUpdate = lastUpdate
    }
    
    var workProgress: Double {
        guard targetWorkHours > 0 else { return 0 }
        return min(1.0, Double(todayWorkSeconds) / (targetWorkHours * 3600))
    }
}

// MARK: - Widget Data Manager

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let suiteName = "group.stefan.timetracker.pro"
    private let dataKey = "widget_timer_data"
    
    // WICHTIG: UserDefaults als lazy property
    private lazy var sharedDefaults: UserDefaults? = {
        return UserDefaults(suiteName: suiteName)
    }()
    
    private init() {}
    
    func saveTimerData(_ data: WidgetTimerData) {
        guard let userDefaults = sharedDefaults else {
            print("❌ Widget: App Group '\(suiteName)' nicht verfügbar")
            return
        }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: dataKey)
            userDefaults.synchronize()
            print("✅ Widget: Daten gespeichert für Gruppe '\(suiteName)'")
        } catch {
            print("❌ Widget: Fehler beim Speichern - \(error)")
        }
    }
    
    func loadTimerData() -> WidgetTimerData {
        guard let userDefaults = sharedDefaults else {
            print("❌ Widget: App Group '\(suiteName)' nicht verfügbar - Verwende Fallback")
            return createFallbackData()
        }
        
        guard let data = userDefaults.data(forKey: dataKey) else {
            print("ℹ️ Widget: Keine gespeicherten Daten in App Group - Verwende Fallback")
            return createFallbackData()
        }
        
        do {
            let decoded = try JSONDecoder().decode(WidgetTimerData.self, from: data)
            print("✅ Widget: Daten erfolgreich aus App Group geladen")
            return decoded
        } catch {
            print("❌ Widget: Fehler beim Dekodieren - \(error) - Verwende Fallback")
            return createFallbackData()
        }
    }
    
    // Fallback-Daten wenn App Group nicht funktioniert
    private func createFallbackData() -> WidgetTimerData {
        return WidgetTimerData(
            workSeconds: 0,
            coffeeSeconds: 0,
            lunchSeconds: 0,
            isTimerRunning: false,
            activeCategory: nil,
            targetWorkHours: 8.0,
            todayWorkSeconds: 0,
            lastUpdate: Date()
        )
    }
    
    // Debug-Funktion
    func debugAppGroup() {
        if let userDefaults = sharedDefaults {
            userDefaults.set("test_\(Date().timeIntervalSince1970)", forKey: "debug_test")
            let success = userDefaults.synchronize()
            print("🐛 App Group Debug: \(success ? "✅ Funktioniert" : "❌ Fehler")")
            
            if let testValue = userDefaults.string(forKey: "debug_test") {
                print("🐛 Geschriebener Wert: \(testValue)")
            }
        } else {
            print("🐛 App Group Debug: UserDefaults ist nil")
        }
    }
}
