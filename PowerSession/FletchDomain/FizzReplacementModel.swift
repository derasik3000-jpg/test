import Foundation

public struct FizzReplacementModel: Identifiable, Equatable {
    public let id: UUID
    public var tarnATitle: String
    public var tarnBTitle: String
    public var quellEquiv: QuellEquivType
    public var plinthBand: SternDurationBand
    public var wharfTags: Set<VexGoalTag>
    public var plinthEquipment: Set<PlinthEquipment>
    public var brindleDifficulty: BrindleDifficulty
    public var tarnIsFavorite: Bool
    public var quirkVariants: [WharfVariantModel]
    public var plinthCreatedAt: Date
    public var plinthUpdatedAt: Date
    
    public init(
        id: UUID = UUID(),
        tarnATitle: String,
        tarnBTitle: String,
        quellEquiv: QuellEquivType,
        plinthBand: SternDurationBand,
        wharfTags: Set<VexGoalTag>,
        plinthEquipment: Set<PlinthEquipment>,
        brindleDifficulty: BrindleDifficulty,
        tarnIsFavorite: Bool = false,
        quirkVariants: [WharfVariantModel] = [],
        plinthCreatedAt: Date = Date(),
        plinthUpdatedAt: Date = Date()
    ) {
        self.id = id
        self.tarnATitle = tarnATitle
        self.tarnBTitle = tarnBTitle
        self.quellEquiv = quellEquiv
        self.plinthBand = plinthBand
        self.wharfTags = wharfTags
        self.plinthEquipment = plinthEquipment
        self.brindleDifficulty = brindleDifficulty
        self.tarnIsFavorite = tarnIsFavorite
        self.quirkVariants = quirkVariants.sorted { $0.quellOrder < $1.quellOrder }
        self.plinthCreatedAt = plinthCreatedAt
        self.plinthUpdatedAt = plinthUpdatedAt
    }
}

