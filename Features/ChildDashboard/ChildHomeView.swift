import SwiftUI

struct ChildHomeView: View {
    @EnvironmentObject private var appState: AppState

    @State private var showTodayChores = false
    @State private var showLearning = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Hi, \(appState.childProfile.displayName)", subtitle: "Earn screen time by completing goals")

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Unlock Status")
                                .font(DS.Typography.cardTitle)

                            UnlockStatusView(status: appState.unlockStatus)

                            HStack(spacing: 12) {
                                SecondaryButton(title: "Today’s Chores", systemImage: "checklist") {
                                    showTodayChores = true
                                }
                                SecondaryButton(title: "Learning", systemImage: "timer") {
                                    showLearning = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today")
                                .font(DS.Typography.cardTitle)

                            HStack {
                                ProgressRing(progress: choresProgress, size: 64)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Chores")
                                        .font(DS.Typography.body.weight(.semibold))
                                    Text("\(approvedCount)/\(todayCount) approved")
                                        .font(DS.Typography.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }

                            ForEach(todayInstances.prefix(3)) { instance in
                                let chore = appState.chores.first { $0.id == instance.choreId }
                                ChoreListRow(title: chore?.title ?? "Chore", points: chore?.points ?? 0, status: instance.status)
                                if instance.id != todayInstances.prefix(3).last?.id {
                                    Divider()
                                }
                            }

                            if todayInstances.isEmpty {
                                Text("No chores yet — ask your parent to add some.")
                                    .font(DS.Typography.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    SecondaryButton(title: "Switch to Parent", systemImage: "person") {
                        appState.switchMode(.parent)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("Child")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showTodayChores) {
                TodayChoresView()
            }
            .sheet(isPresented: $showLearning) {
                LearningProgressView()
            }
        }
    }

    private var todayInstances: [ChoreInstance] {
        appState.choreInstances.filter { $0.scheduledDate.isToday }
    }

    private var todayCount: Int { todayInstances.count }

    private var approvedCount: Int {
        todayInstances.filter { $0.status == .approved }.count
    }

    private var choresProgress: Double {
        guard todayCount > 0 else { return 0 }
        return Double(approvedCount) / Double(todayCount)
    }
}

private extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
