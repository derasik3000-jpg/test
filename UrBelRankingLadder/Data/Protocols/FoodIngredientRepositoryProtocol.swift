import Foundation

protocol FoodIngredientRepositoryProtocol {
    func fetchByCategory(categoryRaw: String) async throws -> [FoodIngredientDTO]
    func searchIngredients(queryText: String?) async throws -> [FoodIngredientDTO]
    func createCustomIngredient(titleText: String, descriptionHint: String?, categoryRaw: String) async throws -> FoodIngredientDTO
    func removeCustomIngredient(identifier: UUID) async throws
}

