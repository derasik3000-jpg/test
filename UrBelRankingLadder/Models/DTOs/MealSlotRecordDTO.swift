import Foundation

public struct MealSlotRecordDTO: Identifiable, Hashable, Codable {
    public let id: UUID
    public let dayIdentifier: String
    public let timeSlotRaw: String
    public let ingredientRef: UUID
    public let portionAmount: Double
    
    public init(id: UUID, dayIdentifier: String, timeSlotRaw: String, ingredientRef: UUID, portionAmount: Double) {
        self.id = id
        self.dayIdentifier = dayIdentifier
        self.timeSlotRaw = timeSlotRaw
        self.ingredientRef = ingredientRef
        self.portionAmount = portionAmount
    }
}

