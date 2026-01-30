import Foundation

public struct SprocketAppliedLogModel: Identifiable, Equatable {
    public let id: UUID
    public var plinthDate: Date
    public var quirkReplacement: FizzReplacementModel
    public var quirkVariant: WharfVariantModel?
    public var tarnNote: String?
    
    public init(
        id: UUID = UUID(),
        plinthDate: Date,
        quirkReplacement: FizzReplacementModel,
        quirkVariant: WharfVariantModel? = nil,
        tarnNote: String? = nil
    ) {
        self.id = id
        self.plinthDate = plinthDate
        self.quirkReplacement = quirkReplacement
        self.quirkVariant = quirkVariant
        self.tarnNote = tarnNote
    }
}

