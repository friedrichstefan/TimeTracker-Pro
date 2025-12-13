//
//  TimeModel.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import Foundation
import Combine

final class TimeModel: ObservableObject {
    @Published var date: Date = Date()
    @Published var timeString: String = ""
    @Published var showSeconds: Bool {
        didSet { UserDefaults.standard.set(showSeconds, forKey: Keys.showSeconds); updateFormattedString() }
    }
    @Published var use24Hour: Bool {
        didSet { UserDefaults.standard.set(use24Hour, forKey: Keys.use24Hour); updateFormattedString() }
    }
    @Published var showDate: Bool {
        didSet { UserDefaults.standard.set(showDate, forKey: Keys.showDate); updateFormattedString() }
    }

    // Neue Eigenschaft: Schriftgröße der großen Uhr (in Punkten)
    @Published var largeClockFontSize: Double {
        didSet { UserDefaults.standard.set(largeClockFontSize, forKey: Keys.largeClockFontSize) }
    }

    private var timer: Timer?
    private var formatter = DateFormatter()

    private enum Keys {
        static let showSeconds = "TimeTracker_ShowSeconds"
        static let use24Hour = "TimeTracker_Use24Hour"
        static let showDate = "TimeTracker_ShowDate"
        static let largeClockFontSize = "TimeTracker_LargeClockFontSize"
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

        setupFormatter()
        updateFormattedString()
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    private func setupFormatter() {
        formatter.locale = Locale.current
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.date = Date()
            self.updateFormattedString()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func updateFormattedString() {
        var timeFormat = ""
        if use24Hour {
            timeFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            timeFormat = showSeconds ? "hh:mm:ss a" : "hh:mm a"
        }
        formatter.dateFormat = timeFormat

        var s = formatter.string(from: date)
        if showDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            s += "  ·  " + dateFormatter.string(from: date)
        }

        DispatchQueue.main.async {
            self.timeString = s
        }
    }
}
