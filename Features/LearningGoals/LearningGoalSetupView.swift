import SwiftUI

struct LearningGoalSetupView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showAppSelection = false
    @State private var title = ""
    @State private var targetMinutes = 15

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Learning Goals", subtitle: "Pick learning apps + set time goals")

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Learning Apps")
                                .font(DS.Typography.cardTitle)

                            ShieldedAppListRow(
                                title: "Selected Apps",
                                subtitle: "Tap to choose educational apps",
                                isSelected: hasSelection
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showAppSelection = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Goal")
                                .font(DS.Typography.cardTitle)

                            TextField("Goal title (e.g., Reading)", text: $title)
                                .textFieldStyle(.roundedBorder)

                            Stepper("Target: \(targetMinutes) min", value: $targetMinutes, in: 5...120, step: 5)

                            PrimaryButton(title: "Add", systemImage: "plus", isEnabled: !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                                let goal = appState.learningGoalService.createGoal(title: title, targetMinutes: targetMinutes)
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    appState.learningGoals.insert(goal, at: 0)
                                }
                                title = ""
                                targetMinutes = 15
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Goals")
                                .font(DS.Typography.cardTitle)

                            ForEach(appState.learningGoals) { goal in
                                LearningGoalProgressBar(
                                    title: goal.title,
                                    progress: goal.progress,
                                    caption: "\(goal.progressSeconds/60)m of \(goal.targetSeconds/60)m"
                                )
                                if goal.id != appState.learningGoals.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Done", systemImage: "checkmark") {
                        appState.screenTimeService.startMonitoringLearningApps(selection: appState.selectedLearningApps)
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("Learning")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showAppSelection) {
                AppSelectionView()
            }
        }
    }

    private var hasSelection: Bool {
        #if canImport(FamilyControls)
        return !appState.selectedLearningApps.applicationTokens.isEmpty
            || !appState.selectedLearningApps.categoryTokens.isEmpty
            || !appState.selectedLearningApps.webDomainTokens.isEmpty
        #else
        // Placeholder when FamilyControls isn't available.
        return true
        #endif
    }
}
