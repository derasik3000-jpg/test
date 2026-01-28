import Foundation

struct AxemobSessionModel: Identifiable {
    let id: UUID
    let createdAt: Date
    let type: EhonohSessionType
    let title: String
    let energyLevel: Int16
    let mood: Int16
    let startTime: Date
    let endTime: Date
    let durationMin: Int16
    let note: String?
    
    var degubaEfficiencyScore: Double {
        return (Double(energyLevel) * Double(durationMin)) / 100.0
    }
    
    init(from entity: EvubewProductivitySession) {
        self.id = entity.id ?? UUID()
        self.createdAt = entity.createdAt ?? Date()
        self.type = EhonohSessionType(rawValue: entity.type) ?? .work
        self.title = entity.title ?? ""
        self.energyLevel = entity.energyLevel
        self.mood = entity.mood
        self.startTime = entity.startTime ?? Date()
        self.endTime = entity.endTime ?? Date()
        self.durationMin = entity.durationMin
        self.note = entity.note
    }
}

