//
//  String+Localized.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// Returns the localized string with format arguments
    func localized(_ args: CVarArg...) -> String {
        return String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}
