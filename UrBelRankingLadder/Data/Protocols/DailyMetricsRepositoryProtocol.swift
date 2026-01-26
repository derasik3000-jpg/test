import Foundation

protocol DailyMetricsRepositoryProtocol {
    func fetchMetrics(dayIdentifier: String) async throws -> DailyMetricsDTO?
    func upsertMetrics(_ metricsData: DailyMetricsDTO) async throws
    func fetchRecentDays(dayCount: Int) async throws -> [DailyMetricsDTO]
}

