//
//  Models.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import Foundation
import SwiftUI

// MARK: - TimerCategory

enum TimerCategory: String, CaseIterable, Codable {
    case work = "work"
    case coffee = "coffee"
    case lunch = "lunch"
    
    var displayName: String {
        switch self {
        case .work: return "Arbeiten"
        case .coffee: return "Kaffeepause"
        case .lunch: return "Mittagessen"
        }
    }
    
    var symbol: String {
        switch self {
        case .work: return "💼"
        case .coffee: return "☕️"
        case .lunch: return "🍽️"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .coffee: return .orange
        case .lunch: return .green
        }
    }
}

// MARK: - AppUsage

struct AppUsage: Identifiable, Codable {
    let id = UUID()
    let bundleID: String
    let appName: String
    let duration: Int // in Sekunden
    let category: TimerCategory
    let date: Date
    
    init(bundleID: String, appName: String, duration: Int, category: TimerCategory, date: Date) {
        self.bundleID = bundleID
        self.appName = appName
        self.duration = duration
        self.category = category
        self.date = date
    }
}

// MARK: - TimerSession

struct TimerSession: Identifiable, Codable {
    let id: UUID
    let category: TimerCategory
    let startTime: Date
    let endTime: Date?
    let duration: Int
    var appUsages: [AppUsage] = []
    
    var isActive: Bool {
        return endTime == nil
    }
    
    init(category: TimerCategory, startTime: Date, endTime: Date?, duration: Int, appUsages: [AppUsage] = []) {
        self.id = UUID()
        self.category = category
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.appUsages = appUsages
    }
}

// MARK: - AutoPause Reason

enum AutoPauseReason {
    case coffee      // Kurze Pause (< Mittagessen-Schwellwert)
    case lunch       // Lange Pause (> Mittagessen-Schwellwert)
    case ignored     // Zu kurz (< Mindestdauer)
}
