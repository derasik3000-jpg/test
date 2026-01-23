import Foundation

struct Badge: Identifiable, Equatable {
    let id: UUID
    let weekId: UUID
    let kind: Int16
    let achievedAt: Date
    
    init(id: UUID = UUID(), weekId: UUID, kind: Int16, achievedAt: Date = Date()) {
        self.id = id
        self.weekId = weekId
        self.kind = kind
        self.achievedAt = achievedAt
    }
}

enum BadgeKind: Int16 {
    case balanced = 0
}

