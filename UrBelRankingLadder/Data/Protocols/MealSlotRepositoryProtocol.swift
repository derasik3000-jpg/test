import Foundation

protocol MealSlotRepositoryProtocol {
    func fetchRecords(dayIdentifier: String, timeSlotRaw: String) async throws -> [MealSlotRecordDTO]
    func upsertRecord(dayIdentifier: String, timeSlotRaw: String, ingredientRef: UUID, portionAmount: Double) async throws
    func removeRecord(recordIdentifier: UUID) async throws
    func clearTimeSlot(dayIdentifier: String, timeSlotRaw: String) async throws
}

