import Foundation

struct CuqavuDailySummaryModel: Identifiable {
    let id: UUID
    let date: Date
    let totalWorkMin: Int32
    let totalStudyMin: Int32
    let totalSportMin: Int32
    let totalRestMin: Int32
    let avgEnergy: Double
    let avgMood: Double
    
    var degubaTotalMinutes: Int32 {
        return totalWorkMin + totalStudyMin + totalSportMin + totalRestMin
    }
    
    init(from entity: CuqavuDailySummary) {
        self.id = entity.id ?? UUID()
        self.date = entity.date ?? Date()
        self.totalWorkMin = entity.totalWorkMin
        self.totalStudyMin = entity.totalStudyMin
        self.totalSportMin = entity.totalSportMin
        self.totalRestMin = entity.totalRestMin
        self.avgEnergy = entity.avgEnergy
        self.avgMood = entity.avgMood
    }
}

