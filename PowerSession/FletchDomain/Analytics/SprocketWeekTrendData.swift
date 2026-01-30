import Foundation

public struct SprocketWeekTrendPoint: Identifiable, Equatable {
    public let id: UUID
    public let plinthWeekStart: Date
    public let quellDaysWithApplied: Int
    public let fizzPercentDays: Int
    
    public init(
        id: UUID = UUID(),
        plinthWeekStart: Date,
        quellDaysWithApplied: Int,
        fizzPercentDays: Int
    ) {
        self.id = id
        self.plinthWeekStart = plinthWeekStart
        self.quellDaysWithApplied = quellDaysWithApplied
        self.fizzPercentDays = fizzPercentDays
    }
}

public struct VexWeeksTrendTimelineData: Equatable {
    public let tarnPoints: [SprocketWeekTrendPoint]
    
    public init(tarnPoints: [SprocketWeekTrendPoint]) {
        self.tarnPoints = tarnPoints
    }
}

