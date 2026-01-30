import Foundation

public struct SternGoalCoverageDonutData: Equatable {
    public let quellTotalApplied: Int
    public let fizzSlices: [MurkySegmentValue]
    
    public init(quellTotalApplied: Int, fizzSlices: [MurkySegmentValue]) {
        self.quellTotalApplied = quellTotalApplied
        self.fizzSlices = fizzSlices
    }
}

