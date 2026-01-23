import Foundation

struct Week: Identifiable, Equatable {
    let id: UUID
    var isoYear: Int16
    var isoWeek: Int16
    var status: Int16
    var createdAt: Date
    var closedAt: Date?
    var sumCents: Int64
    var maxDeltaPct: Int16
    
    init(id: UUID = UUID(), isoYear: Int16, isoWeek: Int16, status: Int16 = 0, 
         createdAt: Date = Date(), closedAt: Date? = nil, sumCents: Int64 = 0, maxDeltaPct: Int16 = 0) {
        self.id = id
        self.isoYear = isoYear
        self.isoWeek = isoWeek
        self.status = status
        self.createdAt = createdAt
        self.closedAt = closedAt
        self.sumCents = sumCents
        self.maxDeltaPct = maxDeltaPct
    }
}

enum WeekStatus: Int16 {
    case open = 0
    case closed = 1
}

