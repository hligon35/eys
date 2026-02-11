import SwiftUI

struct ParentDashboardView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showAddChore = false
    @State private var showReview = false
    @State private var showLearningSetup = false
    @State private var showRules = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header

                    CardContainer {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Child")
                                    .font(DS.Typography.caption)
                                    .foregroundStyle(.secondary)
                                Text(appState.childProfile.displayName)
                                    .font(DS.Typography.sectionHeader)
                                Text("Age \(appState.childProfile.age)")
                                    .font(DS.Typography.body)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            ProgressRing(progress: dailyCompletionProgress)
                        }
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today")
                                .font(DS.Typography.cardTitle)

                            HStack {
                                pill("Chores", value: "\(approvedCount)/\(todayCount)")
                                pill("Learning", value: learningSummary)
                                Spacer()
                            }

                            HStack(spacing: 12) {
                                SecondaryButton(title: "Review", systemImage: "checklist") {
                                    showReview = true
                                }
                                PrimaryButton(title: "Add Chore", systemImage: "plus") {
                                    showAddChore = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Controls")
                                .font(DS.Typography.cardTitle)

                            HStack(spacing: 12) {
                                SecondaryButton(title: "Learning Setup", systemImage: "timer") {
                                    showLearningSetup = true
                                }
                                SecondaryButton(title: "Rules", systemImage: "slider.horizontal.3") {
                                    showRules = true
                                }
                            }

                            HStack(spacing: 12) {
                                SecondaryButton(title: "Switch to Child", systemImage: "person") {
                                    appState.switchMode(.child)
                                }
                                PrimaryButton(title: lockButtonTitle, systemImage: lockButtonIcon) {
                                    toggleLock()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("Parent")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showAddChore) {
                AddChoreView()
            }
            .sheet(isPresented: $showReview) {
                ReviewChoresView()
            }
            .sheet(isPresented: $showLearningSetup) {
                LearningGoalSetupView()
            }
            .sheet(isPresented: $showRules) {
                RuleSetEditorView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Earn Your Screen", subtitle: "Approve chores + learning to unlock")
        }
    }

    private func pill(_ label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
            Text(value)
                .font(.caption.weight(.semibold))
        }
        .font(.caption)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Capsule().fill(DS.Colors.softGray.opacity(0.7)))
    }

    private var todayCount: Int {
        appState.choreInstances.filter { $0.scheduledDate.isToday }.count
    }

    private var approvedCount: Int {
        appState.choreInstances.filter { $0.scheduledDate.isToday && $0.status == .approved }.count
    }

    private var dailyCompletionProgress: Double {
        guard todayCount > 0 else { return 0 }
        return Double(approvedCount) / Double(todayCount)
    }

    private var learningSummary: String {
        let met = appState.learningGoals.filter { $0.progressSeconds >= $0.targetSeconds }.count
        return "\(met)/\(appState.learningGoals.count)"
    }

    private var lockButtonTitle: String {
        switch appState.unlockStatus {
        case .locked: return "Unlock"
        case .unlocked: return "Lock"
        }
    }

    private var lockButtonIcon: String {
        switch appState.unlockStatus {
        case .locked: return "lock.open"
        case .unlocked: return "lock"
        }
    }

    private func toggleLock() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            switch appState.parentOverride {
            case .none, .locked:
                appState.parentOverride = .unlocked
            case .unlocked:
                appState.parentOverride = .locked
            }
            appState.refreshUnlockStatus()
        }
    }
}

private extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
