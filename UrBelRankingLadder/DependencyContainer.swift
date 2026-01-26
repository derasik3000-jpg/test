import Foundation

final class DependencyContainer {
    static let shared = DependencyContainer()
    
    private let coreDataStack = CoreDataStackProvider.shared
    
    lazy var foodIngredientRepository: FoodIngredientRepositoryProtocol = {
        FoodIngredientRepositoryImpl(coreDataStack: coreDataStack)
    }()
    
    lazy var mealSlotRepository: MealSlotRepositoryProtocol = {
        MealSlotRepositoryImpl(coreDataStack: coreDataStack)
    }()
    
    lazy var savedTemplateRepository: SavedTemplateRepositoryProtocol = {
        SavedTemplateRepositoryImpl(coreDataStack: coreDataStack)
    }()
    
    lazy var dailyMetricsRepository: DailyMetricsRepositoryProtocol = {
        DailyMetricsRepositoryImpl(coreDataStack: coreDataStack)
    }()
    
    lazy var userConfigRepository: UserConfigurationRepositoryProtocol = {
        UserConfigurationRepositoryImpl(coreDataStack: coreDataStack)
    }()
    
    lazy var balanceService: BalanceCalculationServiceProtocol = {
        BalanceCalculationServiceImpl()
    }()
    
    lazy var chartBuilderService: ChartBuilderServiceProtocol = {
        ChartBuilderServiceImpl()
    }()
    
    lazy var templateService: TemplateManagementServiceProtocol = {
        TemplateManagementServiceImpl()
    }()
    
    lazy var exportService: TextFileExportServiceProtocol = {
        TextFileExportServiceImpl()
    }()
    
    lazy var aggregationService: DailyAggregationServiceProtocol = {
        DailyAggregationServiceImpl()
    }()
    
    lazy var buildPlateUseCase: BuildPlateVisualizationUseCase = {
        BuildPlateVisualizationUseCase(
            slotRepository: mealSlotRepository,
            ingredientRepository: foodIngredientRepository,
            balanceService: balanceService,
            chartBuilder: chartBuilderService
        )
    }()
    
    lazy var addIngredientUseCase: AddIngredientToSlotUseCase = {
        AddIngredientToSlotUseCase(
            slotRepository: mealSlotRepository,
            ingredientRepository: foodIngredientRepository,
            metricsRepository: dailyMetricsRepository,
            balanceService: balanceService,
            aggregationService: aggregationService
        )
    }()
    
    lazy var applyTemplateUseCase: ApplySavedTemplateUseCase = {
        ApplySavedTemplateUseCase(
            templateService: templateService,
            slotRepository: mealSlotRepository,
            ingredientRepository: foodIngredientRepository,
            metricsRepository: dailyMetricsRepository,
            balanceService: balanceService,
            aggregationService: aggregationService
        )
    }()
    
    lazy var exportDayUseCase: ExportDayReportUseCase = {
        ExportDayReportUseCase(
            metricsRepository: dailyMetricsRepository,
            slotRepository: mealSlotRepository,
            ingredientRepository: foodIngredientRepository,
            exportService: exportService
        )
    }()
    
    lazy var weeklyUseCase: FetchWeeklySummaryUseCase = {
        FetchWeeklySummaryUseCase(
            metricsRepository: dailyMetricsRepository,
            chartBuilder: chartBuilderService
        )
    }()
    
    lazy var clearSlotUseCase: ClearSlotAndRecomputeUseCase = {
        ClearSlotAndRecomputeUseCase(
            slotRepository: mealSlotRepository,
            ingredientRepository: foodIngredientRepository,
            metricsRepository: dailyMetricsRepository,
            balanceService: balanceService,
            aggregationService: aggregationService
        )
    }()
    
    @MainActor func makePlateViewModel() -> PlateConstructorViewModel {
        PlateConstructorViewModel(
            buildPlateUseCase: buildPlateUseCase,
            addIngredientUseCase: addIngredientUseCase,
            clearSlotUseCase: clearSlotUseCase,
            slotRepository: mealSlotRepository,
            configRepository: userConfigRepository
        )
    }
    
    @MainActor func makeIngredientsViewModel() -> IngredientsListViewModel {
        IngredientsListViewModel(ingredientRepository: foodIngredientRepository)
    }
    
    @MainActor func makeTemplateViewModel() -> TemplateLibraryViewModel {
        TemplateLibraryViewModel(
            templateRepository: savedTemplateRepository,
            applyTemplateUseCase: applyTemplateUseCase,
            slotRepository: mealSlotRepository,
            templateService: templateService
        )
    }
    
    @MainActor func makeDaySummaryViewModel() -> DaySummaryViewModel {
        DaySummaryViewModel(
            metricsRepository: dailyMetricsRepository,
            chartBuilder: chartBuilderService,
            exportUseCase: exportDayUseCase,
            weeklyUseCase: weeklyUseCase
        )
    }
    
    private init() {}
}

