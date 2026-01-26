import Foundation
import CoreData

@objc(CheckSession)
public class CheckSession: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var status: Int16
    // Renamed from 'zone' to avoid NSObject.zone KVC conflicts
    @NSManaged public var zoneCode: Int16
    
    @NSManaged public var painMove: Int16
    @NSManaged public var painRest: Bool
    @NSManaged public var popSound: Bool
    @NSManaged public var edema: Bool
    @NSManaged public var heat: Bool
    @NSManaged public var instability: Bool
    @NSManaged public var romPercent: Int16
    @NSManaged public var painNRS: Int16
    @NSManaged public var morningStiffness: Bool
    @NSManaged public var betterWithLoadReduction: Int16
    @NSManaged public var symptomStart: Int16
    @NSManaged public var redFlag: Bool
    
    @NSManaged public var riskScore: Int16
    @NSManaged public var riskLevel: Int16
    @NSManaged public var recommendationCode: Int16
    
    @NSManaged public var note: String?
    @NSManaged public var reminderAt: Date?
}

extension CheckSession {
    @nonobjc public class func requestMaterialization() -> NSFetchRequest<CheckSession> {
        return NSFetchRequest<CheckSession>(entityName: "CheckSession")
    }
    
    func toDTO() -> CheckSessionDTO {
        CheckSessionDTO(
            id: id,
            createdAt: createdAt,
            status: Int(status),
            zone: ZoneDTO(rawValue: Int(zoneCode)) ?? .otherArea,
            painMove: Int(painMove),
            painRest: painRest,
            popSound: popSound,
            edema: edema,
            heat: heat,
            instability: instability,
            romPercent: Int(romPercent),
            painNRS: Int(painNRS),
            morningStiffness: morningStiffness,
            betterWithLoadReduction: Int(betterWithLoadReduction),
            symptomStart: Int(symptomStart),
            redFlag: redFlag,
            riskScore: Int(riskScore),
            riskLevel: Int(riskLevel),
            recommendationCode: Int(recommendationCode),
            note: note,
            reminderAt: reminderAt
        )
    }
    
    func updateFrom(dto: CheckSessionDTO) {
        self.id = dto.id
        self.createdAt = dto.createdAt
        self.status = Int16(dto.status)
        self.zoneCode = Int16(dto.zone.rawValue)
        self.painMove = Int16(dto.painMove)
        self.painRest = dto.painRest
        self.popSound = dto.popSound
        self.edema = dto.edema
        self.heat = dto.heat
        self.instability = dto.instability
        self.romPercent = Int16(dto.romPercent)
        self.painNRS = Int16(dto.painNRS)
        self.morningStiffness = dto.morningStiffness
        self.betterWithLoadReduction = Int16(dto.betterWithLoadReduction)
        self.symptomStart = Int16(dto.symptomStart)
        self.redFlag = dto.redFlag
        self.riskScore = Int16(dto.riskScore)
        self.riskLevel = Int16(dto.riskLevel)
        self.recommendationCode = Int16(dto.recommendationCode)
        self.note = dto.note
        self.reminderAt = dto.reminderAt
    }
}

