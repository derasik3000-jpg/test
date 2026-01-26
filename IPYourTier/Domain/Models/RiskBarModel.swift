import Foundation

public struct RiskBarPoint: Identifiable, Hashable {
    public let id: UUID
    public let date: Date
    public let level: RiskLevel
    
    public init(id: UUID, date: Date, level: RiskLevel) {
        self.id = id
        self.date = date
        self.level = level
    }
}

public struct RiskBarModel {
    public let period: DateInterval
    public let points: [RiskBarPoint]
    
    public init(period: DateInterval, points: [RiskBarPoint]) {
        self.period = period
        self.points = points
    }
}

