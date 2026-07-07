import Foundation

struct DreamEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var tags: String
    var mood: String
    var notes: String
    var dateAdded: Date = Date()
}

struct AppSettings: Codable, Equatable {
    var categoryToggleOne: Bool = true
    var categoryToggleTwo: Bool = true
}
