import Foundation

struct EtherealMilestone: Identifiable {
    let id: UUID
    let sphereId: UUID
    var epicTitleText: String
    var chronicleNoteContent: String?
    var temporalAchievementDate: Date
    var connectedEntryReference: UUID?
}

