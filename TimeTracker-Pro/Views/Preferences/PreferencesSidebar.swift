//
//  PreferencesSidebar.swift
//  TimeTracker-Pro
//
//  Created by Friedrich, Stefan on 15.12.25.
//

import SwiftUI

struct PreferencesSidebar: View {
    @Binding var selectedTab: PrefsTab
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        List(selection: $selectedTab) {
            ForEach(PrefsTab.allCases, id: \.self) { tab in
                SidebarLabel(tab: tab)
                    .tag(tab)
                
                // Trennstrich nach App-Analyse
                if tab.needsDividerAfter {
                    VStack {
                        Divider()
                            .padding(.vertical, 4)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .selectionDisabled()
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("preferences.title".localized)
    }
}

// MARK: - Sidebar Label

struct SidebarLabel: View {
    let tab: PrefsTab
    
    var body: some View {
        Label(tab.title, systemImage: tab.systemImage)
            .font(.system(size: 14, weight: .medium))
    }
}

// MARK: - Preview

#Preview {
    NavigationSplitView {
        PreferencesSidebar(selectedTab: .constant(.settings))
    } detail: {
        Text("Detail View")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.regularMaterial)
    }
}
