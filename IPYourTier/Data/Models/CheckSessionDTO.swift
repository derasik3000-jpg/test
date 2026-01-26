import Foundation

public struct CheckSessionDTO: Identifiable {
    public let id: UUID
    public let createdAt: Date
    public let status: Int
    public let zone: ZoneDTO
    
    public let painMove: Int
    public let painRest: Bool
    public let popSound: Bool
    public let edema: Bool
    public let heat: Bool
    public let instability: Bool
    public let romPercent: Int
    public let painNRS: Int
    public let morningStiffness: Bool
    public let betterWithLoadReduction: Int
    public let symptomStart: Int
    public let redFlag: Bool
    
    public let riskScore: Int
    public let riskLevel: Int
    public let recommendationCode: Int
    
    public let note: String?
    public let reminderAt: Date?
    
    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        status: Int = 0,
        zone: ZoneDTO = .otherArea,
        painMove: Int = 0,
        painRest: Bool = false,
        popSound: Bool = false,
        edema: Bool = false,
        heat: Bool = false,
        instability: Bool = false,
        romPercent: Int = 100,
        painNRS: Int = 0,
        morningStiffness: Bool = false,
        betterWithLoadReduction: Int = -1,
        symptomStart: Int = 0,
        redFlag: Bool = false,
        riskScore: Int = 0,
        riskLevel: Int = 0,
        recommendationCode: Int = 0,
        note: String? = nil,
        reminderAt: Date? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.status = status
        self.zone = zone
        self.painMove = painMove
        self.painRest = painRest
        self.popSound = popSound
        self.edema = edema
        self.heat = heat
        self.instability = instability
        self.romPercent = romPercent
        self.painNRS = painNRS
        self.morningStiffness = morningStiffness
        self.betterWithLoadReduction = betterWithLoadReduction
        self.symptomStart = symptomStart
        self.redFlag = redFlag
        self.riskScore = riskScore
        self.riskLevel = riskLevel
        self.recommendationCode = recommendationCode
        self.note = note
        self.reminderAt = reminderAt
    }
    
    public var isComplete: Bool {
        return status == 1
    }
    
    public var riskLevelEnum: RiskLevelDTO {
        return RiskLevelDTO(rawValue: riskLevel) ?? .lowRisk
    }
}

