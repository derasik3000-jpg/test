import CoreData
import Foundation

final class MealSlotRepositoryImpl: MealSlotRepositoryProtocol {
    private let coreDataStack: CoreDataStackProvider
    
    init(coreDataStack: CoreDataStackProvider = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchRecords(dayIdentifier: String, timeSlotRaw: String) async throws -> [MealSlotRecordDTO] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDMealSlotRecord.fetchRequest()
            request.predicate = NSPredicate(format: "dayIdentifier == %@ AND timeSlotRaw == %@", dayIdentifier, timeSlotRaw)
            
            let results = try context.fetch(request)
            return results.map { self.mapToDTO($0) }
        }
    }
    
    func upsertRecord(dayIdentifier: String, timeSlotRaw: String, ingredientRef: UUID, portionAmount: Double) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDMealSlotRecord.fetchRequest()
            request.predicate = NSPredicate(format: "dayIdentifier == %@ AND timeSlotRaw == %@ AND ingredientRef == %@", dayIdentifier, timeSlotRaw, ingredientRef as CVarArg)
            
            let existing = try context.fetch(request).first
            let record = existing ?? CDMealSlotRecord(context: context)
            
            if existing == nil {
                record.recordIdentifier = UUID()
                record.dayIdentifier = dayIdentifier
                record.timeSlotRaw = timeSlotRaw
                record.ingredientRef = ingredientRef
            }
            
            record.portionAmount += portionAmount
            
            if record.portionAmount <= 0 {
                context.delete(record)
            }
            
            try context.save()
        }
    }
    
    func removeRecord(recordIdentifier: UUID) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDMealSlotRecord.fetchRequest()
            request.predicate = NSPredicate(format: "recordIdentifier == %@", recordIdentifier as CVarArg)
            
            if let record = try context.fetch(request).first {
                context.delete(record)
                try context.save()
            }
        }
    }
    
    func clearTimeSlot(dayIdentifier: String, timeSlotRaw: String) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDMealSlotRecord.fetchRequest()
            request.predicate = NSPredicate(format: "dayIdentifier == %@ AND timeSlotRaw == %@", dayIdentifier, timeSlotRaw)
            
            let records = try context.fetch(request)
            for record in records {
                context.delete(record)
            }
            try context.save()
        }
    }
    
    private func mapToDTO(_ entity: CDMealSlotRecord) -> MealSlotRecordDTO {
        MealSlotRecordDTO(
            id: entity.recordIdentifier!,
            dayIdentifier: entity.dayIdentifier!,
            timeSlotRaw: entity.timeSlotRaw!,
            ingredientRef: entity.ingredientRef!,
            portionAmount: entity.portionAmount
        )
    }
}

