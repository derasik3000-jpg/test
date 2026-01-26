import Foundation

protocol ChartBuilderServiceProtocol {
    func buildMealPlateVisualization(
        dayIdentifier: String,
        timeSlotRaw: String,
        totals: PortionTotalsCalculation,
        balanceMetric: Int,
        suggestionText: String,
        hasGoldQuality: Bool
    ) -> MealPlateVisualizationDTO
    
    func buildDayOverviewDonut(dayIdentifier: String, metrics: DailyMetricsDTO) -> DayOverviewDonutDTO
    
    func buildWeeklyBars(_ daysData: [DailyMetricsDTO]) -> WeeklyBarsVisualizationDTO
    
    func buildDayTimeline(_ metrics: DailyMetricsDTO) -> DayTimelineVisualizationDTO
}

final class ChartBuilderServiceImpl: ChartBuilderServiceProtocol {
    private let targetVegetables: Double = 3.0
    private let targetProtein: Double = 2.0
    private let targetCarbs: Double = 1.0
    
    func buildMealPlateVisualization(
        dayIdentifier: String,
        timeSlotRaw: String,
        totals: PortionTotalsCalculation,
        balanceMetric: Int,
        suggestionText: String,
        hasGoldQuality: Bool
    ) -> MealPlateVisualizationDTO {
        let vegSegment = DonutSegmentDTO(
            id: UUID(),
            categoryKey: .vegetables,
            displayTitle: "Vegetables",
            targetPortionCount: targetVegetables,
            actualPortionCount: totals.vegetablePortions,
            fillPercentage: min(totals.vegetablePortions / targetVegetables, 1.0),
            excessAmount: max(0, totals.vegetablePortions - targetVegetables),
            colorHexValue: "#00FFFF",
            voiceOverText: "Vegetables: \(Int(totals.vegetablePortions)) of \(Int(targetVegetables)) portions"
        )
        
        let proSegment = DonutSegmentDTO(
            id: UUID(),
            categoryKey: .protein,
            displayTitle: "Protein",
            targetPortionCount: targetProtein,
            actualPortionCount: totals.proteinPortions,
            fillPercentage: min(totals.proteinPortions / targetProtein, 1.0),
            excessAmount: max(0, totals.proteinPortions - targetProtein),
            colorHexValue: "#00BFFF",
            voiceOverText: "Protein: \(Int(totals.proteinPortions)) of \(Int(targetProtein)) portions"
        )
        
        let carbSegment = DonutSegmentDTO(
            id: UUID(),
            categoryKey: .carbs,
            displayTitle: "Carbs",
            targetPortionCount: targetCarbs,
            actualPortionCount: totals.carbPortions,
            fillPercentage: min(totals.carbPortions / targetCarbs, 1.0),
            excessAmount: max(0, totals.carbPortions - targetCarbs),
            colorHexValue: "#87CEEB",
            voiceOverText: "Carbs: \(Int(totals.carbPortions)) of \(Int(targetCarbs)) portion"
        )
        
        return MealPlateVisualizationDTO(
            id: UUID(),
            dayIdentifier: dayIdentifier,
            timeSlotRaw: timeSlotRaw,
            segmentCollection: [vegSegment, proSegment, carbSegment],
            balanceMetric: balanceMetric,
            suggestionText: suggestionText,
            hasGoldQuality: hasGoldQuality
        )
    }
    
    func buildDayOverviewDonut(dayIdentifier: String, metrics: DailyMetricsDTO) -> DayOverviewDonutDTO {
        let slots = [
            (raw: "morning", label: "Morning", metric: metrics.morningMetric),
            (raw: "noon", label: "Noon", metric: metrics.noonMetric),
            (raw: "evening", label: "Evening", metric: metrics.eveningMetric),
            (raw: "snack", label: "Snack", metric: metrics.snackMetric)
        ]
        
        let totalWeight = 4.0
        let segments = slots.map { slot in
            let percent = Int(round(Double(slot.metric) / totalWeight))
            return DailyContributionSegmentDTO(
                id: UUID(),
                timeSlotRaw: slot.raw,
                metricValue: slot.metric,
                contributionWeight: 1.0 / totalWeight,
                contributionPercent: percent,
                displayLabel: "\(slot.label) • \(percent)%",
                voiceOverText: "\(slot.label), \(percent) percent contribution"
            )
        }
        
        return DayOverviewDonutDTO(
            id: UUID(),
            dayIdentifier: dayIdentifier,
            segmentCollection: segments,
            averageMetric: metrics.averageMetric,
            hasGoldQuality: metrics.hasGoldStatus
        )
    }
    
    func buildWeeklyBars(_ daysData: [DailyMetricsDTO]) -> WeeklyBarsVisualizationDTO {
        let bars = daysData.sorted { $0.dayIdentifier < $1.dayIdentifier }.map { day in
            DayMetricBarDTO(
                id: UUID(),
                dayIdentifier: day.dayIdentifier,
                averageMetric: day.averageMetric,
                hasGoldQuality: day.hasGoldStatus,
                voiceOverText: "\(day.dayIdentifier), average balance \(day.averageMetric), \(day.hasGoldStatus ? "with" : "without") gold badge"
            )
        }
        
        return WeeklyBarsVisualizationDTO(
            id: UUID(),
            dayBars: bars,
            maxValueHint: 100,
            captionText: "Last 7 Days"
        )
    }
    
    func buildDayTimeline(_ metrics: DailyMetricsDTO) -> DayTimelineVisualizationDTO {
        let segments = [
            TimelineSlotSegmentDTO(
                id: UUID(),
                timeSlotRaw: "morning",
                metricValue: metrics.morningMetric,
                displayLabel: "Morning \(metrics.morningMetric)",
                voiceOverText: "Morning balance \(metrics.morningMetric)"
            ),
            TimelineSlotSegmentDTO(
                id: UUID(),
                timeSlotRaw: "noon",
                metricValue: metrics.noonMetric,
                displayLabel: "Noon \(metrics.noonMetric)",
                voiceOverText: "Noon balance \(metrics.noonMetric)"
            ),
            TimelineSlotSegmentDTO(
                id: UUID(),
                timeSlotRaw: "evening",
                metricValue: metrics.eveningMetric,
                displayLabel: "Evening \(metrics.eveningMetric)",
                voiceOverText: "Evening balance \(metrics.eveningMetric)"
            ),
            TimelineSlotSegmentDTO(
                id: UUID(),
                timeSlotRaw: "snack",
                metricValue: metrics.snackMetric,
                displayLabel: "Snack \(metrics.snackMetric)",
                voiceOverText: "Snack balance \(metrics.snackMetric)"
            )
        ]
        
        return DayTimelineVisualizationDTO(
            id: UUID(),
            dayIdentifier: metrics.dayIdentifier,
            slotSegments: segments
        )
    }
}

