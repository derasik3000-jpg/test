import Foundation
import Combine

@MainActor
final class DaySummaryViewModel: ObservableObject {
    @Published var currentDayIdentifier: String
    @Published var dayMetrics: DailyMetricsDTO?
    @Published var dayOverviewDonut: DayOverviewDonutDTO?
    @Published var dayTimeline: DayTimelineVisualizationDTO?
    @Published var weeklyBars: WeeklyBarsVisualizationDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let metricsRepository: DailyMetricsRepositoryProtocol
    private let chartBuilder: ChartBuilderServiceProtocol
    private let exportUseCase: ExportDayReportUseCase
    private let weeklyUseCase: FetchWeeklySummaryUseCase
    private let haptics: HapticFeedbackProvider
    private var notificationObserver: Any?
    
    init(
        metricsRepository: DailyMetricsRepositoryProtocol,
        chartBuilder: ChartBuilderServiceProtocol,
        exportUseCase: ExportDayReportUseCase,
        weeklyUseCase: FetchWeeklySummaryUseCase,
        haptics: HapticFeedbackProvider = .shared
    ) {
        self.metricsRepository = metricsRepository
        self.chartBuilder = chartBuilder
        self.exportUseCase = exportUseCase
        self.weeklyUseCase = weeklyUseCase
        self.haptics = haptics
        self.currentDayIdentifier = String.todayIdentifier()
        self.notificationObserver = NotificationCenter.default.addObserver(forName: .dayStatsUpdated, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            Task { await self.loadDaySummary() }
        }
    }
    
    func loadDaySummary() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let metrics = try await metricsRepository.fetchMetrics(dayIdentifier: currentDayIdentifier) {
                dayMetrics = metrics
                dayOverviewDonut = chartBuilder.buildDayOverviewDonut(dayIdentifier: currentDayIdentifier, metrics: metrics)
                dayTimeline = chartBuilder.buildDayTimeline(metrics)
            }
            
            weeklyBars = try await weeklyUseCase.execute()
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func exportDay() async {
        do {
            _ = try await exportUseCase.execute(dayIdentifier: currentDayIdentifier)
            haptics.triggerSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

