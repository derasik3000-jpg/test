import Foundation

protocol CreateBeforeAfterEntryUseCase {
    func createBeforeAfterEntry(input: CreateBeforeAfterInput) async throws -> QuantumProgressEntry
}

struct CreateBeforeAfterInput {
    let sphereId: UUID
    let title: String?
    let note: String?
    let eventDate: Date
    let tags: [String]
    let beforeImageData: Data
    let afterImageData: Data?
    let afterSelfRating: Int?
}

class CreateBeforeAfterEntryUseCaseImpl: CreateBeforeAfterEntryUseCase {
    private let entryRepo: QuantumEntryRepository
    private let photoRepo: VortexPhotoRepository
    
    init(entryRepo: QuantumEntryRepository, photoRepo: VortexPhotoRepository) {
        self.entryRepo = entryRepo
        self.photoRepo = photoRepo
    }
    
    func createBeforeAfterEntry(input: CreateBeforeAfterInput) async throws -> QuantumProgressEntry {
        let beforePath = try await photoRepo.persistOriginalPhotoData(imageData: input.beforeImageData, preferredName: nil)
        
        let afterPath: String?
        if let afterData = input.afterImageData {
            afterPath = try await photoRepo.persistOriginalPhotoData(imageData: afterData, preferredName: nil)
        } else {
            afterPath = nil
        }
        
        let entry = try await entryRepo.insertBeforeAfterEntryRecord(
            sphereId: input.sphereId,
            title: input.title,
            note: input.note,
            eventDate: input.eventDate,
            tags: input.tags,
            beforePhotoPath: beforePath,
            afterPhotoPath: afterPath,
            afterSelfRating: input.afterSelfRating
        )
        
        let _ = try? await photoRepo.persistThumbnailForPhoto(at: beforePath)
        if let afterPath = afterPath {
            let _ = try? await photoRepo.persistThumbnailForPhoto(at: afterPath)
        }
        
        return entry
    }
}

