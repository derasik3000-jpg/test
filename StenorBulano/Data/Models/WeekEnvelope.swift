import Foundation

struct WeekEnvelope: Identifiable, Equatable {
    let id: UUID
    let weekId: UUID
    var orderIndex: Int16
    var name: String
    var sumCents: Int64
    
    init(id: UUID = UUID(), weekId: UUID, orderIndex: Int16, name: String, sumCents: Int64 = 0) {
        self.id = id
        self.weekId = weekId
        self.orderIndex = orderIndex
        self.name = name
        self.sumCents = sumCents
    }
}

enum EnvelopeSlot: Int, CaseIterable, Codable {
    case a = 0
    case b = 1
    case c = 2
}

