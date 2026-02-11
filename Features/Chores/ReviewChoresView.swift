import SwiftUI

struct ReviewChoresView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Review Chores", subtitle: "Approve or reject submissions")

                    CardContainer {
                        VStack(spacing: 10) {
                            ForEach(todayInstances) { instance in
                                let chore = appState.chores.first { $0.id == instance.choreId }
                                HStack {
                                    ChoreListRow(
                                        title: chore?.title ?? "Chore",
                                        points: chore?.points ?? 0,
                                        status: instance.status
                                    )

                                    Spacer(minLength: 8)

                                    if instance.status == .submitted {
                                        Button {
                                            approve(instance)
                                        } label: {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(DS.Colors.teal)
                                        }
                                        .buttonStyle(.plain)

                                        Button {
                                            reject(instance)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.red)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 6)

                                if instance.status == .submitted {
                                    Divider()
                                }
                            }

                            if todayInstances.isEmpty {
                                Text("No chores scheduled today.")
                                    .font(DS.Typography.body)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("Review")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var todayInstances: [ChoreInstance] {
        appState.choreInstances.filter { $0.scheduledDate.isToday }
    }

    private func approve(_ instance: ChoreInstance) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            replace(instance: instance, with: appState.choreService.approve(instance: instance))
            appState.refreshUnlockStatus()
        }
    }

    private func reject(_ instance: ChoreInstance) {
        withAnimation(.easeInOut(duration: 0.2)) {
            replace(instance: instance, with: appState.choreService.reject(instance: instance))
            appState.refreshUnlockStatus()
        }
    }

    private func replace(instance: ChoreInstance, with updated: ChoreInstance) {
        guard let idx = appState.choreInstances.firstIndex(where: { $0.id == instance.id }) else { return }
        appState.choreInstances[idx] = updated
    }
}

private extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
