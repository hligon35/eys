import Foundation

@MainActor
final class SyncService {
    enum SyncState {
        case idle
        case syncing
        case failed(String)
    }

    private(set) var state: SyncState = .idle

    private let snapshotKey = "eys_app_snapshot_v1"

    private var defaults: UserDefaults {
        UserDefaults(suiteName: ScreenTimeSharedStore.suiteName) ?? .standard
    }

    struct AppSnapshot: Codable {
        var activeModeRaw: String
        var childProfile: ChildProfile
        var chores: [Chore]
        var choreInstances: [ChoreInstance]
        var learningGoals: [LearningGoal]
        var ruleSet: RuleSet
        var parentOverride: AppState.ParentOverride

        init(activeModeRaw: String, childProfile: ChildProfile, chores: [Chore], choreInstances: [ChoreInstance], learningGoals: [LearningGoal], ruleSet: RuleSet, parentOverride: AppState.ParentOverride) {
            self.activeModeRaw = activeModeRaw
            self.childProfile = childProfile
            self.chores = chores
            self.choreInstances = choreInstances
            self.learningGoals = learningGoals
            self.ruleSet = ruleSet
            self.parentOverride = parentOverride
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            activeModeRaw = try container.decode(String.self, forKey: .activeModeRaw)
            childProfile = try container.decode(ChildProfile.self, forKey: .childProfile)
            chores = try container.decode([Chore].self, forKey: .chores)
            choreInstances = try container.decode([ChoreInstance].self, forKey: .choreInstances)
            learningGoals = try container.decode([LearningGoal].self, forKey: .learningGoals)
            ruleSet = try container.decode(RuleSet.self, forKey: .ruleSet)
            parentOverride = (try? container.decode(AppState.ParentOverride.self, forKey: .parentOverride)) ?? .none
        }
    }

    func loadSnapshot() -> AppSnapshot? {
        guard let data = defaults.data(forKey: snapshotKey) else { return nil }
        return try? JSONDecoder().decode(AppSnapshot.self, from: data)
    }

    func saveSnapshot(_ snapshot: AppSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: snapshotKey)
    }

    func syncNow() async {
        // Placeholder for CloudKit/Firebase/etc.
        state = .syncing
        try? await Task.sleep(nanoseconds: 450_000_000)
        state = .idle
    }
}
