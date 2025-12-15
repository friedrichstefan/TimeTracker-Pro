//
//  Extensions.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import Foundation

// MARK: - UserDefaults Keys

enum UserDefaultsKeys {
    static let showSeconds = "TimeTracker_ShowSeconds"
    static let use24Hour = "TimeTracker_Use24Hour"
    static let showDate = "TimeTracker_ShowDate"
    static let largeClockFontSize = "TimeTracker_LargeClockFontSize"
    static let workSeconds = "TimeTracker_WorkSeconds"
    static let coffeeSeconds = "TimeTracker_CoffeeSeconds"
    static let lunchSeconds = "TimeTracker_LunchSeconds"
    static let timerSessions = "TimeTracker_TimerSessions"
    static let isAppTrackingEnabled = "TimeTracker_IsAppTrackingEnabled"
    
    // Arbeitszeit-Einstellungen
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
    
    // Arbeitszeit-Monitoring
    static let workTimeMonitoringEnabled = "TimeTracker_WorkTimeMonitoringEnabled"
    static let showWorkProgressInStatusBar = "TimeTracker_ShowWorkProgressInStatusBar"
    
    // Automatisches Pausieren
    static let enableAutoPause = "TimeTracker_EnableAutoPause"
    static let onlyDuringWorkHours = "TimeTracker_OnlyDuringWorkHours"
    static let minimumPauseDurationSeconds = "TimeTracker_MinimumPauseDurationSeconds"
    static let lunchThresholdMinutes = "TimeTracker_LunchThresholdMinutes"
    static let askBeforeResuming = "TimeTracker_AskBeforeResuming"
    
    // Erweiterte Auto-Pause
    static let pauseOutsideWorkHours = "TimeTracker_PauseOutsideWorkHours"
    static let askToResumeAfterPause = "TimeTracker_AskToResumeAfterPause"
}

// MARK: - Time Formatters

extension TimeInterval {
    func formatAsTimer() -> String {
        let seconds = Int(self)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
    
    func formatAsShortTime() -> String {
        let seconds = Int(self)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

extension Int {
    func formatAsDuration() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let secs = self % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%02dm %02ds", minutes, secs)
        } else {
            return String(format: "%02ds", secs)
        }
    }
    
    func formatAsTime() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm", minutes)
        } else {
            return "0m"
        }
    }
    
    func formatAsTimerDisplay() -> String {
        let hours = self / 3600
        let minutes = (self % 3600) / 60
        let secs = self % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

// MARK: - Date Extensions

extension Date {
    func todayDateKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    func formatWeekday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    func formatTimeOnly() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    var isAfternoon: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 15 // Nach 15:00 Uhr
    }
}

// MARK: - UserDefaults Extensions

extension UserDefaults {
    func setDefaultsIfNeeded() {
        // Standard-Werte setzen falls noch nicht gesetzt
        if object(forKey: UserDefaultsKeys.showSeconds) == nil { set(true, forKey: UserDefaultsKeys.showSeconds) }
        if object(forKey: UserDefaultsKeys.use24Hour) == nil { set(false, forKey: UserDefaultsKeys.use24Hour) }
        if object(forKey: UserDefaultsKeys.showDate) == nil { set(false, forKey: UserDefaultsKeys.showDate) }
        if object(forKey: UserDefaultsKeys.largeClockFontSize) == nil { set(36.0, forKey: UserDefaultsKeys.largeClockFontSize) }
        if object(forKey: UserDefaultsKeys.isAppTrackingEnabled) == nil { set(false, forKey: UserDefaultsKeys.isAppTrackingEnabled) }
        
        // Arbeitszeit-Einstellungen Standard-Werte
        if object(forKey: UserDefaultsKeys.targetWorkHours) == nil { set(8, forKey: UserDefaultsKeys.targetWorkHours) }
        if object(forKey: UserDefaultsKeys.workStartTime) == nil {
            let startTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
            set(startTime, forKey: UserDefaultsKeys.workStartTime)
        }
        if object(forKey: UserDefaultsKeys.workEndTime) == nil {
            let endTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
            set(endTime, forKey: UserDefaultsKeys.workEndTime)
        }
        if object(forKey: UserDefaultsKeys.includeWeekends) == nil { set(false, forKey: UserDefaultsKeys.includeWeekends) }
        if object(forKey: UserDefaultsKeys.autoStopOnInactivity) == nil { set(true, forKey: UserDefaultsKeys.autoStopOnInactivity) }
        if object(forKey: UserDefaultsKeys.notificationsEnabled) == nil { set(false, forKey: UserDefaultsKeys.notificationsEnabled) }
        if object(forKey: UserDefaultsKeys.breakReminderInterval) == nil { set(60, forKey: UserDefaultsKeys.breakReminderInterval) }
        if object(forKey: UserDefaultsKeys.trackOnlyProductiveApps) == nil { set(false, forKey: UserDefaultsKeys.trackOnlyProductiveApps) }
        if object(forKey: UserDefaultsKeys.warnUnproductiveApps) == nil { set(false, forKey: UserDefaultsKeys.warnUnproductiveApps) }
        if object(forKey: UserDefaultsKeys.dataRetentionDays) == nil { set(0, forKey: UserDefaultsKeys.dataRetentionDays) }
        
        // Arbeitszeit-Monitoring Standard-Werte
        if object(forKey: UserDefaultsKeys.workTimeMonitoringEnabled) == nil { set(true, forKey: UserDefaultsKeys.workTimeMonitoringEnabled) }
        if object(forKey: UserDefaultsKeys.showWorkProgressInStatusBar) == nil { set(true, forKey: UserDefaultsKeys.showWorkProgressInStatusBar) }
        
        // Automatisches Pausieren Standard-Werte
        if object(forKey: UserDefaultsKeys.enableAutoPause) == nil { set(false, forKey: UserDefaultsKeys.enableAutoPause) }
        if object(forKey: UserDefaultsKeys.onlyDuringWorkHours) == nil { set(true, forKey: UserDefaultsKeys.onlyDuringWorkHours) }
        if object(forKey: UserDefaultsKeys.minimumPauseDurationSeconds) == nil { set(10, forKey: UserDefaultsKeys.minimumPauseDurationSeconds) }
        if object(forKey: UserDefaultsKeys.lunchThresholdMinutes) == nil { set(10, forKey: UserDefaultsKeys.lunchThresholdMinutes) }
        if object(forKey: UserDefaultsKeys.askBeforeResuming) == nil { set(true, forKey: UserDefaultsKeys.askBeforeResuming) }
        
        // Erweiterte Auto-Pause Standard-Werte
        if object(forKey: UserDefaultsKeys.pauseOutsideWorkHours) == nil { set(true, forKey: UserDefaultsKeys.pauseOutsideWorkHours) }
        if object(forKey: UserDefaultsKeys.askToResumeAfterPause) == nil { set(true, forKey: UserDefaultsKeys.askToResumeAfterPause) }
    }
}
