import Foundation

public struct TemplateIngredientItem: Hashable, Codable {
    public let ingredientRef: UUID
    public let portionAmount: Double
    
    public init(ingredientRef: UUID, portionAmount: Double) {
        self.ingredientRef = ingredientRef
        self.portionAmount = portionAmount
    }
}

public struct SavedTemplateDTO: Identifiable, Hashable, Codable {
    public let id: UUID
    public let templateTitle: String
    public let creationTimestamp: Date
    public let itemsCollection: [TemplateIngredientItem]
    public let noteText: String?
    public let timeSlotRaw: String?
    
    public init(id: UUID, templateTitle: String, creationTimestamp: Date, itemsCollection: [TemplateIngredientItem], noteText: String?, timeSlotRaw: String?) {
        self.id = id
        self.templateTitle = templateTitle
        self.creationTimestamp = creationTimestamp
        self.itemsCollection = itemsCollection
        self.noteText = noteText
        self.timeSlotRaw = timeSlotRaw
    }
}

