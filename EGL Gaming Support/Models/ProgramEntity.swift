import Foundation

struct GamingStep: Codable {
    var level: String
    var rank: String
    var action: String
    var completed: Bool
}

struct GamingProgramDraft {
    var name: String
    var steps: [GamingStep]
    var imageData: Data?
}

struct GamingProgram {
    let id: UUID
    var name: String
    var steps: [GamingStep]
    var imageData: Data?
    let createdAt: Date
    var updatedAt: Date
}

