import Foundation

protocol TemplateManagementServiceProtocol {
    func extractTemplateItems(from records: [MealSlotRecordDTO]) -> [TemplateIngredientItem]
    func applyTemplateToSlot(_ template: SavedTemplateDTO, dayIdentifier: String, timeSlotRaw: String, slotRepository: MealSlotRepositoryProtocol) async throws
}

final class TemplateManagementServiceImpl: TemplateManagementServiceProtocol {
    func extractTemplateItems(from records: [MealSlotRecordDTO]) -> [TemplateIngredientItem] {
        return records.map {
            TemplateIngredientItem(ingredientRef: $0.ingredientRef, portionAmount: $0.portionAmount)
        }
    }
    
    func applyTemplateToSlot(_ template: SavedTemplateDTO, dayIdentifier: String, timeSlotRaw: String, slotRepository: MealSlotRepositoryProtocol) async throws {
        try await slotRepository.clearTimeSlot(dayIdentifier: dayIdentifier, timeSlotRaw: timeSlotRaw)
        
        for item in template.itemsCollection {
            try await slotRepository.upsertRecord(
                dayIdentifier: dayIdentifier,
                timeSlotRaw: timeSlotRaw,
                ingredientRef: item.ingredientRef,
                portionAmount: item.portionAmount
            )
        }
    }
}

