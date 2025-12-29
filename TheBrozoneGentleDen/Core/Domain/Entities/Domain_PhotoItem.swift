import Foundation

struct SpectrumPhotoItem: Identifiable {
    let id: UUID
    var dimensionalRoleTag: PhotoRoleType
    var vortexStoragePath: String
    var miniatureThumbnailPath: String?
    var temporalCaptureInstant: Date?
    var sequentialOrderIndex: Int
    var pixelWidthDimension: Int?
    var pixelHeightDimension: Int?
    
    enum PhotoRoleType: Int {
        case before = 0
        case after = 1
        case stage = 2
    }
}

