import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case parent
        case child

        var id: String { rawValue }
    }

    @Published var activeMode: Mode = .parent

    @Published var childProfile: ChildProfile = .mock

    @Published var chores: [Chore] = Chore.mockList
    @Published var choreInstances: [ChoreInstance] = ChoreInstance.mockToday

    @Published var learningGoals: [LearningGoal] = LearningGoal.mockList
    @Published var ruleSet: RuleSet = .mock

    enum ParentOverride: String, Codable {
        case none
        case locked
        case unlocked
    }

    @Published var parentOverride: ParentOverride = .none

    // Screen Time
    @Published var selectedLearningApps: FamilyActivitySelection = .init()
    @Published var selectedApprovedApps: FamilyActivitySelection = .init()
    @Published var unlockStatus: UnlockStatus = .locked(reason: "Complete today’s goals")

    // Services (stubs)
    let screenTimeService = ScreenTimeService()
    let choreService = ChoreService()
    let learningGoalService = LearningGoalService()
    let syncService = SyncService()

    private var refreshTask: Task<Void, Never>? = nil
    private var lastAppliedLearningSecondsToday: Int = -1

    private var cancellables = Set<AnyCancellable>()

    init() {
        var shared = ScreenTimeSharedStore()
        if let learning = shared.learningSelection {
            selectedLearningApps = learning
        }
        if let approved = shared.approvedWindowSelection {
            selectedApprovedApps = approved
        }

        if let snapshot = syncService.loadSnapshot() {
            activeMode = Mode(rawValue: snapshot.activeModeRaw) ?? .parent
            childProfile = snapshot.childProfile
            chores = snapshot.chores
            choreInstances = snapshot.choreInstances
            learningGoals = snapshot.learningGoals
            ruleSet = snapshot.ruleSet
            parentOverride = snapshot.parentOverride
        }

        if ruleSet.policy == .approvedOnlyWindow {
            screenTimeService.startMonitoringApprovedOnlyWindow(
                selection: selectedApprovedApps,
                startMinutes: ruleSet.unlockWindowStartMinutes,
                endMinutes: ruleSet.unlockWindowEndMinutes
            )
        }

        refreshUnlockStatus()

        // Persist changes with a small debounce to avoid excessive writes.
        objectWillChange
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.persistSnapshot()
            }
            .store(in: &cancellables)
    }

    func switchMode(_ mode: Mode) {
        withAnimation(.easeInOut(duration: 0.25)) {
            activeMode = mode
        }
    }

    func refreshUnlockStatus() {
        switch parentOverride {
        case .locked:
            unlockStatus = .locked(reason: "Parent locked")
            screenTimeService.applyLockedState(true)
            return
        case .unlocked:
            unlockStatus = .unlocked
            screenTimeService.applyLockedState(false)
            return
        case .none:
            break
        }

        let todayInstances = choreInstances.filter { $0.scheduledDate.isToday }
        let approvedInstances = todayInstances.filter { $0.status == .approved }

        let allApproved = !todayInstances.isEmpty && todayInstances.allSatisfy { $0.status == .approved }
        let learningMet = learningGoals.allSatisfy { $0.progressSeconds >= $0.targetSeconds }

        let earnedXP: Int = approvedInstances.reduce(into: 0) { acc, instance in
            guard let chore = chores.first(where: { $0.id == instance.choreId }) else { return }
            acc += chore.points
        }

        let meetsXP = earnedXP >= ruleSet.requiredDailyXP

        switch ruleSet.policy {
        case .off:
            unlockStatus = .unlocked
        case .scheduleOnly:
            if isWithinDailyWindow(now: Date(), startMinutes: ruleSet.unlockWindowStartMinutes, endMinutes: ruleSet.unlockWindowEndMinutes) {
                unlockStatus = .unlocked
            } else {
                unlockStatus = .locked(reason: scheduleLockedReason(now: Date()))
            }
        case .approvedOnlyWindow:
            let withinWindow = isWithinDailyWindow(now: Date(), startMinutes: ruleSet.unlockWindowStartMinutes, endMinutes: ruleSet.unlockWindowEndMinutes)
            var store = ScreenTimeSharedStore()
            store.approvedWindowIsActive = withinWindow
            unlockStatus = withinWindow ? .locked(reason: "Approved apps only") : .unlocked
        case .lockUntilGoalsMet:
            if allApproved && learningMet && meetsXP {
                unlockStatus = .unlocked
            } else {
                let reason: String
                if !meetsXP {
                    reason = "Earn \(ruleSet.requiredDailyXP) XP today"
                } else if !allApproved {
                    reason = "Finish + get chores approved"
                } else {
                    reason = "Finish learning goals"
                }
                unlockStatus = .locked(reason: reason)
            }
        }

        // Keep device restrictions in sync with the current unlock status.
        screenTimeService.applyLockedState(unlockStatus != .unlocked)
    }

    func startBackgroundRefreshIfNeeded() {
        guard refreshTask == nil else { return }

        refreshTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                await self.pullLearningSecondsFromSharedStore()
                self.refreshUnlockStatus()
                try? await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }

    private func pullLearningSecondsFromSharedStore() {
        var store = ScreenTimeSharedStore()
        let secondsToday = store.learningSecondsToday
        guard secondsToday != lastAppliedLearningSecondsToday else { return }
        lastAppliedLearningSecondsToday = secondsToday

        applyLearningSecondsToday(secondsToday)
    }

    private func applyLearningSecondsToday(_ totalSeconds: Int) {
        // Placeholder mapping: allocate today's learning time across goals sequentially.
        var remaining = max(0, totalSeconds)
        for idx in learningGoals.indices {
            let target = max(0, learningGoals[idx].targetSeconds)
            let applied = min(target, remaining)
            learningGoals[idx].progressSeconds = applied
            remaining -= applied
        }
        refreshUnlockStatus()
    }

    private func isWithinDailyWindow(now: Date, startMinutes: Int, endMinutes: Int) -> Bool {
        let minutesNow = minutesSinceMidnight(now)
        let start = max(0, min(23 * 60 + 59, startMinutes))
        let end = max(0, min(23 * 60 + 59, endMinutes))

        if start == end {
            return false
        }
        if start < end {
            return minutesNow >= start && minutesNow < end
        }
        // Overnight window (e.g., 22:00 - 06:00)
        return minutesNow >= start || minutesNow < end
    }

    private func minutesSinceMidnight(_ date: Date) -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        return max(0, min(23 * 60 + 59, (comps.hour ?? 0) * 60 + (comps.minute ?? 0)))
    }

    private func scheduleLockedReason(now: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let startDate = Calendar.current.date(bySettingHour: ruleSet.unlockWindowStartMinutes / 60, minute: ruleSet.unlockWindowStartMinutes % 60, second: 0, of: now) ?? now
        return "Locked until \(formatter.string(from: startDate))"
    }

    private func persistSnapshot() {
        let snapshot = SyncService.AppSnapshot(
            activeModeRaw: activeMode.rawValue,
            childProfile: childProfile,
            chores: chores,
            choreInstances: choreInstances,
            learningGoals: learningGoals,
            ruleSet: ruleSet,
            parentOverride: parentOverride
        )
        syncService.saveSnapshot(snapshot)
    }
}

enum UnlockStatus: Equatable {
    case locked(reason: String)
    case unlocked
}

// Screen Time frameworks are iOS-only. This keeps the project compiling in non-iOS tooling.
#if canImport(FamilyControls)
import FamilyControls
#else
struct FamilyActivitySelection: Equatable {
    init() {}
}
#endif

private extension Date {
    var isToday: Bool { Calendar.current.isDateInToday(self) }
}
