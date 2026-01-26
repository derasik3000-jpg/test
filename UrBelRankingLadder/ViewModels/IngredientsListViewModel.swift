import Foundation
import Combine
@MainActor
final class IngredientsListViewModel: ObservableObject {
    @Published var vegetables: [FoodIngredientDTO] = []
    @Published var proteins: [FoodIngredientDTO] = []
    @Published var carbs: [FoodIngredientDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let ingredientRepository: FoodIngredientRepositoryProtocol
    
    init(ingredientRepository: FoodIngredientRepositoryProtocol) {
        self.ingredientRepository = ingredientRepository
    }
    
    func loadAllIngredients() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            vegetables = try await ingredientRepository.fetchByCategory(categoryRaw: "vegetable")
            proteins = try await ingredientRepository.fetchByCategory(categoryRaw: "protein")
            carbs = try await ingredientRepository.fetchByCategory(categoryRaw: "carb")
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addCustomIngredient(title: String, description: String?, category: String) async {
        do {
            _ = try await ingredientRepository.createCustomIngredient(
                titleText: title,
                descriptionHint: description,
                categoryRaw: category
            )
            await loadAllIngredients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

