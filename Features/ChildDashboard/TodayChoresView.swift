import SwiftUI

struct TodayChoresView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedInstance: ChoreInstance? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Today’s Chores", subtitle: "Submit proof when finished")

                    CardContainer {
                        VStack(spacing: 10) {
                            ForEach(todayInstances) { instance in
                                let chore = appState.chores.first { $0.id == instance.choreId }

                                Button {
                                    selectedInstance = instance
                                } label: {
                                    ChoreListRow(title: chore?.title ?? "Chore", points: chore?.points ?? 0, status: instance.status)
                                }
                                .buttonStyle(.plain)

                                if instance.id != todayInstances.last?.id {
                                    Divider()
                                }
                            }

                            if todayInstances.isEmpty {
                                Text("No chores scheduled.")
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
            .navigationTitle("Chores")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $selectedInstance) { instance in
                SubmitChoreProofView(instance: instance)
            }
        }
    }

    private var todayInstances: [ChoreInstance] {
        appState.choreInstances.filter { $0.scheduledDate.isToday }
    }
}

private extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
