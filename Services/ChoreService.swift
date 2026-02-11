import Foundation

@MainActor
final class ChoreService {
    func createChore(title: String, details: String, points: Int, schedule: Chore.Schedule, dueDate: Date? = nil) -> Chore {
        Chore(id: UUID(), title: title, details: details, points: points, schedule: schedule, dueDate: dueDate)
    }

    func scheduleTodayInstances(from chores: [Chore], today: Date = Date()) -> [ChoreInstance] {
        // Create an instance for each chore that applies to the given date.
        chores.compactMap { chore in
            guard choreAppliesToday(chore.schedule, choreDueDate: chore.dueDate, date: today) else { return nil }
            return ChoreInstance(id: UUID(), choreId: chore.id, scheduledDate: today, status: .todo, submittedAt: nil, proof: nil)
        }
    }

    private func choreAppliesToday(_ schedule: Chore.Schedule, choreDueDate: Date?, date: Date) -> Bool {
        switch schedule {
        case .daily:
            return true
        case .weekdays:
            return !Calendar.current.isDateInWeekend(date)
        case .weekends:
            return Calendar.current.isDateInWeekend(date)
        case .oneOff:
            guard let choreDueDate else { return false }
            return Calendar.current.isDate(choreDueDate, inSameDayAs: date)
        }
    }

    func submitProof(instance: ChoreInstance, kind: ChoreInstance.Proof.Kind, proofURLString: String? = nil) -> ChoreInstance {
        var updated = instance
        updated.status = .submitted
        updated.submittedAt = Date()
        updated.proof = .init(kind: kind, placeholderURLString: proofURLString ?? "placeholder://upload")
        return updated
    }

    func approve(instance: ChoreInstance) -> ChoreInstance {
        var updated = instance
        updated.status = .approved
        return updated
    }

    func reject(instance: ChoreInstance) -> ChoreInstance {
        var updated = instance
        updated.status = .rejected
        return updated
    }
}
