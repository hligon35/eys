import Foundation

struct RuleSet: Codable, Equatable {
    enum LockPolicy: String, Codable, CaseIterable {
        case lockUntilGoalsMet
        case scheduleOnly
        case approvedOnlyWindow
        case off
    }

    var policy: LockPolicy
    var requiredDailyXP: Int

    /// Minutes since midnight local time.
    /// Used when `policy == .scheduleOnly`.
    var unlockWindowStartMinutes: Int
    var unlockWindowEndMinutes: Int

    enum CodingKeys: String, CodingKey {
        case policy
        case requiredDailyXP
        case unlockWindowStartMinutes
        case unlockWindowEndMinutes
    }

    init(policy: LockPolicy, requiredDailyXP: Int, unlockWindowStartMinutes: Int, unlockWindowEndMinutes: Int) {
        self.policy = policy
        self.requiredDailyXP = requiredDailyXP
        self.unlockWindowStartMinutes = unlockWindowStartMinutes
        self.unlockWindowEndMinutes = unlockWindowEndMinutes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        policy = try container.decode(LockPolicy.self, forKey: .policy)
        requiredDailyXP = (try? container.decode(Int.self, forKey: .requiredDailyXP)) ?? 0
        unlockWindowStartMinutes = (try? container.decode(Int.self, forKey: .unlockWindowStartMinutes)) ?? (18 * 60)
        unlockWindowEndMinutes = (try? container.decode(Int.self, forKey: .unlockWindowEndMinutes)) ?? (20 * 60)
    }

    // Default schedule window: 6:00pm - 8:00pm.
    static let mock = RuleSet(
        policy: .lockUntilGoalsMet,
        requiredDailyXP: 50,
        unlockWindowStartMinutes: 18 * 60,
        unlockWindowEndMinutes: 20 * 60
    )
}
