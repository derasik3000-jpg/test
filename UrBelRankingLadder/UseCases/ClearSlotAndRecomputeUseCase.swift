import Foundation

final class ClearSlotAndRecomputeUseCase {
    private let slotRepository: MealSlotRepositoryProtocol
    private let ingredientRepository: FoodIngredientRepositoryProtocol
    private let metricsRepository: DailyMetricsRepositoryProtocol
    private let balanceService: BalanceCalculationServiceProtocol
    private let aggregationService: DailyAggregationServiceProtocol
    
    init(
        slotRepository: MealSlotRepositoryProtocol,
        ingredientRepository: FoodIngredientRepositoryProtocol,
        metricsRepository: DailyMetricsRepositoryProtocol,
        balanceService: BalanceCalculationServiceProtocol,
        aggregationService: DailyAggregationServiceProtocol
    ) {
        self.slotRepository = slotRepository
        self.ingredientRepository = ingredientRepository
        self.metricsRepository = metricsRepository
        self.balanceService = balanceService
        self.aggregationService = aggregationService
    }
    
    func execute(dayIdentifier: String, timeSlotRaw: String) async throws {
        try await slotRepository.clearTimeSlot(dayIdentifier: dayIdentifier, timeSlotRaw: timeSlotRaw)
        
        let allSlots = ["morning", "noon", "evening", "snack"]
        var slotRecords: [String: [MealSlotRecordDTO]] = [:]
        
        for slot in allSlots {
            slotRecords[slot] = try await slotRepository.fetchRecords(dayIdentifier: dayIdentifier, timeSlotRaw: slot)
        }
        
        let allIngredients = try await ingredientRepository.searchIngredients(queryText: nil)
        let ingredientLookup: (UUID) -> FoodIngredientDTO? = { id in
            allIngredients.first { $0.id == id }
        }
        
        let metrics = aggregationService.recomputeDayMetrics(
            dayIdentifier: dayIdentifier,
            slotRecords: slotRecords,
            ingredientLookup: ingredientLookup,
            balanceService: balanceService
        )
        
        try await metricsRepository.upsertMetrics(metrics)
    }
}


