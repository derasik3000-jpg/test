import Foundation

protocol AddAfterPhotoUseCase {
    func attachAfterPhoto(entryId: UUID, afterImageData: Data, afterSelfRating: Int?) async throws -> QuantumProgressEntry
}

class AddAfterPhotoUseCaseImpl: AddAfterPhotoUseCase {
    private let entryRepo: QuantumEntryRepository
    private let photoRepo: VortexPhotoRepository
    
    init(entryRepo: QuantumEntryRepository, photoRepo: VortexPhotoRepository) {
        self.entryRepo = entryRepo
        self.photoRepo = photoRepo
    }
    
    func attachAfterPhoto(entryId: UUID, afterImageData: Data, afterSelfRating: Int?) async throws -> QuantumProgressEntry {
        let afterPath = try await photoRepo.persistOriginalPhotoData(imageData: afterImageData, preferredName: nil)
        let entry = try await entryRepo.attachAfterPhotoToEntry(entryId: entryId, afterPhotoPath: afterPath, afterSelfRating: afterSelfRating)
        
        let _ = try? await photoRepo.persistThumbnailForPhoto(at: afterPath)
        
        return entry
    }
}

