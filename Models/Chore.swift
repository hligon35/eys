import Foundation

struct Chore: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var details: String
    var points: Int
    var schedule: Schedule
    var dueDate: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case details
        case schedule
        case points
        case isLearning
        case dueDate
    }

    init(id: UUID = UUID(), title: String, details: String, schedule: Schedule, points: Int, isLearning: Bool, dueDate: Date?) {
        self.id = id
        self.title = title
        self.details = details
        self.schedule = schedule
        self.points = points
        self.isLearning = isLearning
        self.dueDate = dueDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        details = (try? container.decode(String.self, forKey: .details)) ?? ""
        schedule = try container.decode(Schedule.self, forKey: .schedule)
        points = (try? container.decode(Int.self, forKey: .points)) ?? 0
        isLearning = (try? container.decode(Bool.self, forKey: .isLearning)) ?? false
        dueDate = try? container.decode(Date.self, forKey: .dueDate)
    }

    enum Schedule: String, Codable, CaseIterable {
        case daily
        case weekdays
        case weekends
        case oneOff
    }

    static let mockList: [Chore] = [
        Chore(id: UUID(), title: "Make bed", details: "Tidy sheets + pillows", points: 10, schedule: .daily, dueDate: nil),
        Chore(id: UUID(), title: "Homework", details: "Complete assignments", points: 25, schedule: .weekdays, dueDate: nil),
        Chore(id: UUID(), title: "Clean room", details: "Floor + desk", points: 30, schedule: .weekends, dueDate: nil)
    ]
}
