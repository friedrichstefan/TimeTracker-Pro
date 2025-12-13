//
//  LargeClockView.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import SwiftUI

struct LargeClockView: View {
    @ObservedObject var timeModel: TimeModel

    var body: some View {
        VStack {
            Text(displayTime())
                .font(.system(size: CGFloat(timeModel.largeClockFontSize), weight: .semibold, design: .monospaced))
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding(.bottom, 6)

            if timeModel.showDate {
                Text(DateFormatter.localizedString(from: timeModel.date, dateStyle: .medium, timeStyle: .none))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
    }

    private func displayTime() -> String {
        var format = ""
        if timeModel.use24Hour {
            format = timeModel.showSeconds ? "HH:mm:ss" : "HH:mm"
        } else {
            format = timeModel.showSeconds ? "hh:mm:ss a" : "hh:mm a"
        }
        let df = DateFormatter()
        df.dateFormat = format
        df.locale = Locale.current
        return df.string(from: timeModel.date)
    }
}
