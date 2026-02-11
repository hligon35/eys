import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
#endif

struct AppSelectionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                SectionHeader(title: "Select Learning Apps", subtitle: "These apps count toward learning time")

                CardContainer {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("FamilyActivityPicker")
                            .font(DS.Typography.cardTitle)

#if canImport(FamilyControls)
                        FamilyActivityPicker(selection: $appState.selectedLearningApps)
                            .frame(maxHeight: 420)
#else
                        Text("FamilyControls not available in this environment.\nAdd this to an iOS target with Screen Time entitlements.")
                            .font(DS.Typography.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
#endif
                    }
                }
                .padding(.horizontal, 16)

                PrimaryButton(title: "Save", systemImage: "checkmark") {
                    appState.screenTimeService.startMonitoringLearningApps(selection: appState.selectedLearningApps)
                    dismiss()
                }
                .padding(.horizontal, 16)

                Spacer()
            }
            .padding(.vertical, 12)
            .background(DS.Colors.pageBackground)
            .navigationTitle("Apps")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
