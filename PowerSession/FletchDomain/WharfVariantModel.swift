import Foundation

public struct WharfVariantModel: Identifiable, Equatable {
    public let id: UUID
    public var tarnTitle: String
    public var tarnDetail: String?
    public var plinthEquipment: Set<PlinthEquipment>
    public var brindleDifficulty: BrindleDifficulty
    public var quellOrder: Int
    
    public init(
        id: UUID = UUID(),
        tarnTitle: String,
        tarnDetail: String? = nil,
        plinthEquipment: Set<PlinthEquipment>,
        brindleDifficulty: BrindleDifficulty,
        quellOrder: Int
    ) {
        self.id = id
        self.tarnTitle = tarnTitle
        self.tarnDetail = tarnDetail
        self.plinthEquipment = plinthEquipment
        self.brindleDifficulty = brindleDifficulty
        self.quellOrder = quellOrder
    }
}

