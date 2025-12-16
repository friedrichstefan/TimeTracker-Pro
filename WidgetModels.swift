//
//  WidgetModels.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 16.12.25.
//

import Foundation
import SwiftUI

// MARK: - Widget Timer Category

public enum WidgetTimerCategory: String, CaseIterable, Codable {
    case work = "work"
    case coffee = "coffee"
    case lunch = "lunch"
    
    public var displayName: String {
        switch self {
        case .work: return "Arbeit"
        case .coffee: return "Kaffee"
        case .lunch: return "Mittag"
        }
    }
    
    public var symbol: String {
        switch self {
        case .work: return "💼"
        case .coffee: return "☕️"
        case .lunch: return "🍽️"
        }
    }
    
    public var color: Color {
        switch self {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
}

// MARK: - Widget Timer Data

public struct WidgetTimerData: Codable {
    public let workSeconds: Int
    public let coffeeSeconds: Int
    public let lunchSeconds: Int
    public let isTimerRunning: Bool
    public let activeCategory: WidgetTimerCategory?
    public let targetWorkHours: Int
    public let todayWorkSeconds: Int
    public let lastUpdate: Date
    
    public init(
        workSeconds: Int = 0,
        coffeeSeconds: Int = 0,
        lunchSeconds: Int = 0,
        isTimerRunning: Bool = false,
        activeCategory: WidgetTimerCategory? = nil,
        targetWorkHours: Int = 8,
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
    
    public var workProgress: Double {
        guard targetWorkHours > 0 else { return 0 }
        return min(1.0, Double(todayWorkSeconds) / Double(targetWorkHours * 3600))
    }
}

// MARK: - Widget Data Manager

public class WidgetDataManager {
    public static let shared = WidgetDataManager()
    
    private let suiteName = "group.stefan.timetracker.pro"
    private let dataKey = "widget_timer_data"
    
    private init() {}
    
    public func saveTimerData(_ data: WidgetTimerData) {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            print("❌ Widget: App Group nicht verfügbar")
            return
        }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: dataKey)
            userDefaults.synchronize()
            print("✅ Widget: Daten gespeichert")
        } catch {
            print("❌ Widget: Fehler beim Speichern - \(error)")
        }
    }
    
    public func loadTimerData() -> WidgetTimerData {
        guard let userDefaults = UserDefaults(suiteName: suiteName),
              let data = userDefaults.data(forKey: dataKey) else {
            return WidgetTimerData()
        }
        
        do {
            let decoded = try JSONDecoder().decode(WidgetTimerData.self, from: data)
            return decoded
        } catch {
            return WidgetTimerData()
        }
    }
}
