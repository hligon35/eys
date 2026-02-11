import Foundation

struct ChildProfile: Identifiable, Codable, Equatable {
    var id: UUID
    var displayName: String
    var age: Int

    static let mock = ChildProfile(id: UUID(), displayName: "Avery", age: 10)
}
