import SwiftUI

struct AddChoreView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var details = ""
    @State private var points = 10
    @State private var schedule: Chore.Schedule = .daily
    @State private var dueDate: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Add Chore", subtitle: "Create a required task for today")

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Title", text: $title)
                                .textFieldStyle(.roundedBorder)

                            TextField("Details", text: $details, axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)

                            HStack {
                                Stepper("Points: \(points)", value: $points, in: 1...200)
                            }

                            Picker("Schedule", selection: $schedule) {
                                ForEach(Chore.Schedule.allCases, id: \.self) { schedule in
                                    Text(schedule.rawValue.capitalized).tag(schedule)
                                }
                            }
                            .pickerStyle(.segmented)

                            if schedule == .oneOff {
                                DatePicker("Due", selection: $dueDate, displayedComponents: .date)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Create", systemImage: "plus", isEnabled: !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                        let chore = appState.choreService.createChore(
                            title: title,
                            details: details,
                            points: points,
                            schedule: schedule,
                            dueDate: schedule == .oneOff ? dueDate : nil
                        )
                        withAnimation(.easeInOut(duration: 0.25)) {
                            appState.chores.insert(chore, at: 0)
                            appState.choreInstances = appState.choreService.scheduleTodayInstances(from: appState.chores)
                        }
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("New Chore")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
