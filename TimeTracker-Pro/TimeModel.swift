import Foundation
import Combine
import AppKit
import UniformTypeIdentifiers
import UserNotifications

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
    
    // App-Tracking
    @Published var isAppTrackingEnabled: Bool {
        didSet { UserDefaults.standard.set(isAppTrackingEnabled, forKey: Keys.isAppTrackingEnabled) }
    }
    
    // Arbeitszeit-Einstellungen
    @Published var targetWorkHours: Int {
        didSet { UserDefaults.standard.set(targetWorkHours, forKey: Keys.targetWorkHours) }
    }
    @Published var workStartTime: Date {
        didSet { UserDefaults.standard.set(workStartTime, forKey: Keys.workStartTime) }
    }
    @Published var workEndTime: Date {
        didSet { UserDefaults.standard.set(workEndTime, forKey: Keys.workEndTime) }
    }
    @Published var includeWeekends: Bool {
        didSet { UserDefaults.standard.set(includeWeekends, forKey: Keys.includeWeekends) }
    }

    // Timer-Verhalten
    @Published var autoStopOnInactivity: Bool {
        didSet { UserDefaults.standard.set(autoStopOnInactivity, forKey: Keys.autoStopOnInactivity) }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled) }
    }
    @Published var breakReminderInterval: Int {
        didSet { UserDefaults.standard.set(breakReminderInterval, forKey: Keys.breakReminderInterval) }
    }

    // App-Tracking erweitert
    @Published var trackOnlyProductiveApps: Bool {
        didSet { UserDefaults.standard.set(trackOnlyProductiveApps, forKey: Keys.trackOnlyProductiveApps) }
    }
    @Published var warnUnproductiveApps: Bool {
        didSet { UserDefaults.standard.set(warnUnproductiveApps, forKey: Keys.warnUnproductiveApps) }
    }

    // Daten-Export
    @Published var dataRetentionDays: Int {
        didSet { UserDefaults.standard.set(dataRetentionDays, forKey: Keys.dataRetentionDays) }
    }
    
    @Published var workTimeMonitoringEnabled: Bool {
        didSet {
            UserDefaults.standard.set(workTimeMonitoringEnabled, forKey: Keys.workTimeMonitoringEnabled)
            if !workTimeMonitoringEnabled {
                // Timer stoppen wenn deaktiviert
                workTimeCheckTimer?.invalidate()
                workTimeCheckTimer = nil
            } else {
                // Timer starten wenn aktiviert
                startWorkTimeMonitoring()
            }
        }
    }
    @Published var showWorkProgressInStatusBar: Bool {
        didSet { UserDefaults.standard.set(showWorkProgressInStatusBar, forKey: Keys.showWorkProgressInStatusBar) }
    }
    
    private var appTrackingTimer: Timer?
    private var currentAppUsages: [String: (String, Int)] = [:] // bundleID: (appName, duration)
    private var lastActiveApp: String = ""
    
    // Arbeitszeit-Monitoring
    private var workTimeCheckTimer: Timer?
    private var lastWorkTimeNotification: Date?

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
        
        // Neue Keys
        static let targetWorkHours = "TimeTracker_TargetWorkHours"
        static let workStartTime = "TimeTracker_WorkStartTime"
        static let workEndTime = "TimeTracker_WorkEndTime"
        static let includeWeekends = "TimeTracker_IncludeWeekends"
        static let autoStopOnInactivity = "TimeTracker_AutoStopOnInactivity"
        static let notificationsEnabled = "TimeTracker_NotificationsEnabled"
        static let breakReminderInterval = "TimeTracker_BreakReminderInterval"
        static let trackOnlyProductiveApps = "TimeTracker_TrackOnlyProductiveApps"
        static let warnUnproductiveApps = "TimeTracker_WarnUnproductiveApps"
        static let dataRetentionDays = "TimeTracker_DataRetentionDays"
        
        static let workTimeMonitoringEnabled = "TimeTracker_WorkTimeMonitoringEnabled"
        static let showWorkProgressInStatusBar = "TimeTracker_ShowWorkProgressInStatusBar"
    }

    init() {
        let defaults = UserDefaults.standard
        
        // Standard-Werte setzen
        if defaults.object(forKey: Keys.showSeconds) == nil { defaults.set(true, forKey: Keys.showSeconds) }
        if defaults.object(forKey: Keys.use24Hour) == nil { defaults.set(false, forKey: Keys.use24Hour) }
        if defaults.object(forKey: Keys.showDate) == nil { defaults.set(false, forKey: Keys.showDate) }
        if defaults.object(forKey: Keys.largeClockFontSize) == nil { defaults.set(36.0, forKey: Keys.largeClockFontSize) }
        if defaults.object(forKey: Keys.isAppTrackingEnabled) == nil { defaults.set(false, forKey: Keys.isAppTrackingEnabled) }
        
        // Neue Standard-Werte
        if defaults.object(forKey: Keys.targetWorkHours) == nil { defaults.set(8, forKey: Keys.targetWorkHours) }
        if defaults.object(forKey: Keys.workStartTime) == nil {
            let startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            defaults.set(startTime, forKey: Keys.workStartTime)
        }
        if defaults.object(forKey: Keys.workEndTime) == nil {
            let endTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
            defaults.set(endTime, forKey: Keys.workEndTime)
        }
        if defaults.object(forKey: Keys.includeWeekends) == nil { defaults.set(false, forKey: Keys.includeWeekends) }
        if defaults.object(forKey: Keys.autoStopOnInactivity) == nil { defaults.set(true, forKey: Keys.autoStopOnInactivity) }
        if defaults.object(forKey: Keys.notificationsEnabled) == nil { defaults.set(false, forKey: Keys.notificationsEnabled) }
        if defaults.object(forKey: Keys.breakReminderInterval) == nil { defaults.set(60, forKey: Keys.breakReminderInterval) }
        if defaults.object(forKey: Keys.trackOnlyProductiveApps) == nil { defaults.set(false, forKey: Keys.trackOnlyProductiveApps) }
        if defaults.object(forKey: Keys.warnUnproductiveApps) == nil { defaults.set(false, forKey: Keys.warnUnproductiveApps) }
        if defaults.object(forKey: Keys.dataRetentionDays) == nil { defaults.set(0, forKey: Keys.dataRetentionDays) }
        
        if defaults.object(forKey: Keys.workTimeMonitoringEnabled) == nil { defaults.set(true, forKey: Keys.workTimeMonitoringEnabled) }
        if defaults.object(forKey: Keys.showWorkProgressInStatusBar) == nil { defaults.set(true, forKey: Keys.showWorkProgressInStatusBar) }

        // Werte laden
        showSeconds = defaults.bool(forKey: Keys.showSeconds)
        use24Hour = defaults.bool(forKey: Keys.use24Hour)
        showDate = defaults.bool(forKey: Keys.showDate)
        isAppTrackingEnabled = defaults.bool(forKey: Keys.isAppTrackingEnabled)

        let savedSize = defaults.double(forKey: Keys.largeClockFontSize)
        largeClockFontSize = savedSize > 0 ? savedSize : 36.0

        // Neue Properties laden
        targetWorkHours = defaults.integer(forKey: Keys.targetWorkHours)
        workStartTime = defaults.object(forKey: Keys.workStartTime) as? Date ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        workEndTime = defaults.object(forKey: Keys.workEndTime) as? Date ?? Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
        includeWeekends = defaults.bool(forKey: Keys.includeWeekends)
        autoStopOnInactivity = defaults.bool(forKey: Keys.autoStopOnInactivity)
        notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
        breakReminderInterval = defaults.integer(forKey: Keys.breakReminderInterval)
        trackOnlyProductiveApps = defaults.bool(forKey: Keys.trackOnlyProductiveApps)
        warnUnproductiveApps = defaults.bool(forKey: Keys.warnUnproductiveApps)
        dataRetentionDays = defaults.integer(forKey: Keys.dataRetentionDays)

        // Timer-Zeiten laden
        workSeconds = defaults.integer(forKey: Keys.workSeconds)
        coffeeSeconds = defaults.integer(forKey: Keys.coffeeSeconds)
        lunchSeconds = defaults.integer(forKey: Keys.lunchSeconds)
        
        workTimeMonitoringEnabled = defaults.bool(forKey: Keys.workTimeMonitoringEnabled)
        showWorkProgressInStatusBar = defaults.bool(forKey: Keys.showWorkProgressInStatusBar)
        
        // Timer-Sessions laden
        loadTimerSessions()

        setupFormatter()
        startClockTimer()
        
        // Berechtigung für Benachrichtigungen anfragen
        requestNotificationPermission()
        
        // Arbeitszeit-Check Timer starten
        startWorkTimeMonitoring()
        
        if workTimeMonitoringEnabled {
                startWorkTimeMonitoring()
            }
    }

    deinit {
        clockTimer?.invalidate()
        countdownTimer?.invalidate()
        appTrackingTimer?.invalidate()
        workTimeCheckTimer?.invalidate()
    }
    
    // MARK: - Benachrichtigungen
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Benachrichtigungen erlaubt")
            }
        }
    }
    
    private func startWorkTimeMonitoring() {
        workTimeCheckTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.checkWorkTimeProgress()
        }
        RunLoop.current.add(workTimeCheckTimer!, forMode: .common)
    }
    
    private func checkWorkTimeProgress() {
        guard notificationsEnabled && workTimeMonitoringEnabled else { return }
        
        let todayWorkTime = getWorkTimeForDate(Date())
        let targetWorkTime = targetWorkHours * 3600
        let progress = Double(todayWorkTime) / Double(targetWorkTime)
        
        let now = Date()
        
        // Ziel erreicht
        if progress >= 1.0 && !hasNotificationBeenSentToday("goal_reached") {
            sendNotification(
                title: "Arbeitsziel erreicht!",
                body: "Du hast heute bereits \(targetWorkHours) Stunden gearbeitet.",
                identifier: "goal_reached",
                icon: "checkmark.circle"
            )
        }
        // 75% erreicht
        else if progress >= 0.75 && !hasNotificationBeenSentToday("75_percent") {
            let remaining = formatTime(targetWorkTime - todayWorkTime)
            sendNotification(
                title: "75% geschafft!",
                body: "Noch \(remaining) bis zum Tagesziel.",
                identifier: "75_percent",
                icon: "chart.bar.fill"
            )
        }
        // 50% erreicht
        else if progress >= 0.5 && !hasNotificationBeenSentToday("50_percent") {
            sendNotification(
                title: "Hälfte geschafft!",
                body: "Du bist auf einem guten Weg zum Tagesziel.",
                identifier: "50_percent",
                icon: "clock.badge.checkmark"
            )
        }
        // Warnung bei wenig Arbeitszeit gegen Abend
        else if isAfternoon() && progress < 0.3 && !hasNotificationBeenSentToday("afternoon_warning") {
            sendNotification(
                title: "Arbeitszeit-Erinnerung",
                body: "Es wird später - vielleicht Zeit für mehr Produktivität?",
                identifier: "afternoon_warning",
                icon: "clock.badge.exclamationmark"
            )
        }
    }
    
    private func sendNotification(title: String, body: String, identifier: String, icon: String) {
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
    
    private func hasNotificationBeenSentToday(_ identifier: String) -> Bool {
        let key = "notification_\(identifier)_\(todayDateKey())"
        return UserDefaults.standard.bool(forKey: key)
    }
    
    private func markNotificationAsSentToday(_ identifier: String) {
        let key = "notification_\(identifier)_\(todayDateKey())"
        UserDefaults.standard.set(true, forKey: key)
    }
    
    private func todayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private func isAfternoon() -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 15 // Nach 15:00 Uhr
    }

    // MARK: - Timer Functions

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
    
    // MARK: - App-Tracking Functions
    
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
    
    // MARK: - Chronik Functions
    
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
    
    // MARK: - Analyse Functions
    
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
    
    // MARK: - Export Functions
    
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
    
    // MARK: - Private Functions
    
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

    // Clock-Logik (für interne Views)
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
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}
