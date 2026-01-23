import Foundation

struct Entry: Identifiable, Equatable {
    let id: UUID
    let weekId: UUID
    let envelopeId: UUID
    var amountCents: Int64
    var note: String?
    var at: Date
    var dayKey: Int16
    var wasUndone: Bool
    
    init(id: UUID = UUID(), weekId: UUID, envelopeId: UUID, amountCents: Int64, 
         note: String? = nil, at: Date = Date(), dayKey: Int16, wasUndone: Bool = false) {
        self.id = id
        self.weekId = weekId
        self.envelopeId = envelopeId
        self.amountCents = amountCents
        self.note = note
        self.at = at
        self.dayKey = dayKey
        self.wasUndone = wasUndone
    }
}

