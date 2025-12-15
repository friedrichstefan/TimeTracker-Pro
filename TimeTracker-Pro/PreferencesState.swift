//
//  PreferencesState.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 13.12.25.
//

import Foundation
import Combine

class PreferencesState: ObservableObject {
    @Published var selectedTab: PrefsTab = .timerDetails
    
    func setSelectedTab(_ tab: PrefsTab) {
        selectedTab = tab
    }
}
