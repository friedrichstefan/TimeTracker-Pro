//
//  TimeModel.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import Foundation
import Combine
import AppKit

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
    
    var color: String {
        switch self {
        case .work: return "blue"
        case .coffee: return "orange"
        case .lunch: return "green"
        }
    }
}

struct AppUsage: Identifiable, Codable {
    let id = UUID()
    let bundleID: String
    let appName: String
    let duration: Int // in Sekunden
    let category: TimerCategory
    let date: Date
    
    // Custom initializer für UUID-Problem
    init(bundleID: String, appName: String, duration: Int, category: TimerCategory, date: Date) {
        self.bundleID = bundleID
        self.appName = appName
        self.duration = duration
        self.category = category
        self.date = date
    }
}

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

final class TimeModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var timeString: String = ""
    @Published var showSeconds: Bool {
        didSet { UserDefaults.standard.set(showSeconds, forKey: Keys.showSeconds) }
    }
    @Published var use24Hour: Bool {
        didSet { UserDefaults.standard.set(use24Hour, forKey: Keys.use24Hour) }
    }
    @Published var showDate: Bool {
        didSet { UserDefaults.standard.set(showDate, forKey: Keys.showDate) }
    }
    @Published var largeClockFontSize: Double {
        didSet { UserDefaults.standard.set(largeClockFontSize, forKey: Keys.largeClockFontSize) }
    }
    
    // Timer-spezifische Eigenschaften
    @Published var workSeconds: Int = 0
    @Published var coffeeSeconds: Int = 0
    @Published var lunchSeconds: Int = 0
    @Published var activeCategory: TimerCategory? = nil
    @Published var isTimerRunning: Bool = false
    
    // Chronik
    @Published var timerSessions: [TimerSession] = []
    private var currentSession: TimerSession?
    
    // App-Tracking - NEU
    @Published var isAppTrackingEnabled: Bool {
        didSet { UserDefaults.standard.set(isAppTrackingEnabled, forKey: Keys.isAppTrackingEnabled) }
    }
    
    private var appTrackingTimer: Timer?
    private var currentAppUsages: [String: (String, Int)] = [:] // bundleID: (appName, duration)
    private var lastActiveApp: String = ""

    private var clockTimer: Timer?
    private var countdownTimer: Timer?
    private var formatter = DateFormatter()

    private enum Keys {
        static let showSeconds = "TimeTracker_ShowSeconds"
        static let use24Hour = "TimeTracker_Use24Hour"
        static let showDate = "TimeTracker_ShowDate"
        static let largeClockFontSize = "TimeTracker_LargeClockFontSize"
        static let workSeconds = "TimeTracker_WorkSeconds"
        static let coffeeSeconds = "TimeTracker_CoffeeSeconds"
        static let lunchSeconds = "TimeTracker_LunchSeconds"
        static let timerSessions = "TimeTracker_TimerSessions"
        static let isAppTrackingEnabled = "TimeTracker_IsAppTrackingEnabled"
    }

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.showSeconds) == nil { defaults.set(true, forKey: Keys.showSeconds) }
        if defaults.object(forKey: Keys.use24Hour) == nil { defaults.set(false, forKey: Keys.use24Hour) }
        if defaults.object(forKey: Keys.showDate) == nil { defaults.set(false, forKey: Keys.showDate) }
        if defaults.object(forKey: Keys.largeClockFontSize) == nil { defaults.set(36.0, forKey: Keys.largeClockFontSize) }
        if defaults.object(forKey: Keys.isAppTrackingEnabled) == nil { defaults.set(false, forKey: Keys.isAppTrackingEnabled) }

        showSeconds = defaults.bool(forKey: Keys.showSeconds)
        use24Hour = defaults.bool(forKey: Keys.use24Hour)
        showDate = defaults.bool(forKey: Keys.showDate)
        isAppTrackingEnabled = defaults.bool(forKey: Keys.isAppTrackingEnabled)

        let savedSize = defaults.double(forKey: Keys.largeClockFontSize)
        largeClockFontSize = savedSize > 0 ? savedSize : 36.0

        // Lade gespeicherte Timer-Zeiten
        workSeconds = defaults.integer(forKey: Keys.workSeconds)
        coffeeSeconds = defaults.integer(forKey: Keys.coffeeSeconds)
        lunchSeconds = defaults.integer(forKey: Keys.lunchSeconds)
        
        // Lade Timer-Sessions
        loadTimerSessions()

        setupFormatter()
        startClockTimer()
    }

    deinit {
        clockTimer?.invalidate()
        countdownTimer?.invalidate()
        appTrackingTimer?.invalidate()
    }

    // Timer-Funktionen - ERWEITERT
    func startTimer(for category: TimerCategory) {
        stopTimer() // Stoppe aktuellen Timer falls läuft
        activeCategory = category
        isTimerRunning = true
        
        currentSession = TimerSession(
            category: category,
            startTime: Date(),
            endTime: nil,
            duration: 0
        )
        
        // App-Tracking starten - NUR für Arbeit
        if isAppTrackingEnabled && category == .work {
            startAppTracking()
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch category {
                case .work:
                    self.workSeconds += 1
                    UserDefaults.standard.set(self.workSeconds, forKey: Keys.workSeconds)
                case .coffee:
                    self.coffeeSeconds += 1
                    UserDefaults.standard.set(self.coffeeSeconds, forKey: Keys.coffeeSeconds)
                case .lunch:
                    self.lunchSeconds += 1
                    UserDefaults.standard.set(self.lunchSeconds, forKey: Keys.lunchSeconds)
                }
            }
        }
        RunLoop.current.add(countdownTimer!, forMode: .common)
    }
    
    func stopTimer() {
        guard let session = currentSession else {
            isTimerRunning = false
            activeCategory = nil
            countdownTimer?.invalidate()
            countdownTimer = nil
            stopAppTracking()
            return
        }
        
        // App-Tracking stoppen
        stopAppTracking()
        
        isTimerRunning = false
        activeCategory = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        let endTime = Date()
        let duration = Int(endTime.timeIntervalSince(session.startTime))
        
        // App-Usages hinzufügen
        let appUsages = currentAppUsages.map { (bundleID, data) in
            AppUsage(
                bundleID: bundleID,
                appName: data.0,
                duration: data.1,
                category: session.category,
                date: session.startTime
            )
        }
        
        let completedSession = TimerSession(
            category: session.category,
            startTime: session.startTime,
            endTime: endTime,
            duration: duration,
            appUsages: appUsages
        )
        
        timerSessions.insert(completedSession, at: 0) // Neueste zuerst
        currentSession = nil
        currentAppUsages.removeAll()
        
        saveTimerSessions()
    }
    
    func resetAllTimers() {
        stopTimer()
        workSeconds = 0
        coffeeSeconds = 0
        lunchSeconds = 0
        
        UserDefaults.standard.set(0, forKey: Keys.workSeconds)
        UserDefaults.standard.set(0, forKey: Keys.coffeeSeconds)
        UserDefaults.standard.set(0, forKey: Keys.lunchSeconds)
    }
    
    func getCurrentTimerSeconds() -> Int {
        guard let category = activeCategory else {
            return max(workSeconds, coffeeSeconds, lunchSeconds)
        }
        
        switch category {
        case .work: return workSeconds
        case .coffee: return coffeeSeconds
        case .lunch: return lunchSeconds
        }
    }
    
    // App-Tracking Funktionen - NEU
    private func startAppTracking() {
        currentAppUsages.removeAll()
        lastActiveApp = ""
        appTrackingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.trackCurrentApp()
        }
        RunLoop.current.add(appTrackingTimer!, forMode: .common)
    }
    
    private func stopAppTracking() {
        appTrackingTimer?.invalidate()
        appTrackingTimer = nil
    }
    
    private func trackCurrentApp() {
        guard let activeApp = NSWorkspace.shared.frontmostApplication else { return }
        guard let bundleID = activeApp.bundleIdentifier else { return }
        
        let appName = activeApp.localizedName ?? "Unbekannt"
        
        // App-Zeit hinzufügen (alle 5 Sekunden)
        let current = currentAppUsages[bundleID] ?? (appName, 0)
        currentAppUsages[bundleID] = (current.0, current.1 + 5)
        
        lastActiveApp = bundleID
    }
    
    // Erweiterte Chronik-Funktionen
    func getSessionsForDate(_ date: Date) -> [TimerSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return timerSessions.filter { session in
            session.startTime >= startOfDay && session.startTime < endOfDay
        }.sorted { $0.startTime > $1.startTime } // Neueste zuerst
    }
    
    func getTotalTimeForDate(_ date: Date) -> Int {
        return getSessionsForDate(date).reduce(0) { $0 + $1.duration }
    }
    
    func getWorkTimeForDate(_ date: Date) -> Int {
        return getSessionsForDate(date)
            .filter { $0.category == .work }
            .reduce(0) { $0 + $1.duration }
    }
    
    func getBreakTimeForDate(_ date: Date) -> Int {
        return getSessionsForDate(date)
            .filter { $0.category == .coffee || $0.category == .lunch }
            .reduce(0) { $0 + $1.duration }
    }
    
    func getDaysWithSessions() -> [Date] {
        let calendar = Calendar.current
        let uniqueDays = Set(timerSessions.map { calendar.startOfDay(for: $0.startTime) })
        return Array(uniqueDays).sorted(by: >)
    }
    
    func clearSessionsForDate(_ date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        timerSessions = timerSessions.filter { session in
            !(session.startTime >= startOfDay && session.startTime < endOfDay)
        }
        
        saveTimerSessions()
    }
    
    // Analyse-Funktionen - NEU
    func getAppUsagesForDate(_ date: Date, category: TimerCategory = .work) -> [AppUsage] {
        let sessions = getSessionsForDate(date).filter { $0.category == category }
        return sessions.flatMap { $0.appUsages }
    }
    
    func getAggregatedAppUsagesForDate(_ date: Date, category: TimerCategory = .work) -> [AppUsage] {
        let allUsages = getAppUsagesForDate(date, category: category)
        var aggregated: [String: (String, Int)] = [:]
        
        for usage in allUsages {
            let current = aggregated[usage.bundleID] ?? (usage.appName, 0)
            aggregated[usage.bundleID] = (current.0, current.1 + usage.duration)
        }
        
        return aggregated.map { (bundleID, data) in
            AppUsage(
                bundleID: bundleID,
                appName: data.0,
                duration: data.1,
                category: category,
                date: date
            )
        }.sorted { $0.duration > $1.duration }
    }
    
    // Chronik-Funktionen
    private func loadTimerSessions() {
        guard let data = UserDefaults.standard.data(forKey: Keys.timerSessions),
              let sessions = try? JSONDecoder().decode([TimerSession].self, from: data) else {
            timerSessions = []
            return
        }
        timerSessions = sessions
    }
    
    private func saveTimerSessions() {
        guard let data = try? JSONEncoder().encode(timerSessions) else { return }
        UserDefaults.standard.set(data, forKey: Keys.timerSessions)
    }

    // Uhrzeit-Logik (für interne Views)
    private func setupFormatter() {
        formatter.locale = Locale.current
    }

    private func startClockTimer() {
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.date = Date()
            }
        }
        RunLoop.current.add(clockTimer!, forMode: .common)
    }
}
