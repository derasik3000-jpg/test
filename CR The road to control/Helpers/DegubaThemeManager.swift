import SwiftUI
import Combine
import CoreData

struct DegubaThemeColors {
    let evubewPrimary: Color
    let cuqavuSecondary: Color
    let degubaBackground: Color
    let degubaCardBackground: Color
    let degubaSurfaceBackground: Color
    
    static let axemobThemes: [DegubaThemeColors] = [
        DegubaThemeColors(
            evubewPrimary: Color(red: 0.96, green: 0.84, blue: 0.26), // Яркий золотой
            cuqavuSecondary: Color(red: 1.0, green: 0.88, blue: 0.0), // Желто-золотой
            degubaBackground: Color(red: 0.1, green: 0.1, blue: 0.12), // Темный фон
            degubaCardBackground: Color(red: 0.15, green: 0.15, blue: 0.18), // Темная карточка
            degubaSurfaceBackground: Color(red: 0.12, green: 0.12, blue: 0.14) // Темная поверхность
        ),
        DegubaThemeColors(
            evubewPrimary: Color(red: 0.96, green: 0.84, blue: 0.26), // Яркий золотой
            cuqavuSecondary: Color(red: 1.0, green: 0.88, blue: 0.0), // Желто-золотой
            degubaBackground: Color(red: 0.1, green: 0.1, blue: 0.12), // Темный фон
            degubaCardBackground: Color(red: 0.15, green: 0.15, blue: 0.18), // Темная карточка
            degubaSurfaceBackground: Color(red: 0.12, green: 0.12, blue: 0.14) // Темная поверхность
        ),
        DegubaThemeColors(
            evubewPrimary: Color(red: 0.96, green: 0.84, blue: 0.26), // Яркий золотой
            cuqavuSecondary: Color(red: 1.0, green: 0.88, blue: 0.0), // Желто-золотой
            degubaBackground: Color(red: 0.1, green: 0.1, blue: 0.12), // Темный фон
            degubaCardBackground: Color(red: 0.15, green: 0.15, blue: 0.18), // Темная карточка
            degubaSurfaceBackground: Color(red: 0.12, green: 0.12, blue: 0.14) // Темная поверхность
        )
    ]
    
    static func ehonohGetTheme(_ index: Int16) -> DegubaThemeColors {
        let safeIndex = Int(index) % axemobThemes.count
        return axemobThemes[safeIndex]
    }
}

class CuqavuThemeManager: ObservableObject {
    static let shared = CuqavuThemeManager()
    
    @Published var degubaCurrentTheme: DegubaThemeColors
    
    private init() {
        let settingsUseCase = EhonohUpdateSettingsUseCase(context: DegubaPersistenceController.shared.container.viewContext)
        let settings = settingsUseCase.axemobGetOrCreateSettings()
        self.degubaCurrentTheme = DegubaThemeColors.ehonohGetTheme(settings.themeIndex)
    }
    
    func evubewUpdateTheme(_ index: Int16) {
        degubaCurrentTheme = DegubaThemeColors.ehonohGetTheme(index)
    }
}

