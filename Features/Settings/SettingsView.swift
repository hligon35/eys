import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionHeader(title: "Settings", subtitle: "App mode and Screen Time status")

                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mode")
                            .font(DS.Typography.cardTitle)

                        Picker("Mode", selection: $appState.activeMode) {
                            ForEach(AppState.Mode.allCases) { mode in
                                Text(mode.rawValue.capitalized).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 16)

                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Screen Time")
                            .font(DS.Typography.cardTitle)

                        Text("Requires entitlements + iOS device. Stubbed here.")
                            .font(DS.Typography.body)
                            .foregroundStyle(.secondary)

                        PrimaryButton(title: "Request Authorization", systemImage: "hand.raised") {
                            Task {
                                await appState.screenTimeService.requestAuthorizationIfNeeded()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .background(DS.Colors.pageBackground)
        .navigationTitle("Settings")
    }
}
