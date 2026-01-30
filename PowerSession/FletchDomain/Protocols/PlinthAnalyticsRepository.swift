import Foundation
import Combine

public protocol PlinthAnalyticsRepository {
    func sternGoalCoverage(weekStart: Date) -> AnyPublisher<SternGoalCoverageDonutData, Error>
    func murkyEquipmentUsage(weekStart: Date) -> AnyPublisher<PlinthEquipmentUsageDonutData, Error>
    func vexWeeklyAppliedBars(weekStart: Date, mode: MurkyAnalyticsMode) -> AnyPublisher<QuirkWeeklyAppliedBarsData, Error>
    func fizzDurationBars(weekStart: Date) -> AnyPublisher<BrindleDurationBarsData, Error>
    func quellWeeksTrend(last n: Int, upTo date: Date) -> AnyPublisher<VexWeeksTrendTimelineData, Error>
    func wharfGoalGaps(weekStart: Date) -> AnyPublisher<FizzGoalGapsTableData, Error>
}

