import Foundation
import Combine

enum TimerCategory: String, CaseIterable {
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
    }

    init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: Keys.showSeconds) == nil { defaults.set(true, forKey: Keys.showSeconds) }
        if defaults.object(forKey: Keys.use24Hour) == nil { defaults.set(false, forKey: Keys.use24Hour) }
        if defaults.object(forKey: Keys.showDate) == nil { defaults.set(false, forKey: Keys.showDate) }
        if defaults.object(forKey: Keys.largeClockFontSize) == nil { defaults.set(36.0, forKey: Keys.largeClockFontSize) }

        showSeconds = defaults.bool(forKey: Keys.showSeconds)
        use24Hour = defaults.bool(forKey: Keys.use24Hour)
        showDate = defaults.bool(forKey: Keys.showDate)

        let savedSize = defaults.double(forKey: Keys.largeClockFontSize)
        largeClockFontSize = savedSize > 0 ? savedSize : 36.0

        // Lade gespeicherte Timer-Zeiten
        workSeconds = defaults.integer(forKey: Keys.workSeconds)
        coffeeSeconds = defaults.integer(forKey: Keys.coffeeSeconds)
        lunchSeconds = defaults.integer(forKey: Keys.lunchSeconds)

        setupFormatter()
        startClockTimer()
    }

    deinit {
        clockTimer?.invalidate()
        countdownTimer?.invalidate()
    }

    // Timer-Funktionen
    func startTimer(for category: TimerCategory) {
        stopTimer() // Stoppe aktuellen Timer falls läuft
        activeCategory = category
        isTimerRunning = true
        
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
        isTimerRunning = false
        activeCategory = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
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
            // Wenn kein Timer läuft, zeige den größten Wert
            return max(workSeconds, coffeeSeconds, lunchSeconds)
        }
        
        switch category {
        case .work: return workSeconds
        case .coffee: return coffeeSeconds
        case .lunch: return lunchSeconds
        }
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
