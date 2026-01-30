import Foundation

public struct BrindleDurationBarsData: Equatable {
    public struct FizzBandBar: Identifiable, Equatable {
        public let id: UUID
        public let plinthBand: SternDurationBand
        public let quellCount: Int
        public let fizzPercent: Double
        
        public init(id: UUID = UUID(), plinthBand: SternDurationBand, quellCount: Int, fizzPercent: Double) {
            self.id = id
            self.plinthBand = plinthBand
            self.quellCount = quellCount
            self.fizzPercent = fizzPercent
        }
    }
    
    public let tarnItems: [FizzBandBar]
    
    public init(tarnItems: [FizzBandBar]) {
        self.tarnItems = tarnItems
    }
}

