import Foundation

struct QuantumProgressEntry: Identifiable {
    let id: UUID
    let sphereId: UUID
    var morphicTypeValue: ProgressTypeEnum
    var prismaticTitleText: String?
    var chronicleNoteContent: String?
    var temporalEventMoment: Date
    var stellarCreatedTimestamp: Date
    var galaxyUpdatedTimestamp: Date
    var pinnacleFixedFlag: Bool
    var luminousAfterScore: Int?
    var photoFragments: [SpectrumPhotoItem]
    var semanticTags: [String]
    
    enum ProgressTypeEnum: Int {
        case beforeAfter = 0
        case stages = 1
    }
}

