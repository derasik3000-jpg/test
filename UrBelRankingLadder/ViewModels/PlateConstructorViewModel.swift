import Foundation
import Combine
@MainActor
final class PlateConstructorViewModel: ObservableObject {
    @Published var currentDayIdentifier: String
    @Published var currentTimeSlot: String
    @Published var plateVisualization: MealPlateVisualizationDTO?
    @Published var slotRecords: [MealSlotRecordDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let buildPlateUseCase: BuildPlateVisualizationUseCase
    private let addIngredientUseCase: AddIngredientToSlotUseCase
    private let clearSlotUseCase: ClearSlotAndRecomputeUseCase
    private let slotRepository: MealSlotRepositoryProtocol
    private let configRepository: UserConfigurationRepositoryProtocol
    private let haptics: HapticFeedbackProvider
    
    init(
        buildPlateUseCase: BuildPlateVisualizationUseCase,
        addIngredientUseCase: AddIngredientToSlotUseCase,
        clearSlotUseCase: ClearSlotAndRecomputeUseCase,
        slotRepository: MealSlotRepositoryProtocol,
        configRepository: UserConfigurationRepositoryProtocol,
        haptics: HapticFeedbackProvider = .shared
    ) {
        self.buildPlateUseCase = buildPlateUseCase
        self.addIngredientUseCase = addIngredientUseCase
        self.clearSlotUseCase = clearSlotUseCase
        self.slotRepository = slotRepository
        self.configRepository = configRepository
        self.haptics = haptics
        self.currentDayIdentifier = String.todayIdentifier()
        self.currentTimeSlot = Date().currentTimeSlot()
    }
    
    func loadPlate() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            plateVisualization = try await buildPlateUseCase.execute(
                dayIdentifier: currentDayIdentifier,
                timeSlotRaw: currentTimeSlot
            )
            
            slotRecords = try await slotRepository.fetchRecords(
                dayIdentifier: currentDayIdentifier,
                timeSlotRaw: currentTimeSlot
            )
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addIngredient(ingredientRef: UUID, portionDelta: Double) async {
        do {
            let config = try await configRepository.loadConfiguration()
            if config.enableHapticFeedback {
                haptics.triggerLightImpact()
            }
            
            try await addIngredientUseCase.execute(
                dayIdentifier: currentDayIdentifier,
                timeSlotRaw: currentTimeSlot,
                ingredientRef: ingredientRef,
                portionDelta: portionDelta
            )
            
            await loadPlate()
            
            if plateVisualization?.hasGoldQuality == true && config.enableHapticFeedback {
                haptics.triggerSuccess()
            }
            NotificationCenter.default.post(name: .dayStatsUpdated, object: currentDayIdentifier)
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearSlot() async {
        do {
            try await clearSlotUseCase.execute(dayIdentifier: currentDayIdentifier, timeSlotRaw: currentTimeSlot)
            await loadPlate()
            
            let config = try await configRepository.loadConfiguration()
            if config.enableHapticFeedback {
                haptics.triggerMediumImpact()
            }
            NotificationCenter.default.post(name: .dayStatsUpdated, object: currentDayIdentifier)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func switchTimeSlot(to slot: String) async {
        currentTimeSlot = slot
        await loadPlate()
    }
}

