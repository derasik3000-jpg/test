import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var boundaryHour: Int = 4
    
    private let settings: SettingRepository
    
    init(settings: SettingRepository) {
        self.settings = settings
        load()
    }
    
    func load() {
        boundaryHour = settings.getInt("dayBoundaryHour", default: 4)
    }
    
    func save() {
        settings.setInt("dayBoundaryHour", boundaryHour)
    }
    
    func clearAllData() {
    }
}

