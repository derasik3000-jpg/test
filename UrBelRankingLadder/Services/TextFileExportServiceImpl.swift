import Foundation
import UIKit

protocol TextFileExportServiceProtocol {
    func generateDayReport(
        metrics: DailyMetricsDTO,
        slotRecords: [String: [MealSlotRecordDTO]],
        ingredientLookup: (UUID) -> FoodIngredientDTO?
    ) -> String
    
    func saveAndShareFile(fileName: String, content: String) async throws
}

final class TextFileExportServiceImpl: TextFileExportServiceProtocol {
    func generateDayReport(
        metrics: DailyMetricsDTO,
        slotRecords: [String: [MealSlotRecordDTO]],
        ingredientLookup: (UUID) -> FoodIngredientDTO?
    ) -> String {
        var output = "UrBel:RankingLadder — Day \(metrics.dayIdentifier)\n\n"
        
        for (slotRaw, slotMetric) in [
            ("morning", metrics.morningMetric),
            ("noon", metrics.noonMetric),
            ("evening", metrics.eveningMetric),
            ("snack", metrics.snackMetric)
        ] {
            let slotName = slotRaw.capitalized
            let records = slotRecords[slotRaw] ?? []
            
            var vegItems: [(String, Double)] = []
            var proItems: [(String, Double)] = []
            var carbItems: [(String, Double)] = []
            
            for record in records {
                guard let ingredient = ingredientLookup(record.ingredientRef) else { continue }
                let entry = (ingredient.titleText, record.portionAmount)
                
                switch ingredient.categoryRaw {
                case "vegetable":
                    vegItems.append(entry)
                case "protein":
                    proItems.append(entry)
                case "carb":
                    carbItems.append(entry)
                default:
                    break
                }
            }
            
            output += "\(slotName): "
            
            if vegItems.isEmpty && proItems.isEmpty && carbItems.isEmpty {
                output += "Empty"
            } else {
                var parts: [String] = []
                
                if !vegItems.isEmpty {
                    let vegText = vegItems.map { "\($0.0)×\($0.1)" }.joined(separator: ", ")
                    parts.append("Veg(\(vegText))")
                }
                
                if !proItems.isEmpty {
                    let proText = proItems.map { "\($0.0)×\($0.1)" }.joined(separator: ", ")
                    parts.append("Protein(\(proText))")
                }
                
                if !carbItems.isEmpty {
                    let carbText = carbItems.map { "\($0.0)×\($0.1)" }.joined(separator: ", ")
                    parts.append("Carbs(\(carbText))")
                }
                
                output += parts.joined(separator: "; ")
            }
            
            output += " | Balance: \(slotMetric)/100\n"
        }
        
        output += "\nDAY SUMMARY: Avg balance \(metrics.averageMetric)/100 | Gold: \(metrics.hasGoldStatus ? "YES" : "NO")\n"
        
        return output
    }
    
    func saveAndShareFile(fileName: String, content: String) async throws {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try content.write(to: tempURL, atomically: true, encoding: .utf8)
        
        await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else {
                return
            }
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            activityVC.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: tempURL)
            }
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
    }
}

