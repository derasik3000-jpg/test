import Foundation

public enum RiskLevel: Int {
    case low = 0
    case medium = 1
    case high = 2
    case red = 3
}

public struct RiskDonutModel: Identifiable {
    public let id: UUID
    public let score: Int
    public let level: RiskLevel
    public let max: Int = 12
    public var ratio: Double { Double(min(score, max)) / Double(max) }
    public let createdAt: Date
    public let zoneName: String
    
    public init(id: UUID, score: Int, level: RiskLevel, createdAt: Date, zoneName: String) {
        self.id = id
        self.score = score
        self.level = level
        self.createdAt = createdAt
        self.zoneName = zoneName
    }
}

