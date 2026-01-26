import Foundation

public struct RiskSlice: Hashable {
    public let level: RiskLevel
    public let count: Int
    
    public init(level: RiskLevel, count: Int) {
        self.level = level
        self.count = count
    }
}

public struct RiskPieModel {
    public let period: DateInterval
    public let slices: [RiskSlice]
    public var total: Int { slices.reduce(0) { $0 + $1.count } }
    
    public init(period: DateInterval, slices: [RiskSlice]) {
        self.period = period
        self.slices = slices
    }
}

