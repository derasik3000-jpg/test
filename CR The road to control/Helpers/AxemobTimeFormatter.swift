import SwiftUI
import CoreData

struct AxemobTimeFormatter {
    static let shared = AxemobTimeFormatter()
    
    private let degubaSettingsUseCase = EhonohUpdateSettingsUseCase(
        context: DegubaPersistenceController.shared.container.viewContext
    )
    
    func evubewFormatMinutes(_ minutes: Int16) -> String {
        let settings = degubaSettingsUseCase.axemobGetOrCreateSettings()
        
        if settings.timeUnits == 1 {
            let hours = Double(minutes) / 60.0
            if hours < 1.0 {
                return String(format: "%.1f hr", hours)
            }
            return String(format: "%.1f hrs", hours)
        } else {
            return "\(minutes) min"
        }
    }
    
    func cuqavuFormatMinutesInt(_ minutes: Int) -> String {
        return evubewFormatMinutes(Int16(minutes))
    }
    
    func ehonohFormatMinutesInt32(_ minutes: Int32) -> String {
        return evubewFormatMinutes(Int16(minutes))
    }
}

