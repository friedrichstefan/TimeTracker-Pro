//
//  TimeModel.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import Foundation
import Combine
import AppKit
import UniformTypeIdentifiers
import UserNotifications
import WidgetKit

final class TimeModel: ObservableObject {
    // MARK: - Clock Properties
    @Published var date: Date = Date()
    @Published var timeString: String = ""
    @Published var showSeconds: Bool {
        didSet { UserDefaults.standard.set(showSeconds, forKey: UserDefaultsKeys.showSeconds) }
    }
    @Published var use24Hour: Bool {
        didSet { UserDefaults.standard.set(use24Hour, forKey: UserDefaultsKeys.use24Hour) }
    }
    @Published var showDate: Bool {
        didSet { UserDefaults.standard.set(showDate, forKey: UserDefaultsKeys.showDate) }
    }
    @Published var largeClockFontSize: Double {
        didSet { UserDefaults.standard.set(largeClockFontSize, forKey: UserDefaultsKeys.largeClockFontSize) }
    }
    
    // MARK: - Timer Properties
    @Published var workSeconds: Int = 0
    @Published var coffeeSeconds: Int = 0
    @Published var lunchSeconds: Int = 0
    @Published var activeCategory: TimerCategory? = nil
    @Published var isTimerRunning: Bool = false
    
    // MARK: - Session Management
    @Published var timerSessions: [TimerSession] = []
    private var currentSession: TimerSession?
    
