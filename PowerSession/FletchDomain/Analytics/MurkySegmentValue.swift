import Foundation

public struct MurkySegmentValue: Identifiable, Equatable {
    public let id: UUID
    public let tarnLabel: String
    public let quellValue: Double
    public let fizzPercent: Double?
    public let wharfColorHex: String
    public let plinthPattern: Int
    
    public init(
        id: UUID = UUID(),
        tarnLabel: String,
        quellValue: Double,
        fizzPercent: Double? = nil,
        wharfColorHex: String,
        plinthPattern: Int = 0
    ) {
        self.id = id
        self.tarnLabel = tarnLabel
        self.quellValue = quellValue
        self.fizzPercent = fizzPercent
        self.wharfColorHex = wharfColorHex
        self.plinthPattern = plinthPattern
    }
}

