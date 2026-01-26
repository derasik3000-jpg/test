import CoreData
import Foundation

final class FoodIngredientRepositoryImpl: FoodIngredientRepositoryProtocol {
    private let coreDataStack: CoreDataStackProvider
    
    init(coreDataStack: CoreDataStackProvider = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    func fetchByCategory(categoryRaw: String) async throws -> [FoodIngredientDTO] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDFoodIngredient.fetchRequest()
            request.predicate = NSPredicate(format: "categoryRaw == %@", categoryRaw)
            request.sortDescriptors = [
                NSSortDescriptor(key: "isUserCreated", ascending: false),
                NSSortDescriptor(key: "titleText", ascending: true)
            ]
            
            let results = try context.fetch(request)
            return results.map { self.mapToDTO($0) }
        }
    }
    
    func searchIngredients(queryText: String?) async throws -> [FoodIngredientDTO] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = CDFoodIngredient.fetchRequest()
            if let query = queryText, !query.isEmpty {
                request.predicate = NSPredicate(format: "titleText CONTAINS[cd] %@", query)
            }
            request.sortDescriptors = [
                NSSortDescriptor(key: "isUserCreated", ascending: false),
                NSSortDescriptor(key: "titleText", ascending: true)
            ]
            
            let results = try context.fetch(request)
            return results.map { self.mapToDTO($0) }
        }
    }
    
    func createCustomIngredient(titleText: String, descriptionHint: String?, categoryRaw: String) async throws -> FoodIngredientDTO {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let ingredient = CDFoodIngredient(context: context)
            ingredient.identifier = UUID()
            ingredient.titleText = titleText
            ingredient.descriptionHint = descriptionHint
            ingredient.categoryRaw = categoryRaw
            ingredient.isUserCreated = true
            
            try context.save()
            return self.mapToDTO(ingredient)
        }
    }
    
    func removeCustomIngredient(identifier: UUID) async throws {
        let context = coreDataStack.viewContext
        try await context.perform {
            let request = CDFoodIngredient.fetchRequest()
            request.predicate = NSPredicate(format: "identifier == %@ AND isUserCreated == YES", identifier as CVarArg)
            
            if let ingredient = try context.fetch(request).first {
                context.delete(ingredient)
                try context.save()
            }
        }
    }
    
    private func mapToDTO(_ entity: CDFoodIngredient) -> FoodIngredientDTO {
        FoodIngredientDTO(
            id: entity.identifier!,
            titleText: entity.titleText!,
            descriptionHint: entity.descriptionHint,
            categoryRaw: entity.categoryRaw!,
            isUserCreated: entity.isUserCreated
        )
    }
}

