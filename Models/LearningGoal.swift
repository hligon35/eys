import Foundation

struct LearningGoal: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var targetSeconds: Int
    var progressSeconds: Int

    var progress: Double {
        guard targetSeconds > 0 else { return 0 }
        return min(1, Double(progressSeconds) / Double(targetSeconds))
    }

    static let mockList: [LearningGoal] = [
        LearningGoal(id: UUID(), title: "Reading", targetSeconds: 20 * 60, progressSeconds: 8 * 60),
        LearningGoal(id: UUID(), title: "Math practice", targetSeconds: 15 * 60, progressSeconds: 12 * 60)
    ]
}