    // MARK: - Settings Properties
    @Published var isAppTrackingEnabled: Bool {
        didSet { UserDefaults.standard.set(isAppTrackingEnabled, forKey: UserDefaultsKeys.isAppTrackingEnabled) }
    }
    @Published var targetWorkHours: Int {
        didSet { UserDefaults.standard.set(targetWorkHours, forKey: UserDefaultsKeys.targetWorkHours) }
    }
    @Published var workStartTime: Date {
        didSet { UserDefaults.standard.set(workStartTime, forKey: UserDefaultsKeys.workStartTime) }
    }
    @Published var workEndTime: Date {
        didSet { UserDefaults.standard.set(workEndTime, forKey: UserDefaultsKeys.workEndTime) }
    }
    @Published var includeWeekends: Bool {
        didSet { UserDefaults.standard.set(includeWeekends, forKey: UserDefaultsKeys.includeWeekends) }
    }
    @Published var autoStopOnInactivity: Bool {
        didSet { UserDefaults.standard.set(autoStopOnInactivity, forKey: UserDefaultsKeys.autoStopOnInactivity) }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: UserDefaultsKeys.notificationsEnabled) }
    }
    @Published var breakReminderInterval: Int {
        didSet { UserDefaults.standard.set(breakReminderInterval, forKey: UserDefaultsKeys.breakReminderInterval) }
    }
    @Published var trackOnlyProductiveApps: Bool {
        didSet { UserDefaults.standard.set(trackOnlyProductiveApps, forKey: UserDefaultsKeys.trackOnlyProductiveApps) }
    }
    @Published var warnUnproductiveApps: Bool {
        didSet { UserDefaults.standard.set(warnUnproductiveApps, forKey: UserDefaultsKeys.warnUnproductiveApps) }
    }
    @Published var dataRetentionDays: Int {
        didSet { UserDefaults.standard.set(dataRetentionDays, forKey: UserDefaultsKeys.dataRetentionDays) }
    }
    @Published var workTimeMonitoringEnabled: Bool {
        didSet {
            UserDefaults.standard.set(workTimeMonitoringEnabled, forKey: UserDefaultsKeys.workTimeMonitoringEnabled)
            if !workTimeMonitoringEnabled {
                workTimeCheckTimer?.invalidate()
                workTimeCheckTimer = nil
            } else {
                startWorkTimeMonitoring()
            }
        }
    }
    @Published var showWorkProgressInStatusBar: Bool {
        didSet { UserDefaults.standard.set(showWorkProgressInStatusBar, forKey: UserDefaultsKeys.showWorkProgressInStatusBar) }
    }
    
    // MARK: - Auto Pause Properties
    @Published var systemStateMonitor = SystemStateMonitor()
    @Published var enableAutoPause: Bool {
        didSet {
            UserDefaults.standard.set(enableAutoPause, forKey: UserDefaultsKeys.enableAutoPause)
            updateSystemMonitoringCallbacks()
        }
    }
    @Published var onlyDuringWorkHours: Bool {
        didSet { UserDefaults.standard.set(onlyDuringWorkHours, forKey: UserDefaultsKeys.onlyDuringWorkHours) }
    }
    @Published var minimumPauseDurationSeconds: Int {
        didSet { UserDefaults.standard.set(minimumPauseDurationSeconds, forKey: UserDefaultsKeys.minimumPauseDurationSeconds) }
    }
    @Published var lunchThresholdMinutes: Int {
        didSet { UserDefaults.standard.set(lunchThresholdMinutes, forKey: UserDefaultsKeys.lunchThresholdMinutes) }
    }
    @Published var askBeforeResuming: Bool {
        didSet { UserDefaults.standard.set(askBeforeResuming, forKey: UserDefaultsKeys.askBeforeResuming) }
    }
    @Published var pauseOutsideWorkHours: Bool {
        didSet { UserDefaults.standard.set(pauseOutsideWorkHours, forKey: UserDefaultsKeys.pauseOutsideWorkHours) }
    }
    @Published var askToResumeAfterPause: Bool {
        didSet { UserDefaults.standard.set(askToResumeAfterPause, forKey: UserDefaultsKeys.askToResumeAfterPause) }
    }
    
    // MARK: - Private Properties
    private var appTrackingTimer: Timer?
    private var currentAppUsages: [String: (String, Int)] = [:]
    private var lastActiveApp: String = ""
    private var workTimeCheckTimer: Timer?
    private var lastWorkTimeNotification: Date?
    private var wasWorkingBeforeLock = false
    private var lockStartSeconds: [TimerCategory: Int] = [:]
    private var isAutomaticAction = false
    private var wasWorkTimerStoppedByLock = false
    private var pausedOutsideWorkHours = false
    private var clockTimer: Timer?
    private var countdownTimer: Timer?
    private var formatter = DateFormatter()

    // MARK: - Initialization
    
    init() {
        let defaults = UserDefaults.standard
        defaults.setDefaultsIfNeeded()

        // Load values
        showSeconds = defaults.bool(forKey: UserDefaultsKeys.showSeconds)
        use24Hour = defaults.bool(forKey: UserDefaultsKeys.use24Hour)
        showDate = defaults.bool(forKey: UserDefaultsKeys.showDate)
        isAppTrackingEnabled = defaults.bool(forKey: UserDefaultsKeys.isAppTrackingEnabled)
        
        let savedSize = defaults.double(forKey: UserDefaultsKeys.largeClockFontSize)
        largeClockFontSize = savedSize > 0 ? savedSize : 36.0
        
        // Load work settings
        targetWorkHours = defaults.integer(forKey: UserDefaultsKeys.targetWorkHours)
        workStartTime = defaults.object(forKey: UserDefaultsKeys.workStartTime) as? Date ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        workEndTime = defaults.object(forKey: UserDefaultsKeys.workEndTime) as? Date ?? Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
        includeWeekends = defaults.bool(forKey: UserDefaultsKeys.includeWeekends)
        autoStopOnInactivity = defaults.bool(forKey: UserDefaultsKeys.autoStopOnInactivity)
        notificationsEnabled = defaults.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        breakReminderInterval = defaults.integer(forKey: UserDefaultsKeys.breakReminderInterval)
        trackOnlyProductiveApps = defaults.bool(forKey: UserDefaultsKeys.trackOnlyProductiveApps)
        warnUnproductiveApps = defaults.bool(forKey: UserDefaultsKeys.warnUnproductiveApps)
        dataRetentionDays = defaults.integer(forKey: UserDefaultsKeys.dataRetentionDays)
        workTimeMonitoringEnabled = defaults.bool(forKey: UserDefaultsKeys.workTimeMonitoringEnabled)
        showWorkProgressInStatusBar = defaults.bool(forKey: UserDefaultsKeys.showWorkProgressInStatusBar)
        
        // Load auto pause settings
        enableAutoPause = defaults.bool(forKey: UserDefaultsKeys.enableAutoPause)
        onlyDuringWorkHours = defaults.bool(forKey: UserDefaultsKeys.onlyDuringWorkHours)
        minimumPauseDurationSeconds = defaults.integer(forKey: UserDefaultsKeys.minimumPauseDurationSeconds)
        lunchThresholdMinutes = defaults.integer(forKey: UserDefaultsKeys.lunchThresholdMinutes)
        askBeforeResuming = defaults.bool(forKey: UserDefaultsKeys.askBeforeResuming)
        pauseOutsideWorkHours = defaults.bool(forKey: UserDefaultsKeys.pauseOutsideWorkHours)
        askToResumeAfterPause = defaults.bool(forKey: UserDefaultsKeys.askToResumeAfterPause)

        // Load timer times
        workSeconds = defaults.integer(forKey: UserDefaultsKeys.workSeconds)
        coffeeSeconds = defaults.integer(forKey: UserDefaultsKeys.coffeeSeconds)
        lunchSeconds = defaults.integer(forKey: UserDefaultsKeys.lunchSeconds)
        
        loadTimerSessions()
        setupFormatter()
        startClockTimer()
        requestNotificationPermission()
        
        if workTimeMonitoringEnabled {
            startWorkTimeMonitoring()
        }
        
        updateSystemMonitoringCallbacks()
    }

    deinit {
        clockTimer?.invalidate()
        countdownTimer?.invalidate()
        appTrackingTimer?.invalidate()
        workTimeCheckTimer?.invalidate()
    }
}

