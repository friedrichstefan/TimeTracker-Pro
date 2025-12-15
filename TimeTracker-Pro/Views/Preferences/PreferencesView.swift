import SwiftUI
import Combine

enum PrefsTab: String, CaseIterable, Hashable {
    case timerDetails = "timerDetails"
    case chronik = "chronik"
    case analyse = "analyse"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .timerDetails: return "timer.details".localized
        case .chronik: return "timeline".localized
        case .analyse: return "analysis.title".localized
        case .settings: return "settings".localized
        }
    }
    
    var systemImage: String {
        switch self {
        case .timerDetails: return "timer"
        case .chronik: return "clock.arrow.circlepath"
        case .analyse: return "chart.pie"
        case .settings: return "gearshape"
        }
    }
    
    var needsDividerAfter: Bool {
        return self == .analyse
    }
}

struct PreferencesView: View {
    @ObservedObject var timeModel: TimeModel
    @ObservedObject var preferencesState: PreferencesState
    @Environment(\.colorScheme) var colorScheme
    
    // Kontrolle über Sidebar-Sichtbarkeit
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar Content
            PreferencesSidebar(selectedTab: $preferencesState.selectedTab)
                .navigationSplitViewColumnWidth(min: 200, ideal: 260, max: 300)
        } detail: {
            // Detail Content
            DetailContentView(
                selectedTab: preferencesState.selectedTab,
                timeModel: timeModel
            )
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button {
                        toggleSidebar()
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                    .help("Sidebar ein-/ausblenden")
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private func toggleSidebar() {
        withAnimation(.easeInOut(duration: 0.2)) {
            columnVisibility = columnVisibility == .all ? .detailOnly : .all
        }
    }
}

// MARK: - Detail Content Router

struct DetailContentView: View {
    let selectedTab: PrefsTab
    @ObservedObject var timeModel: TimeModel
    
    var body: some View {
        Group {
            switch selectedTab {
            case .timerDetails:
                TimerDetailView(timeModel: timeModel)
            case .chronik:
                ChronikView(timeModel: timeModel)
            case .analyse:
                AnalyseView(timeModel: timeModel)
            case .settings:
                SettingsPane(timeModel: timeModel)
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}
