import Foundation

final class BuildPlateVisualizationUseCase {
    private let slotRepository: MealSlotRepositoryProtocol
    private let ingredientRepository: FoodIngredientRepositoryProtocol
    private let balanceService: BalanceCalculationServiceProtocol
    private let chartBuilder: ChartBuilderServiceProtocol
    
    init(
        slotRepository: MealSlotRepositoryProtocol,
        ingredientRepository: FoodIngredientRepositoryProtocol,
        balanceService: BalanceCalculationServiceProtocol,
        chartBuilder: ChartBuilderServiceProtocol
    ) {
        self.slotRepository = slotRepository
        self.ingredientRepository = ingredientRepository
        self.balanceService = balanceService
        self.chartBuilder = chartBuilder
    }
    
    func execute(dayIdentifier: String, timeSlotRaw: String) async throws -> MealPlateVisualizationDTO {
        let records = try await slotRepository.fetchRecords(dayIdentifier: dayIdentifier, timeSlotRaw: timeSlotRaw)
        let allIngredients = try await ingredientRepository.searchIngredients(queryText: nil)
        
        let ingredientLookup: (UUID) -> FoodIngredientDTO? = { id in
            allIngredients.first { $0.id == id }
        }
        
        let totals = balanceService.calculateTotals(from: records, ingredientLookup: ingredientLookup)
        let result = balanceService.calculateBalance(for: totals)
        
        return chartBuilder.buildMealPlateVisualization(
            dayIdentifier: dayIdentifier,
            timeSlotRaw: timeSlotRaw,
            totals: totals,
            balanceMetric: result.balanceMetric,
            suggestionText: result.suggestionText,
            hasGoldQuality: result.isPerfectBalance
        )
    }
}

