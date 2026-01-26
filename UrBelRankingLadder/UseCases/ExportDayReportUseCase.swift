import Foundation

final class ExportDayReportUseCase {
    private let metricsRepository: DailyMetricsRepositoryProtocol
    private let slotRepository: MealSlotRepositoryProtocol
    private let ingredientRepository: FoodIngredientRepositoryProtocol
    private let exportService: TextFileExportServiceProtocol
    
    init(
        metricsRepository: DailyMetricsRepositoryProtocol,
        slotRepository: MealSlotRepositoryProtocol,
        ingredientRepository: FoodIngredientRepositoryProtocol,
        exportService: TextFileExportServiceProtocol
    ) {
        self.metricsRepository = metricsRepository
        self.slotRepository = slotRepository
        self.ingredientRepository = ingredientRepository
        self.exportService = exportService
    }
    
    func execute(dayIdentifier: String) async throws -> String {
        guard let metrics = try await metricsRepository.fetchMetrics(dayIdentifier: dayIdentifier) else {
            return ""
        }
        
        let allSlots = ["morning", "noon", "evening", "snack"]
        var slotRecords: [String: [MealSlotRecordDTO]] = [:]
        
        for slot in allSlots {
            slotRecords[slot] = try await slotRepository.fetchRecords(dayIdentifier: dayIdentifier, timeSlotRaw: slot)
        }
        
        let allIngredients = try await ingredientRepository.searchIngredients(queryText: nil)
        let ingredientLookup: (UUID) -> FoodIngredientDTO? = { id in
            allIngredients.first { $0.id == id }
        }
        
        let reportText = exportService.generateDayReport(
            metrics: metrics,
            slotRecords: slotRecords,
            ingredientLookup: ingredientLookup
        )
        
        try await exportService.saveAndShareFile(fileName: "UrBelRL_\(dayIdentifier).txt", content: reportText)
        
        return reportText
    }
}

