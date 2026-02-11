import Foundation

@MainActor
final class LearningGoalService {
    func createGoal(title: String, targetMinutes: Int) -> LearningGoal {
        LearningGoal(id: UUID(), title: title, targetSeconds: targetMinutes * 60, progressSeconds: 0)
    }

    func updateProgress(goal: LearningGoal, newProgressSeconds: Int) -> LearningGoal {
        var updated = goal
        updated.progressSeconds = max(0, newProgressSeconds)
        return updated
    }
}
