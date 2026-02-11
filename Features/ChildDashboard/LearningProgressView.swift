import SwiftUI

struct LearningProgressView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Learning Progress", subtitle: "Time in selected learning apps")

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today")
                                .font(DS.Typography.cardTitle)

                            ForEach(appState.learningGoals) { goal in
                                LearningGoalProgressBar(
                                    title: goal.title,
                                    progress: goal.progress,
                                    caption: "\(goal.progressSeconds/60)m of \(goal.targetSeconds/60)m"
                                )

                                HStack {
                                    SecondaryButton(title: "Add 5m", systemImage: "plus") {
                                        addFiveMinutes(goal)
                                    }
                                    SecondaryButton(title: "Reset", systemImage: "arrow.counterclockwise") {
                                        reset(goal)
                                    }
                                }

                                if goal.id != appState.learningGoals.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Done", systemImage: "checkmark") {
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
        }
    }

    private func addFiveMinutes(_ goal: LearningGoal) {
        guard let idx = appState.learningGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            appState.learningGoals[idx] = appState.learningGoalService.updateProgress(goal: goal, newProgressSeconds: goal.progressSeconds + 5 * 60)
            appState.refreshUnlockStatus()
        }
    }

    private func reset(_ goal: LearningGoal) {
        guard let idx = appState.learningGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            appState.learningGoals[idx] = appState.learningGoalService.updateProgress(goal: goal, newProgressSeconds: 0)
            appState.refreshUnlockStatus()
        }
    }
}
