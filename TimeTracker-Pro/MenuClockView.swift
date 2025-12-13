//
//  MenuClockView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct MenuClockView: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            // kleinere, aber gut lesbare Uhr für das Menü
            Text(clockText())
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
                .lineLimit(1)
            if timeModel.showDate {
                Text(DateFormatter.localizedString(from: timeModel.date, dateStyle: .medium, timeStyle: .none))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func clockText() -> String {
        if timeModel.use24Hour {
            let fmt = timeModel.showSeconds ? "HH:mm:ss" : "HH:mm"
            let df = DateFormatter()
            df.dateFormat = fmt
            df.locale = Locale.current
            return df.string(from: timeModel.date)
        } else {
            let fmt = timeModel.showSeconds ? "hh:mm:ss a" : "hh:mm a"
            let df = DateFormatter()
            df.dateFormat = fmt
            df.locale = Locale.current
            return df.string(from: timeModel.date)
        }
    }
}
