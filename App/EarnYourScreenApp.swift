import SwiftUI

@main
struct EarnYourScreenApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.activeMode {
            case .parent:
                ParentDashboardView()
            case .child:
                ChildHomeView()
            }
        }
        .tint(DS.Colors.teal)
        .task {
            await appState.screenTimeService.requestAuthorizationIfNeeded()
            appState.startBackgroundRefreshIfNeeded()
        }
    }
}
