import Foundation

struct GamingPreferenceDraft {
    var iconColorHex: String
    var iconViewType: String
    var lastExportDate: Date?
}

struct GamingPreference {
    let id: UUID
    var iconColorHex: String
    var iconViewType: String
    var lastExportDate: Date?
}

