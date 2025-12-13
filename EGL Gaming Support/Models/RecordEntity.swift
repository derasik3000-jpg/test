import Foundation

struct GamingRecordDraft {
    var text: String
    var recordDate: Date?
    var imageData: Data?
}

struct GamingRecord: Identifiable {
    let id: UUID
    var text: String
    var recordDate: Date?
    var imageData: Data?
    let createdAt: Date
    var updatedAt: Date
}
