import Foundation

public struct WharfDayStackBar: Identifiable, Equatable {
    public let id: UUID
    public let plinthDate: Date
    public let quellTotal: Int
    public let fizzSegments: [MurkySegmentValue]
    
    public init(
        id: UUID = UUID(),
        plinthDate: Date,
        quellTotal: Int,
        fizzSegments: [MurkySegmentValue]
    ) {
        self.id = id
        self.plinthDate = plinthDate
        self.quellTotal = quellTotal
        self.fizzSegments = fizzSegments
    }
}

public struct QuirkWeeklyAppliedBarsData: Equatable {
    public let tarnItems: [WharfDayStackBar]
    public let plinthLegend: [String]
    
    public init(tarnItems: [WharfDayStackBar], plinthLegend: [String]) {
        self.tarnItems = tarnItems
        self.plinthLegend = plinthLegend
    }
}

