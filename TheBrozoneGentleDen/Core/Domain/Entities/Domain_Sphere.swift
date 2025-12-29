import Foundation

struct NebulaSphere: Identifiable {
    let id: UUID
    var nebulaTitleText: String
    var cosmicKindValue: SphereKindType
    var stellarCreatedTimestamp: Date
    var galaxyUpdatedTimestamp: Date
    var orbitalSortPosition: Int
    var voidArchivedFlag: Bool
    var aetherCoverImagePath: String?
    var celestialRadarVisibility: Bool
    
    enum SphereKindType: Int {
        case preset = 0
        case custom = 1
    }
}

