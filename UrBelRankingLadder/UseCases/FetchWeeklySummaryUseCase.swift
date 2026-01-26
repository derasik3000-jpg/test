import Foundation

final class FetchWeeklySummaryUseCase {
    private let metricsRepository: DailyMetricsRepositoryProtocol
    private let chartBuilder: ChartBuilderServiceProtocol
    
    init(
        metricsRepository: DailyMetricsRepositoryProtocol,
        chartBuilder: ChartBuilderServiceProtocol
    ) {
        self.metricsRepository = metricsRepository
        self.chartBuilder = chartBuilder
    }
    
    func execute() async throws -> WeeklyBarsVisualizationDTO {
        let recentDays = try await metricsRepository.fetchRecentDays(dayCount: 7)
        return chartBuilder.buildWeeklyBars(recentDays)
    }
}