// MARK: - Timer Functions

extension TimeModel {
    func startTimer(for category: TimerCategory) {
        stopTimer()
        activeCategory = category
        isTimerRunning = true
        
        currentSession = TimerSession(
            category: category,
            startTime: Date(),
            endTime: nil,
            duration: 0
        )
        
        if isAppTrackingEnabled && category == .work {
            startAppTracking()
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch category {
                case .work:
                    self.workSeconds += 1
                    UserDefaults.standard.set(self.workSeconds, forKey: UserDefaultsKeys.workSeconds)
                case .coffee:
                    self.coffeeSeconds += 1
                    UserDefaults.standard.set(self.coffeeSeconds, forKey: UserDefaultsKeys.coffeeSeconds)
                case .lunch:
                    self.lunchSeconds += 1
                    UserDefaults.standard.set(self.lunchSeconds, forKey: UserDefaultsKeys.lunchSeconds)
                }
            }
        }
        RunLoop.current.add(countdownTimer!, forMode: .common)
        
        // Widget Update
        DispatchQueue.main.async {
            self.updateWidgetData()
        }
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
        
        stopAppTracking()
        isTimerRunning = false
        activeCategory = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        let endTime = Date()
        let duration = Int(endTime.timeIntervalSince(session.startTime))
        
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
        
        timerSessions.insert(completedSession, at: 0)
        currentSession = nil
        currentAppUsages.removeAll()
        saveTimerSessions()
        
        // Widget Update
        DispatchQueue.main.async {
            self.updateWidgetData()
        }
        
    }
    
    func resetAllTimers() {
        stopTimer()
        workSeconds = 0
        coffeeSeconds = 0
        lunchSeconds = 0
        
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.workSeconds)
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.coffeeSeconds)
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.lunchSeconds)
        
        // Widget Update
        DispatchQueue.main.async {
            self.updateWidgetData()
        }
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
}

