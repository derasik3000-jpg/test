import Foundation

struct PortionTotalsCalculation {
    let vegetablePortions: Double
    let proteinPortions: Double
    let carbPortions: Double
}

struct BalanceCalculationResult {
    let balanceMetric: Int
    let suggestionText: String
    let isPerfectBalance: Bool
}

protocol BalanceCalculationServiceProtocol {
    func calculateTotals(from records: [MealSlotRecordDTO], ingredientLookup: (UUID) -> FoodIngredientDTO?) -> PortionTotalsCalculation
    func calculateBalance(for totals: PortionTotalsCalculation) -> BalanceCalculationResult
    func determineDayGoldStatus(averageMetric: Int, hasPerfectSlot: Bool) -> Bool
}

final class BalanceCalculationServiceImpl: BalanceCalculationServiceProtocol {
    private let targetVegetables: Double = 3.0
    private let targetProtein: Double = 2.0
    private let targetCarbs: Double = 1.0
    
    func calculateTotals(from records: [MealSlotRecordDTO], ingredientLookup: (UUID) -> FoodIngredientDTO?) -> PortionTotalsCalculation {
        var veg: Double = 0
        var pro: Double = 0
        var carb: Double = 0
        
        for record in records {
            guard let ingredient = ingredientLookup(record.ingredientRef) else { continue }
            
            switch ingredient.categoryRaw {
            case "vegetable":
                veg += record.portionAmount
            case "protein":
                pro += record.portionAmount
            case "carb":
                carb += record.portionAmount
            default:
                break
            }
        }
        
        return PortionTotalsCalculation(
            vegetablePortions: veg,
            proteinPortions: pro,
            carbPortions: carb
        )
    }
    
    func calculateBalance(for totals: PortionTotalsCalculation) -> BalanceCalculationResult {
        let vegFill = min(totals.vegetablePortions / targetVegetables, 1.0)
        let proFill = min(totals.proteinPortions / targetProtein, 1.0)
        let carbFill = min(totals.carbPortions / targetCarbs, 1.0)
        
        let overflow = max(0, totals.vegetablePortions - targetVegetables) +
                       max(0, totals.proteinPortions - targetProtein) +
                       max(0, totals.carbPortions - targetCarbs)
        
        let penalty = min(overflow * 5, 20)
        
        let baseScore = (vegFill + proFill + carbFill) / 3.0 * 100.0
        let finalScore = max(0, baseScore - penalty)
        
        let metric = Int(round(finalScore))
        let isPerfect = metric == 100
        
        let suggestion = generateSuggestion(
            vegFill: vegFill,
            proFill: proFill,
            carbFill: carbFill,
            totals: totals,
            isPerfect: isPerfect
        )
        
        return BalanceCalculationResult(
            balanceMetric: metric,
            suggestionText: suggestion,
            isPerfectBalance: isPerfect
        )
    }
    
    func determineDayGoldStatus(averageMetric: Int, hasPerfectSlot: Bool) -> Bool {
        return hasPerfectSlot || averageMetric >= 90
    }
    
    private func generateSuggestion(vegFill: Double, proFill: Double, carbFill: Double, totals: PortionTotalsCalculation, isPerfect: Bool) -> String {
        if isPerfect {
            return "Perfect balance achieved!"
        }
        
        let vegNeeded = targetVegetables - totals.vegetablePortions
        let proNeeded = targetProtein - totals.proteinPortions
        let carbNeeded = targetCarbs - totals.carbPortions
        
        if vegNeeded > 0.25 && vegFill < proFill && vegFill < carbFill {
            let count = Int(ceil(vegNeeded))
            return "Add \(count) more veggie portion\(count == 1 ? "" : "s")"
        }
        
        if proNeeded > 0.25 && proFill < vegFill && proFill < carbFill {
            let count = Int(ceil(proNeeded))
            return "Add \(count) more protein portion\(count == 1 ? "" : "s")"
        }
        
        if carbNeeded > 0.25 && carbFill < vegFill && carbFill < proFill {
            return "Add 1 more carb portion"
        }
        
        if vegNeeded > 0.25 {
            return "Add more vegetables"
        }
        
        if proNeeded > 0.25 {
            return "Add more protein"
        }
        
        if carbNeeded > 0.25 {
            return "Add more carbs"
        }
        
        return "Almost there!"
    }
}

