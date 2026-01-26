import Foundation

public enum X6EventKind {
    case redFlagDetected
    case escalated(from: RiskLevel, to: RiskLevel)
    case deescalated(from: RiskLevel, to: RiskLevel)
    case consecutiveHigh(count: Int)
}

public struct X6Event: Identifiable, Hashable {
    public let id: UUID
    public let when: Date
    public let kind: String
    public let title: String
    public let detail: String?
    
    public init(id: UUID = UUID(), when: Date, kind: String, title: String, detail: String?) {
        self.id = id
        self.when = when
        self.kind = kind
        self.title = title
        self.detail = detail
    }
    
    public static func == (lhs: X6Event, rhs: X6Event) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct X6TimelineModel {
    public let period: DateInterval?
    public let events: [X6Event]
    
    public init(period: DateInterval?, events: [X6Event]) {
        self.period = period
        self.events = events
    }
}