// MARK: - Data Management

extension TimeModel {
    func getSessionsForDate(_ date: Date) -> [TimerSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return timerSessions.filter { session in
            session.startTime >= startOfDay && session.startTime < endOfDay
        }.sorted { $0.startTime > $1.startTime }
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
}

// MARK: - Export Functions

extension TimeModel {
    func exportToCSV() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.commaSeparatedText]
        panel.nameFieldStringValue = "timetracker_export.csv"
        
        if panel.runModal() == .OK, let url = panel.url {
            let csvContent = generateCSVContent()
            try? csvContent.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    func exportToJSON() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "timetracker_export.json"
        
        if panel.runModal() == .OK, let url = panel.url {
            if let jsonData = try? JSONEncoder().encode(timerSessions),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                try? jsonString.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }

    private func generateCSVContent() -> String {
        var content = "Datum,Startzeit,Endzeit,Kategorie,Dauer (Min),App-Name,App-Dauer (Min)\n"
        
        for session in timerSessions {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            let date = dateFormatter.string(from: session.startTime).components(separatedBy: " ")[0]
            let startTime = dateFormatter.string(from: session.startTime).components(separatedBy: " ")[1]
            let endTime = session.endTime.map { dateFormatter.string(from: $0).components(separatedBy: " ")[1] } ?? "läuft"
            
            if session.appUsages.isEmpty {
                content += "\(date),\(startTime),\(endTime),\(session.category.displayName),\(session.duration/60),,\n"
            } else {
                for appUsage in session.appUsages {
                    content += "\(date),\(startTime),\(endTime),\(session.category.displayName),\(session.duration/60),\(appUsage.appName),\(appUsage.duration/60)\n"
                }
            }
        }
        
        return content
    }
}

// MARK: - Notification Methods

extension TimeModel {
    func resumeWorkFromNotification() {
        print("Resuming work from notification")
        startTimer(for: .work)
    }
    
    func dismissResumeRequest() {
        print("User dismissed resume request")
    }
}

// MARK: - Widget Integration
extension TimeModel {
    func updateWidgetData() {
        let widgetData = WidgetTimerData(
            workSeconds: workSeconds,
            coffeeSeconds: coffeeSeconds,
            lunchSeconds: lunchSeconds,
            isTimerRunning: isTimerRunning,
            activeCategory: activeCategory,  // Direktes activeCategory verwenden (kein Convert nötig)
            targetWorkHours: Double(targetWorkHours),
            todayWorkSeconds: getWorkTimeForDate(Date()),
            lastUpdate: Date()
        )
        
        WidgetDataManager.shared.saveTimerData(widgetData)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
// MARK: - Private Helper Methods

private extension TimeModel {
    func loadTimerSessions() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.timerSessions),
              let sessions = try? JSONDecoder().decode([TimerSession].self, from: data) else {
            timerSessions = []
            return
        }
        timerSessions = sessions
    }
    
    func saveTimerSessions() {
        guard let data = try? JSONEncoder().encode(timerSessions) else { return }
        UserDefaults.standard.set(data, forKey: UserDefaultsKeys.timerSessions)
    }
    
    func setupFormatter() {
        formatter.locale = Locale.current
    }

