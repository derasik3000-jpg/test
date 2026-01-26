import Foundation

protocol DailyAggregationServiceProtocol {
    func recomputeDayMetrics(
        dayIdentifier: String,
        slotRecords: [String: [MealSlotRecordDTO]],
        ingredientLookup: (UUID) -> FoodIngredientDTO?,
        balanceService: BalanceCalculationServiceProtocol
    ) -> DailyMetricsDTO
}

final class DailyAggregationServiceImpl: DailyAggregationServiceProtocol {
    func recomputeDayMetrics(
        dayIdentifier: String,
        slotRecords: [String: [MealSlotRecordDTO]],
        ingredientLookup: (UUID) -> FoodIngredientDTO?,
        balanceService: BalanceCalculationServiceProtocol
    ) -> DailyMetricsDTO {
        var morningMetric = 0
        var noonMetric = 0
        var eveningMetric = 0
        var snackMetric = 0
        var hasPerfectSlot = false
        
        for (slot, records) in slotRecords {
            let totals = balanceService.calculateTotals(from: records, ingredientLookup: ingredientLookup)
            let result = balanceService.calculateBalance(for: totals)
            
            let metric = result.balanceMetric
            if result.isPerfectBalance {
                hasPerfectSlot = true
            }
            
            switch slot {
            case "morning":
                morningMetric = metric
            case "noon":
                noonMetric = metric
            case "evening":
                eveningMetric = metric
            case "snack":
                snackMetric = metric
            default:
                break
            }
        }
        
        let avgMetric = (morningMetric + noonMetric + eveningMetric) / 3
        let hasGold = balanceService.determineDayGoldStatus(averageMetric: avgMetric, hasPerfectSlot: hasPerfectSlot)
        
        return DailyMetricsDTO(
            dayIdentifier: dayIdentifier,
            morningMetric: morningMetric,
            noonMetric: noonMetric,
            eveningMetric: eveningMetric,
            snackMetric: snackMetric,
            averageMetric: avgMetric,
            hasGoldStatus: hasGold,
            exportTimestamp: nil
        )
    }
}

