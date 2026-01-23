import Foundation

struct MissionProgress: Identifiable, Equatable {
    let id: UUID
    let weekId: UUID
    var dailyFootprintDays: Int16
    var noSkewDays: Int16
    var balancedAchieved: Bool
    
    init(id: UUID = UUID(), weekId: UUID, dailyFootprintDays: Int16 = 0, 
         noSkewDays: Int16 = 0, balancedAchieved: Bool = false) {
        self.id = id
        self.weekId = weekId
        self.dailyFootprintDays = dailyFootprintDays
        self.noSkewDays = noSkewDays
        self.balancedAchieved = balancedAchieved
    }
}