    func startClockTimer() {
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.date = Date()
            }
        }
        RunLoop.current.add(clockTimer!, forMode: .common)
    }
    
    // App Tracking
    func startAppTracking() {
        currentAppUsages.removeAll()
        lastActiveApp = ""
        appTrackingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.trackCurrentApp()
        }
        RunLoop.current.add(appTrackingTimer!, forMode: .common)
    }
    
    func stopAppTracking() {
        appTrackingTimer?.invalidate()
        appTrackingTimer = nil
    }
    
    func trackCurrentApp() {
        guard let activeApp = NSWorkspace.shared.frontmostApplication else { return }
        guard let bundleID = activeApp.bundleIdentifier else { return }
        
        let appName = activeApp.localizedName ?? "Unbekannt"
        let current = currentAppUsages[bundleID] ?? (appName, 0)
        currentAppUsages[bundleID] = (current.0, current.1 + 5)
        lastActiveApp = bundleID
    }
    
    // Notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Benachrichtigungen erlaubt")
            }
        }
    }
    
    func startWorkTimeMonitoring() {
        workTimeCheckTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkWorkTimeProgress()
        }
        RunLoop.current.add(workTimeCheckTimer!, forMode: .common)
    }
    
    func checkWorkTimeProgress() {
        guard notificationsEnabled && workTimeMonitoringEnabled else { return }
        
        let todayWorkTime = getWorkTimeForDate(Date())
        let targetWorkTime = targetWorkHours * 3600
        let progress = Double(todayWorkTime) / Double(targetWorkTime)
        
        // Simplified notification logic - kann erweitert werden
        if progress >= 1.0 && !hasNotificationBeenSentToday("goal_reached") {
            sendNotification(
                title: "Arbeitsziel erreicht!",
                body: "Du hast heute bereits \(targetWorkHours) Stunden gearbeitet.",
                identifier: "goal_reached"
            )
        }
    }
    
    func sendNotification(title: String, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
        markNotificationAsSentToday(identifier)
    }
    
    func hasNotificationBeenSentToday(_ identifier: String) -> Bool {
        let key = "notification_\(identifier)_\(Date().todayDateKey())"
        return UserDefaults.standard.bool(forKey: key)
    }
    
    func markNotificationAsSentToday(_ identifier: String) {
        let key = "notification_\(identifier)_\(Date().todayDateKey())"
        UserDefaults.standard.set(true, forKey: key)
    }
    
    // System Monitoring
    func updateSystemMonitoringCallbacks() {
        systemStateMonitor.onSystemLocked = { [weak self] in
            DispatchQueue.main.async {
                self?.handleSystemLocked()
            }
        }
        
        systemStateMonitor.onSystemUnlocked = { [weak self] duration, reason in
            DispatchQueue.main.async {
                self?.handleSystemUnlocked(duration: duration, reason: reason)
            }
        }
    }
    
    func handleSystemLocked() {
        // Vereinfachte Auto-Pause-Logik - kann erweitert werden
        let inWorkHours = isCurrentlyInWorkHours()
        let isWorkTimerRunning = (activeCategory == .work && isTimerRunning)
        
        if inWorkHours && enableAutoPause && isTimerRunning {
            stopTimer()
            wasWorkingBeforeLock = true
        } else if !inWorkHours && pauseOutsideWorkHours && isWorkTimerRunning {
            pausedOutsideWorkHours = true
        }
    }
    
    func handleSystemUnlocked(duration: TimeInterval, reason: AutoPauseReason) {
        if wasWorkingBeforeLock && enableAutoPause {
            // Auto resume logic hier
            if reason == .ignored {
                startTimer(for: .work)
            }
        }
        
        // Reset flags
        wasWorkingBeforeLock = false
        pausedOutsideWorkHours = false
    }
    
    func isCurrentlyInWorkHours() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        
        let weekday = calendar.component(.weekday, from: now)
        let isWeekend = weekday == 1 || weekday == 7
        let isWorkDay = includeWeekends ? true : !isWeekend
        
        guard isWorkDay else { return false }
        
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        
        let startHour = calendar.component(.hour, from: workStartTime)
        let startMinute = calendar.component(.minute, from: workStartTime)
        let startTimeInMinutes = startHour * 60 + startMinute
        
        let endHour = calendar.component(.hour, from: workEndTime)
        let endMinute = calendar.component(.minute, from: workEndTime)
        let endTimeInMinutes = endHour * 60 + endMinute
        
        return currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes <= endTimeInMinutes
    }
}
