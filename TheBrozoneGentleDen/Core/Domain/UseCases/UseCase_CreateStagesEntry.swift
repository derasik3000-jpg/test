import Foundation

protocol CreateStagesEntryUseCase {
    func createStagesEntry(input: CreateStagesInput) async throws -> QuantumProgressEntry
}

struct CreateStagesInput {
    let sphereId: UUID
    let title: String?
    let note: String?
    let eventDate: Date
    let tags: [String]
    let stageImagesData: [Data]
}

class CreateStagesEntryUseCaseImpl: CreateStagesEntryUseCase {
    private let entryRepo: QuantumEntryRepository
    private let photoRepo: VortexPhotoRepository
    
    init(entryRepo: QuantumEntryRepository, photoRepo: VortexPhotoRepository) {
        self.entryRepo = entryRepo
        self.photoRepo = photoRepo
    }
    
    func createStagesEntry(input: CreateStagesInput) async throws -> QuantumProgressEntry {
        guard input.stageImagesData.count >= 2 && input.stageImagesData.count <= 10 else {
            throw AuroraFluxError.validationFailed("Stages must have 2-10 photos")
        }
        
        var stagePaths: [String] = []
        for imageData in input.stageImagesData {
            let path = try await photoRepo.persistOriginalPhotoData(imageData: imageData, preferredName: nil)
            stagePaths.append(path)
        }
        
        let entry = try await entryRepo.insertStagesEntryRecord(
            sphereId: input.sphereId,
            title: input.title,
            note: input.note,
            eventDate: input.eventDate,
            tags: input.tags,
            stagePhotoPaths: stagePaths
        )
        
        for path in stagePaths {
            let _ = try? await photoRepo.persistThumbnailForPhoto(at: path)
        }
        
        return entry
    }
}

