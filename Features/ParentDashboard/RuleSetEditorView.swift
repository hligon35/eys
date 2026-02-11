import SwiftUI

struct RuleSetEditorView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var policy: RuleSet.LockPolicy = .lockUntilGoalsMet
    @State private var requiredXP: Int = 50
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    SectionHeader(title: "Rules", subtitle: "Define what ‘unlock’ means")

                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Policy", selection: $policy) {
                                ForEach(RuleSet.LockPolicy.allCases, id: \.self) { policy in
                                    Text(label(for: policy)).tag(policy)
                                }
                            }
                            .pickerStyle(.segmented)

                            Stepper("Required daily XP: \(requiredXP)", value: $requiredXP, in: 0...500, step: 10)

                            if policy == .scheduleOnly {
                                Divider()

                                Text("Unlock window")
                                    .font(DS.Typography.cardTitle)

                                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)

                                Text("During this window the device is unlocked (placeholder schedule rule).")
                                    .font(DS.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if policy == .approvedOnlyWindow {
                                Divider()

                                Text("Approved-only window")
                                    .font(DS.Typography.cardTitle)

                                DatePicker("Start", selection: $startTime, displayedComponents: .hourAndMinute)
                                DatePicker("End", selection: $endTime, displayedComponents: .hourAndMinute)

#if canImport(FamilyControls)
                                FamilyActivityPicker(selection: $appState.selectedApprovedApps)
                                    .frame(maxHeight: 320)
#else
                                Text("FamilyControls not available in this environment.\nAdd this to an iOS target with Screen Time entitlements.")
                                    .font(DS.Typography.body)
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
#endif

                                Text("During this window only the apps you approve are allowed.")
                                    .font(DS.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text("Placeholder: this will later map to ManagedSettings rules + DeviceActivity thresholds.")
                                .font(DS.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 16)

                    PrimaryButton(title: "Save", systemImage: "checkmark") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            appState.ruleSet = RuleSet(
                                policy: policy,
                                requiredDailyXP: requiredXP,
                                unlockWindowStartMinutes: minutesSinceMidnight(startTime),
                                unlockWindowEndMinutes: minutesSinceMidnight(endTime)
                            )
                        }

                        if policy == .approvedOnlyWindow {
                            appState.screenTimeService.startMonitoringApprovedOnlyWindow(
                                selection: appState.selectedApprovedApps,
                                startMinutes: minutesSinceMidnight(startTime),
                                endMinutes: minutesSinceMidnight(endTime)
                            )
                        }
                        dismiss()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 12)
            }
            .background(DS.Colors.pageBackground)
            .navigationTitle("Rule Set")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                policy = appState.ruleSet.policy
                requiredXP = appState.ruleSet.requiredDailyXP
                startTime = dateForMinutes(appState.ruleSet.unlockWindowStartMinutes)
                endTime = dateForMinutes(appState.ruleSet.unlockWindowEndMinutes)
            }
        }
    }

    private func label(for policy: RuleSet.LockPolicy) -> String {
        switch policy {
        case .lockUntilGoalsMet: return "Goals"
        case .scheduleOnly: return "Schedule"
        case .approvedOnlyWindow: return "Approved"
        case .off: return "Off"
        }
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return max(0, min(23 * 60 + 59, (comps.hour ?? 0) * 60 + (comps.minute ?? 0)))
    }

    private func dateForMinutes(_ minutes: Int) -> Date {
        let clamped = max(0, min(23 * 60 + 59, minutes))
        let hour = clamped / 60
        let minute = clamped % 60
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
