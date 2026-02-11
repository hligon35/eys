import Foundation

struct ChoreInstance: Identifiable, Codable, Equatable {
    var id: UUID
    var choreId: UUID
    var scheduledDate: Date
    var status: Status
    var submittedAt: Date?
    var proof: Proof?

    enum Status: String, Codable, CaseIterable {
        case todo
        case submitted
        case approved
        case rejected
    }

    struct Proof: Codable, Equatable {
        enum Kind: String, Codable {
            case photo
            case video
        }
        var kind: Kind
        var placeholderURLString: String
    }

    static let mockToday: [ChoreInstance] = {
        let today = Date()
        return [
            ChoreInstance(id: UUID(), choreId: Chore.mockList[0].id, scheduledDate: today, status: .todo, submittedAt: nil, proof: nil),
            ChoreInstance(id: UUID(), choreId: Chore.mockList[1].id, scheduledDate: today, status: .submitted, submittedAt: today, proof: .init(kind: .photo, placeholderURLString: "placeholder://photo")),
            ChoreInstance(id: UUID(), choreId: Chore.mockList[2].id, scheduledDate: today, status: .approved, submittedAt: today, proof: .init(kind: .video, placeholderURLString: "placeholder://video"))
        ]
    }()
}
